import * as functions from 'firebase-functions';

import { adminApp } from './adminApp';
import { checkUserIsSignedIn } from './utils';

const firebaseTools = require('firebase-tools');
const firestore = adminApp.firestore();

/**
 * Check if an email is available in the database.
 * @param email - Email to check.
 * @returns True if the email is available, false otherwise.
 * @throws HttpsError if the email is not valid.
 * @throws HttpsError if the email is not a string.
 * @throws HttpsError if the email is empty.
 */
export const checkEmailAvailability = functions
  .region('europe-west3')
  .https
  .onCall(async (data) => {
    const email: string = data.email;
    const isAvailable = await isEmailAvailable(email);

    return {
      email,
      isAvailable,
    };
  });

/**
 * Check if a username is available in the database.
 * @param username - Username to check.
 * @returns True if the username is available, false otherwise.
 * @throws HttpsError if the username is not valid.
 * @throws HttpsError if the username is not a string.
 * @throws HttpsError if the username is empty.
 */
export const checkUsernameAvailability = functions
  .region('europe-west3')
  .https
  .onCall(async (data) => {
    const username: string = data.username;
    const isAvailable: boolean = await isUsernameAvailable(username);

    return {
      username,
      isAvailable,
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
        `The function must be called with 3 string 
        arguments [username], [email] and [password].`,
      );
    }

    const { username, password, email } = data;
    const isUsernameOk: boolean = await isUsernameAvailable(username);
    const isEmailOk: boolean = await isEmailAvailable(email);

    if (!isUsernameOk) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid username.`,
      );
    }

    if (!isEmailOk) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid email.`,
      );
    }

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
      created_at: adminApp.firestore.Timestamp.now(),
      developer: {
        apps: {
          current: 0,
          limit: 5,
        },
        is_program_active: false,
        payment: {}
      },
      email: email,
      language: 'en',
      metrics: {
        drafts: 0,
        favourites: 0,
        lists: 0,
        notifications: {
          total: 0,
          unread: 0,
        },
        quotes: {
          proposed: 0,
          published: 0,
          submitted: 0,
        },
      },
      name: username,
      name_lower_case: username.toLowerCase(),
      rights: {
        'user:manage_data'      : false,
        'user:manage_authors'   : false,
        'user:manage_quotes'    : false,
        'user:manage_quotidians': false,
        'user:manage_references': false,
        'user:propose_quotes'   : true,
        'user:read_quotes'      : true,
        'user:validate_quotes'  : false,
      },
      settings: {
        notifications: {
          email: {
            drafts: true,
            quotidians: false,
          },
          push: {
            quotidians: true,
            drafts: true,
          }
        },
      },
      urls: {
        image:      '',
        twitter:    '',
        facebook:   '',
        instagram:  '',
        twitch:     '',
        website:    '',
        wikipedia:  '',
        youtube:    '',
      },
      uid: userRecord.uid,
    });

    return {
      message: "",
      success: true,
      user: {
        id: userRecord.uid, 
        email,
      },
    };
  });

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
        force: true,
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
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user (1).`,
      );
    }

    await checkUserIsSignedIn(context, idToken);
    const isFormatOk = validateEmailFormat(newEmail);

    if (!newEmail || !isFormatOk) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [newEmail] argument. 
        The value you specified is not in a correct email format.`,
      );
    }

    const isEmailTaken = await isUserExistsByEmail(newEmail);

    if (isEmailTaken) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The email specified is not available.
         Try specify a new one in the "newEmail" argument.`,
        );
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
      user: { id: userAuth.uid },
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
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    const { newUsername } = data;
    const isFormatOk = validateNameFormat(newUsername);

    if (!newUsername || !isFormatOk) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [newUsername].
         The value you specified is not in a correct format.`,
      );
    }

    const isUsernameTaken = await isUserExistsByUsername(newUsername.toLowerCase());

    if (isUsernameTaken) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The name specified is not available.
         Please try with a new one.`,
      );
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
        name_lower_case: newUsername.toLowerCase(),
      });

    return {
      success: true,
      user: { id: userAuth.uid },
    };
  });

/**
 * Checks if the provided data object contains the required keys and their values are of the correct types.
 *
 * @param {any} data - the data object to be checked
 * @return {boolean} true if the data object is valid, false otherwise
 */
function checkCreateAccountData(data: any) {
  if (Object.keys(data).length !== 3) {
    return false;
  }

  const keys = Object.keys(data);

  if (!keys.includes('username')
    || !keys.includes('email')
    || !keys.includes('password')) {
    return false;
  }

  if (typeof data['username'] !== 'string' ||
    typeof data['email'] !== 'string' ||
    typeof data['password'] !== 'string') {
    return false;
  }

  return true;
}

/**
 * Checks if the given email is available for use.
 *
 * @param {string} email - the email to check
 * @return {Promise<boolean>} whether the email is available
 */
async function isEmailAvailable(email: string) {
  if (typeof email !== 'string' || email.length === 0) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must be called with one (string)
         argument [email] which is the email to check.`,
    );
  }

  if (!validateEmailFormat(email)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must be called with a valid email address. ${email} is not in a correct format.`,
    );
  }

  const exists = await isUserExistsByEmail(email);
  const isAvailable = !exists;
  return isAvailable;
}

/**
 * Check if a user exists by their email.
 * 
 * @param {string} email - the email to check
 * @return {boolean} whether the user exists or not
 * @throws {functions.https.HttpsError} if the email is not in a correct format
 * @throws {functions.https.HttpsError} if the email is not available
 **/
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

  /**
 * Check if a user exists by their username in lowercase.
 *
 * @param {string} nameLowerCase - the lowercase username to check
 * @return {boolean} whether the user exists or not
 */
async function isUserExistsByUsername(nameLowerCase: string) {
  const nameSnapshot = await firestore
    .collection('users')
    .where('name_lower_case', '==', nameLowerCase)
    .limit(1)
    .get();

  if (nameSnapshot.empty) {
    return false;
  }

  return true;
}

  /**
 * Checks if the given username is available.
 *
 * @param {string} username - the username to check
 * @return {Promise<boolean>} whether the username is available
 */
async function isUsernameAvailable(username: string): Promise<boolean> {
  if (typeof username !== 'string' || username.length === 0) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must be called with one (string)
         argument "username" which is the username to check.`,
    );
  }

  if (!validateNameFormat(username)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must be called with a valid [username]
         with at least 3 alpha-numeric characters (underscore is allowed) (A-Z, 0-9, _).`,
    );
  }

  const usernameSnapshot = await firestore
    .collection('users')
    .where('name_lower_case', '==', username.toLowerCase())
    .limit(1)
    .get();

  return usernameSnapshot.empty;
}

/**
 * Validates the format of the email.
 *
 * @param {string} email - the email to be validated
 * @return {boolean} true if the email format is valid, false otherwise
 */
function validateEmailFormat(email: string) {
  const re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
}

/**
 * Validates the format of the given name string.
 *
 * @param {string} name - The name string to be validated
 * @return {boolean} Whether the name string has a valid format
 */
function validateNameFormat(name: string) {
  const re = /[a-zA-Z0-9_]{3,}/;
  const matches = re.exec(name);

  if (!matches) { return false; }
  if (matches.length < 1) { return false; }

  const firstMatch = matches[0];
  return firstMatch === name;
}

