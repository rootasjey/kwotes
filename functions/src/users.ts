import * as functions from 'firebase-functions';

import { adminApp } from './adminApp';
import { checkUserIsSignedIn } from './utils';

const firestore = adminApp.firestore();

export const checkEmailAvailability = functions
  .region('europe-west3')
  .https
  .onCall(async (data) => {
    const email: string = data.email;

    if (!(typeof email === 'string') || email.length === 0) {
      throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
        'one (string) argument "email" which is the email to check.');
    }

    if (!validateEmailFormat(email)) {
      throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
        'a valid email address.');
    }

    let isAvailable = true;

    const emailSnap = await firestore
      .collection('users')
      .where('email', '==', email)
      .limit(1)
      .get();

    isAvailable = emailSnap.empty;

    try {
      const userRecord = await adminApp
        .auth()
        .getUserByEmail(email);

      if (userRecord) {
        isAvailable = false;
      }

      isAvailable = true;

    } catch (error) {
      isAvailable = true;
    }

    return {
      email,
      isAvailable,
    };
  });

export const checkNameAvailability = functions
  .region('europe-west3')
  .https
  .onCall(async (data) => {
    const name: string = data.name;

    if (!(typeof name === 'string') || name.length === 0) {
      throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
        'one (string) argument "name" which is the name to check.');
    }

    if (!validateNameFormat(name)) {
      throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
        'a valid name with at least 3 alpha-numeric characters (underscore is allowed) (A-Z, 0-9, _).');
    }

    const nameSnap = await firestore
      .collection('users')
      .where('nameLowerCase', '==', name.toLowerCase())
      .limit(1)
      .get();

    return {
      name: name,
      isAvailable: nameSnap.empty,
    };
  });

async function checkNameLowerCaseUpdate(params: DataUpdateParams) {
  const { beforeData, afterData, payload, docId } = params;

  if (beforeData.nameLowerCase === afterData.nameLowerCase) {
    return payload;
  }

  if (!afterData.nameLowerCase) {
    payload['nameLowerCase'] = beforeData.nameLowerCase || `user_${Date.now()}`;
    return payload;
  }

  if (!validateNameFormat(afterData.nameLowerCase)) {
    const sampleName = `user_${Date.now()}`;
    payload.nameLowerCase = sampleName;

    return payload;
  }

  const nameLowerCase = afterData.nameLowerCase;
  const userNamesSnap = await firestore
    .collection('users')
    .where('nameLowerCase', '==', nameLowerCase)
    .limit(2)
    .get();

  const exactMatch = userNamesSnap.docs
    .filter((doc) => doc.id !== docId);

  if (exactMatch.length > 0) { // the name already exists
    const suffix = Date.now();
    payload.name = `${nameLowerCase}-${suffix}`;
    payload.nameLowerCase = `${nameLowerCase}-${suffix}`;
  }

  return payload;
}

async function checkNameUpdate(params: DataUpdateParams) {
  const { beforeData, afterData, payload, docId } = params;

  if (beforeData.name === afterData.name) { return payload; }

  if (!afterData.name) {
    payload['name'] = beforeData.name || `user_${Date.now()}`;
    return payload;
  }

  const nameLowerCase = (afterData.name as string).toLowerCase();

  if (!validateNameFormat(nameLowerCase)) {
    const sampleName = `user_${Date.now()}`;
    payload.name = sampleName;
    payload.nameLowerCase = sampleName;

    return payload;
  }

  const userNamesSnap = await firestore
    .collection('users')
    .where('nameLowerCase', '==', nameLowerCase)
    .limit(2)
    .get();

  const exactMatch = userNamesSnap.docs
    .filter((doc) => doc.id !== docId);

  if (exactMatch.length > 0) { // not good
    payload['name'] = beforeData.name;

  } else if (beforeData.nameLowerCase !== nameLowerCase) { // it's ok
    payload['nameLowerCase'] = (afterData.name as string).toLowerCase();
  }

  return payload;
}

function checkRights(params: DataUpdateParams) {
  const { beforeData, afterData, payload } = params;

  let rightsOk = true;

  for (const [key, value] of Object.entries(afterData.rights)) {
    const isEqual = value === beforeData.rights[key];

    rightsOk = rightsOk && isEqual;
  }

  if (rightsOk) { return payload; }
  return { ...payload, ...{ 'rights': beforeData.rights } };
}

async function checkUserName(
  data: FirebaseFirestore.DocumentData,
  payload: any,
) {
  if (!data) { return payload; }

  let nameLowerCase = '';

  if (data.name) { nameLowerCase = (data.name as string).toLowerCase(); }
  else { nameLowerCase = payload.nameLowerCase; }

  const userNamesSnap = await firestore
    .collection('users')
    .where('nameLowerCase', '==', nameLowerCase)
    .limit(1)
    .get();

  if (userNamesSnap.empty) { return payload; }

  const suffix = Date.now();

  return { ...payload, ...{
    name: `${payload.name}-${suffix}`,
    nameLowerCase: `${payload.name}-${suffix}`
  } };
}

/**
 * Create an user with Firebase auth then with Firestore.
 * Check user's provided arguments and exit if wrong.
 */
export const createAccount = functions
  .region('europe-west3')
  .https
  .onCall(async (data: CreateUserAccountParams) => {
    if (!checkCreateAccountData(data)) {
      throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
        '3 string arguments "username", "email" and "password".');
    }

    const { username, password, email } = data;

    try {
      const userRecord = await adminApp.auth()
      .createUser({
        displayName: username,
        password: password,
        email: email,
        emailVerified: false,
      });

      await adminApp.firestore()
      .collection('users')
      .doc(userRecord.uid)
      .set({
        email: email,
        lang: 'en',
        name: username,
        nameLowerCase: username.toLowerCase(),
        pricing: 'free',
        quota: {
          current: 0,
          date: Date.now(),
          limit: 1,
        },
        rights: {
          'user:managedata'     : false,
          'user:manageauthor'   : false,
          'user:managequote'    : false,
          'user:managequotidian': false,
          'user:managereference': false,
          'user:proposequote'   : true,
          'user:readquote'      : true,
          'user:validatequote'  : false,
        },
        settings: {
          notifications: {
            email: {
              tempQuotes: true,
              quotidians: false,
            },
            push: {
              quotidians: true,
              tempQuotes: true,
            }
          },
        },
        stats: {
          fav: 0,
          lists: 0,
          proposed: 0,
          published: 0,
          tempQuotes: 0,
          notifications: {
            total: 0,
            unread: 0,
          }
        },
        urls: {
          image: '',
          twitter: '',
          facebook: '',
          instagram: '',
          twitch: '',
          website: '',
          wikipedia: '',
          youtube: '',
        },
        uid: userRecord.uid,
      });

      return {
        user: data,
        success: true,
        error: {
          body: "",
          type: "",
        }
      };

    } catch (error) {
      return {
        user: data,
        success: false,
        error: {
          body: "Couldn't create a new user record. Try again later or contact someone at contact@fig.style",
          type: "account_creation",
        }
      };
    }
  });

function checkCreateAccountData(data: any) {
  if (Object.keys(data).length !== 3) {
    return false;
  }

  const keys = Object.keys(data);

  if (keys.indexOf('username') < 0 
    || keys.indexOf('email') < 0 
    || keys.indexOf('password') < 0) {
    return false;
  }

  if (!data['username'] || !data['email'] || !data['password']) {
    return false;
  }

  return true;
}

/**
 * Delete user's entry from Firebase auth and from Firestore.
 * Add a new document to the `todelete` collection to clear user's data
 * as `notifications`, `drafts`, `lists`, `favourites` sub-collection.
 */
export const deleteAccount = functions
  .region('europe-west3')
  .https
  .onCall(async (data, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError('unauthenticated', 'The function must be called from ' +
        'an authenticated user.');
    }

    await checkUserIsSignedIn(context);

    const userSnapshot = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .get();


    const userData = userSnapshot.data();
    
    if (!userSnapshot.exists || !userData) {
      return {
        success: false,
        error: {
          message: "This user document doesn't exist anymore.",
        },
        uid: userAuth.uid,
      };
    }

    const stats = userData.stats;
    const totalItemsCount = stats.fav + stats.lists + 
      stats.tempQuotes + stats.notifications.total;

    // Add delete entry.
    // Eventually set the quote.author.id field to anonymous's id.
    await firestore
      .collection('todelete')
      .doc(userAuth.uid)
      .set({
        doc: {
          id: userAuth.uid,
          conceptualType: 'user',
          dataType: 'document',
          hasChildren: true,
        },
        path: `users/${userAuth.uid}`,
        task: {
          createdAt: Date.now(),
          done: false,
          items: {
            deleted: 0,
            total: totalItemsCount ?? 0,
          },
          updatedAt: Date.now(),
        },
        user: {
          id: userAuth.uid,
        },
      });

    // Delete user auth
    await adminApp
      .auth()
      .deleteUser(userAuth.uid);

    // Delete Firestore document
    await firestore
      .collection('users')
      .doc(userAuth.uid)
      .delete();

    return {
      success: true,
      uid: userAuth.uid,
    };
  });

/**
 * Increment user's quote proposition quota.
 * All users have a daily quota limit except moderators or special users.
 * The quota resets everyday at midnight +1 second.
 */
export const incrementQuota = functions
  .region('europe-west3')
  .firestore
  .document('tempquotes/{tempquoteId}')
  .onCreate(async (snapshot, context) => {
    const snapshotData = snapshot.data();
    if (!snapshotData) { return; }

    const userUid = snapshotData.user.id;
    if (!userUid) { return; }

    const userDoc = await firestore
      .collection('users')
      .doc(userUid)
      .get();

    if (!userDoc.exists) { return; }

    const data = userDoc.data();
    if (!data) { return; }

    const serverDate = new Date(context.timestamp);
    const quota = data.quota;

    let date = quota.date !== null && typeof quota.date !== 'undefined' ?
      quota.date.toDate() :
      new Date('January 1');

    let current: number = quota['current'];

    if (date.getDate() !== serverDate.getDate() ||
      date.getMonth() !== serverDate.getMonth() ||
      date.getFullYear() !== serverDate.getFullYear()) {

      current = 0;
      date = serverDate;
    }

    current += 1;

    return await userDoc.ref
      .update({
        'quota.date': adminApp.firestore.Timestamp.fromDate(date),
        'quota.current': current,
      });
  });

async function isUserByEmailExists(email: string) {
  const emailSnapshot = await firestore
    .collection('users')
    .where('email', '==', email)
    .limit(1)
    .get();

  if (!emailSnapshot.empty) {
    return true;
  }

  try {
    const userRecord = await adminApp
      .auth()
      .getUserByEmail(email);

    if (userRecord) {
      return true;
    }

    return false;

  } catch (error) {
    return false;
  }
}

async function isUserByUsernameExists(nameLowerCase: string) {
  const nameSnapshot = await firestore
    .collection('users')
    .where('nameLowerCase', '==', nameLowerCase)
    .limit(1)
    .get();

  if (nameSnapshot.empty) {
    return false;
  }

  return true;
}

// Check that the new created doc is well-formatted.
export const newAccountCheck = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}')
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    let payload: any = {};

    if (!data) {
      payload = await populateUserData(snapshot);

    }

    if (typeof data.rights === 'undefined') {
      payload.rights = {
        'user:managedata'     : false,
        'user:manageauthor'   : false,
        'user:managequote'    : false,
        'user:managequotidian': false,
        'user:managereference': false,
        'user:proposequote'   : true,
        'user:readquote'      : true,
        'user:validatequote'  : false,
      };

    }

    if (!data.name || !data.nameLowerCase) {
      payload = populateUserNameIfEmpty(data, payload);
      payload = await checkUserName(data, payload);
    }

    if (!validateNameFormat(name)) {
      const sampleName = `user_${Date.now()}`;
      payload.name = sampleName;
      payload.nameLowerCase = sampleName;
    }

    if (Object.keys(payload).length === 0) { return; }

    return await snapshot.ref.update(payload);
  });

// Add all missing props.
async function populateUserData(snapshot: functions.firestore.DocumentSnapshot) {
  const user = await adminApp.auth().getUser(snapshot.id);
  const email = typeof user !== 'undefined' ?
    user.email : '';

  const suffix = Date.now();

  return {
    'email': email,
    'flag': '',
    'lang': 'en',
    'name': `user_${suffix}`,
    'nameLowerCase': `user_${suffix}`,
    'notifications': [],
    'pricing': 'free',
    'quota': {
      'current': 0,
      'date': Date.now(),
      'limit': 1,
    },
    'rights': {
      'user:managedata': false,
      'user:manageauthor': false,
      'user:managequote': false,
      'user:managequotidian': false,
      'user:managereference': false,
      'user:proposequote': true,
      'user:readquote': true,
      'user:validatequote': false,
    },
    'stats': {
      'favourites': 0,
      'lists': 0,
      'proposed': 0,
    },
    'tokens': {},
    'urls': {
      'image': '',
    },
    'uid': snapshot.id,
  };
}

function populateUserNameIfEmpty(
  data: FirebaseFirestore.DocumentData,
  payload: any,
): FirebaseFirestore.DocumentData {

  if (!data) { return payload; }
  if (data.name && data.nameLowerCase) { return payload; }

  let name = data.name || data.nameLowerCase;
  name = name || `user_${Date.now()}`;

  return {
    ...payload, ...{
      name: name,
      nameLowerCase: name,
    }
  };
}

/**
 * Update an user's email in Firebase auth and in Firestore.
 * Several security checks are made (email format, password, email unicity)
 * before validating the new email.
 */
export const updateEmail = functions
  .region('europe-west3')
  .https
  .onCall(async (data: UpdateEmailParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError('unauthenticated', 'The function must be called from ' +
        'an authenticated user.');
    }

    await checkUserIsSignedIn(context);

    const { newEmail } = data;
    const isFormatOk = validateEmailFormat(newEmail);
      
    if (!newEmail || !isFormatOk) {
      throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
        'a valid "newEmail" argument. The value you specified is not in a correct email format.');
    }

    const isEmailTaken = await isUserByEmailExists(newEmail);

    if (isEmailTaken) {
      throw new functions.https.HttpsError('invalid-argument', 'The email specified ' +
        'is not available. Try specify a new one in the "newEmail" argument.');
    }

    await adminApp
    .auth()
    .updateUser(userAuth.uid, {
      email: newEmail,
      emailVerified: false,
    });

    await firestore
      .collection('users')
      .doc(userAuth.uid)
      .update({
        email: newEmail,
      });

    return {
      success: true,
      uid: userAuth.uid,
    };
  });


/**
 * Update a new username in Firebase auth and in Firestore.
 * Several security checks are made (name format & unicity, password)
 * before validating the new username.
 */
export const updateUsername = functions
  .region('europe-west3')
  .https
  .onCall(async (data: UpdateUsernameParams, context) => {
    const userAuth = context.auth;
    
    if (!userAuth) {
      throw new functions.https.HttpsError('unauthenticated', 'The function must be called from ' +
      'an authenticated user.');
    }

    await checkUserIsSignedIn(context);

    const { newUsername } = data;
    const isFormatOk = validateNameFormat(newUsername);

    if (!newUsername || !isFormatOk) {
      throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
        'a valid "newUsername". The value you specified is not in a correct format.');
    }

    const isUsernameTaken = await isUserByUsernameExists(newUsername.toLowerCase());

    if (isUsernameTaken) {
      throw new functions.https.HttpsError('invalid-argument', 'The name specified ' +
        'is not available. Please try with a new one.');
    }

    await adminApp
      .auth()
      .updateUser(userAuth.uid, {
        displayName: newUsername,
      });

    await firestore
      .collection('users')
      .doc(userAuth.uid)
      .update({
        name: newUsername,
        nameLowerCase: newUsername.toLowerCase(),
      });

    return {
      success: true,
      uid: userAuth.uid,
    };
  });


// Prevent user's rights update
// and user name conflicts.
// TODO: Allow admins to update user's rights.
export const updateUserCheck = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}')
  .onUpdate(async (change) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    if (!beforeData || !afterData) { return; }

    let payload: any = {};

    const params: DataUpdateParams = {
      beforeData,
      afterData,
      payload,
      docId: change.after.id,
    };

    payload = checkRights(params);
    payload = await checkNameUpdate(params);
    payload = await checkNameLowerCaseUpdate(params);

    if (Object.keys(payload).length === 0) { return; }

    if (payload.nameLowerCase) { // auto-update auth user
      const displayName = payload.name ?? afterData.name;

      await adminApp
      .auth()
      .updateUser(change.after.id, {
        displayName: displayName,
      });
    }

    return await change.after.ref
      .update(payload);
  });

function validateEmailFormat(email: string) {
  const re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
}

function validateNameFormat(name: string) {
  const re = /[a-zA-Z0-9_]{3,}/;
  const matches = re.exec(name);

  if (!matches) { return false; }
  if (matches.length < 1) { return false; }

  const firstMatch = matches[0];
  return firstMatch === name;
}
