import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

import { adminApp } from './adminApp';

const firestore = adminApp.firestore();

export const checkEmailAvailable = functions
  .region('europe-west3')
  .https
  .onCall(async (data, context) => {
    const email: string = data.email;

    if (!(typeof email === 'string') || email.length === 0) {
      throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
        'one argument "email" which is the email to check.');
    }


    if (!validateEmailFormat(email)) {
      throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
        'a valid email address.');
    }

    const emailSnap = await firestore
      .collection('users')
      .where('email', '==', email)
      .limit(1)
      .get();

    return {
      email,
      isAvailable: emailSnap.empty,
    };
  });

async function checkNameLowerCaseUpdate(params: DataUpdateParams) {
  const { beforeData, afterData, payload, docId } = params;

  if (beforeData.nameLowerCase === afterData.nameLowerCase) {
    return payload;
  }

  if (!afterData.nameLowerCase) {
    payload['nameLowerCase'] = beforeData.nameLowerCase || `user-${Date.now()}`;
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

  if (exactMatch.length > 0) {
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
    payload['name'] = beforeData.name || `user-${Date.now()}`;
    return payload;
  }

  const nameLowerCase = (afterData.name as string).toLowerCase();

  const userNamesSnap = await firestore
    .collection('users')
    .where('nameLowerCase', '==', nameLowerCase)
    .limit(2)
    .get();

  const exactMatch = userNamesSnap.docs
    .filter((doc) => doc.id !== docId);

  if (exactMatch.length > 0) { // not good
    payload['name'] = beforeData.name;

  } else { // it's ok
    if (beforeData.nameLowerCase !== afterData.nameLowerCase) {
      payload['nameLowerCase'] = (afterData.name as string).toLowerCase();
    }
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

export const incrementQuoteQuota = functions
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
        'quota.date': admin.firestore.Timestamp.fromDate(date),
        'quota.current': current,
      });
  });

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

// Check that the new created doc is well-formatted.
export const newAccountCheck = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}')
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    let payload: any = {};

    if (!data) {
      payload = await populateUserData(snapshot);

    } else if (typeof data.rights === 'undefined') {
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

    } else if (!data.name || !data.nameLowerCase) {
      payload = populateUserNameIfEmpty(data, payload);
      payload = await checkUserName(data, payload);
    }

    if (Object.keys(payload).length === 0) { return; }

    return await snapshot.ref.update(payload);
  });

// Add all missing props.
async function populateUserData(snapshot: functions.firestore.DocumentSnapshot) {
  const user = await admin.auth().getUser(snapshot.id);
  const email = typeof user !== 'undefined' ?
    user.email : '';

  const suffix = Date.now();

  return {
    'email': email,
    'flag': '',
    'lang': 'en',
    'name': `user-${suffix}`,
    'nameLowerCase': `user-${suffix}`,
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
  name = name || `user-${Date.now()}`;

  return {
    ...payload, ...{
      name: name,
      nameLowerCase: name,
    }
  };
}

// Prevent user's rights update
// and user name conflicts.
// TODO: Allow admins to update user's rights.
export const updateUserCheck = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
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

    return await change.after.ref
      .update(payload);
  });

function validateEmailFormat(email: string) {
  const re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
}
