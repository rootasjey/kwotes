import * as functions from 'firebase-functions';

import { adminApp } from './adminApp';
import { checkUserIsSignedIn } from './utils';

const firebaseTools = require('firebase-tools');
const firestore = adminApp.firestore();

/**
 * TODO: TEMPORARY: Delete after execution.
 * Update list.quote document to use same id.
 * Must be used after app updates (mobile & web).
 */
export const configUpdateUserLists = functions
  .region('europe-west3')
  .https
  .onRequest(async ({}, res) => {
    // The app has very few users right now (less than 20).
    const userSnapshot = await firestore
      .collection('users')
      .limit(100)
      .get();

    // For each user
    userSnapshot.docs.forEach(async (userDoc) => {
      // Get all lists
      const listsSnapshot = await firestore
        .collection(`users/${userDoc.id}/lists`)
        .get();

      // For each list
      for await (const listDoc of listsSnapshot.docs) {
        // Get all quotes
        const quotesSnap = await firestore
          .collection(`users/${userDoc.id}/lists/${listDoc.id}/quotes`)
          .get();

        // For each quote
        for await (const quoteDoc of quotesSnap.docs) {
          const quoteData = quoteDoc.data();
          
          // Check if the quote has the `quoteId` prop.
          // If this prop. exists, it uses the old data model 
          // so it must be updated.
          if (quoteData.quoteId) {
            // Add a new quote doc with the right id and the same data.
            await firestore
              .collection(`users/${userDoc.id}/lists/${listDoc.id}/quotes`)
              .doc(quoteDoc.id)
              .set(quoteDoc.data());
  
            // Delete the old quote doc.
            await quoteDoc.ref.delete();
          }
        }
      }
    });

    res.status(200).send('done');
  });

export const checkEmailAvailability = functions
  .region('europe-west3')
  .https
  .onCall(async (data) => {
    const email: string = data.email;

    if (!(typeof email === 'string') || email.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with one (string) argument "email" which is the email to check.`,
      );
    }

    if (!validateEmailFormat(email)) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid email address.`,
      );
    }

    const exists = await isUserExistsByEmail(email);
    const isAvailable = !exists;

    return {
      email,
      isAvailable,
    };
  });

export const checkUsernameAvailability = functions
  .region('europe-west3')
  .https
  .onCall(async (data) => {
    const name: string = data.name;

    if (!(typeof name === 'string') || name.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with one (string) argument "name" which is the name to check.`,
      );
    }

    if (!validateNameFormat(name)) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid name with at least 3 alpha-numeric characters (underscore is allowed) (A-Z, 0-9, _).`,
      );
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

/**
 * Create an user with Firebase auth then with Firestore.
 * Check user's provided arguments and exit if wrong.
 */
export const createAccount = functions
  .region('europe-west3')
  .https
  .onCall(async (data: CreateUserAccountParams) => {
    if (!checkCreateAccountData(data)) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with 3 string arguments "username", "email" and "password".`,
      );
    }

    const { username, password, email } = data;

    try {
      const userRecord = await adminApp
      .auth()
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
        developer: {
          apps: {
            current: 0,
            limit: 5,
          },
          isProgramActive: false,
          payment: {
            isActive: false,
            plan: 'free',
            stripeId: '',
          }
        },
        email: email,
        lang: 'en',
        name: username,
        nameLowerCase: username.toLowerCase(),
        pricing: 'free',
        quota: {
          current: 0,
          date: new Date(),
          limit: 20,
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
        user: {
          id: userRecord.uid, 
          email,
        },
      };

    } catch (error) {
      throw new functions.https.HttpsError(
        'internal', 
        `There was an internal error while creating your account. Please try again or contact us if the problem persists".`,
      );
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
 * Delete user's document from Firebase auth & Firestore.
 */
export const deleteAccount = functions
  .region('europe-west3')
  .https
  .onCall(async (data: DeleteAccountParams, context) => {
    const userAuth = context.auth;
    const { idToken } = data;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    await checkUserIsSignedIn(context, idToken);

    const userSnap = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .get();

    const userData = userSnap.data();

    if (!userSnap.exists || !userData) {
      throw new functions.https.HttpsError(
        'not-found',
        `This user document doesn't exist. It may have been deleted.`,
      );
    }

    await adminApp
      .auth()
      .deleteUser(userAuth.uid);

    await firebaseTools.firestore
      .delete(userSnap.ref.path, {
        project: process.env.GCLOUD_PROJECT,
        recursive: true,
        yes: true,
      });

    return {
      success: true,
      user: {
        id: userAuth.uid,
      },
    };
  });

async function isUserExistsByEmail(email: string) {
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

async function isUserExistsByUsername(nameLowerCase: string) {
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
    const { idToken, newEmail } = data;

    if (!userAuth) {
      throw new functions.https.HttpsError('unauthenticated', 'The function must be called from ' +
        'an authenticated user (1).');
    }

    await checkUserIsSignedIn(context, idToken);

    const isFormatOk = validateEmailFormat(newEmail);

    if (!newEmail || !isFormatOk) {
      throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
        'a valid "newEmail" argument. The value you specified is not in a correct email format.');
    }

    const isEmailTaken = await isUserExistsByEmail(newEmail);

    if (isEmailTaken) {
      throw new functions.https.HttpsError('invalid-argument', 'The email specified ' +
        'is not available. Try specify a new one in the "newEmail" argument.');
    }

    try {
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
        user: { id: userAuth.uid },
      };

    } catch (error) {
      throw new functions.https.HttpsError('internal', 'There was an internal error ' +
        'while creating your account. Please try again or contact us if the problem persists".');
    }
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

    const { newUsername } = data;
    const isFormatOk = validateNameFormat(newUsername);

    if (!newUsername || !isFormatOk) {
      throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
        'a valid "newUsername". The value you specified is not in a correct format.');
    }

    const isUsernameTaken = await isUserExistsByUsername(newUsername.toLowerCase());

    if (isUsernameTaken) {
      throw new functions.https.HttpsError('invalid-argument', 'The name specified ' +
        'is not available. Please try with a new one.');
    }

    try {
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
        user: { id: userAuth.uid },
      };
    } catch (error) {
      throw new functions.https.HttpsError('internal', 'There was an internal error ' +
        'while creating your account. Please try again or contact us if the problem persists".');
    }
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
