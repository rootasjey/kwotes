import * as functions from 'firebase-functions';

import { adminApp } from './adminApp';

const firestore = adminApp.firestore();

/**
 * Cloud function to call when signing in with an existing user account.
 * This function will simply add necessaries properties values to the user's account.
 */
export const activateDevProgram = functions
  .region('europe-west3')
  .https
  .onCall(async (data, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    try {
      const userSnapshot = await firestore
        .collection('users')
        .doc(userAuth.uid)
        .get();

      const userData = userSnapshot.data();

      if (!userSnapshot.exists || !userData) {
        throw new functions.https.HttpsError(
          'not-found',
          `The user [${userAuth.uid}] document doesn't exist. 
          It may occurs if your data has been lost or a bad internet connection. 
          Please try again later.`,
        );
      }

      await userSnapshot.ref
        .update({
          developer: {
            apps: {
              current: 0,
              limit: 5,
            },
            isProgramActive: true,
            payment: {
              isActive: false,
              plan: 'free',
              stripeId: '',
            }
          },
        });

      return {
        success: true,
        user: { 
          id: userAuth.uid, 
        },
      };

    } catch (error) {
      console.error(error);
      throw new functions.https.HttpsError(
        'internal', 
        `There was an internal error while creating your account. 
        Please try again or contact us if the problem persists.`,
      );
    }
  });

/**
 * Add a new app for the authenticated user.
 * Check user's apps limit.
 */
export const addApp = functions
  .region('europe-west3')
  .https
  .onCall(async (data: AddAppParams, context) => {
    const userAuth = context.auth;
    
    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    try {
      const userSnapshot = await firestore
        .collection('users')
        .doc(userAuth.uid)
        .get();

      const userData = userSnapshot.data();

      if (!userSnapshot.exists || !userData) {
        throw new functions.https.HttpsError(
          'not-found',
          `The user [${userAuth.uid}] document doesn't exist. 
          It may occurs if your data has been lost or a bad internet connection. 
          Please try again later.`,
        );
      }

      const currentAppsCount: number = userData.developer?.apps?.current ?? 0;
      const limitAppsCount: number = userData.developer?.apps?.limit ?? 5;

      if (currentAppsCount >= limitAppsCount) {
        throw new functions.https.HttpsError(
          'permission-denied',
          `You've reached your applications' limit number.`
        );
      }

      let { name, description } = data;

      if (!name) {
        name = `app-${userAuth.uid}-${Date.now()}`;
      }

      if (!description) {
        description = 'This is an awesome app!';
      }

      const hash1 = require("crypto")
        .createHash("md5")
        .update(Date.now().toString())
        .digest("base64");

      const hash2 = require("crypto")
        .createHash("md5")
        .update(Date.now().toString())
        .digest("base64");

      const appDoc = await firestore
        .collection('apps')
        .add({
          createdAt: adminApp.firestore.FieldValue.serverTimestamp(),
          keys: {
            primary: `${userAuth.uid},${hash1},k=1`,
            secondary: `${userAuth.uid},${hash2},k=2`,
          },
          cert: {
            active: false,
            deliveredAt: adminApp.firestore.FieldValue.serverTimestamp(),
            exp: adminApp.firestore.FieldValue.serverTimestamp(),
          },
          description,
          name,
          plan: 'free',
          rights: {
            'api:edituser': false,
            'api:manageauthor': false,
            'api:managequote': false,
            'api:managereference': false,
            'api:managequotidian': false,
            'api:proposequote': false,
            'api:readquote': true,
            'api:readuser': false,
            'api:validatequote': false,
          },
          stats: {
            calls: {
              allTime: 0,
              callsLimit: 1000,
            },
            usedBy: 0,
          },
          updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
          urls: {
            email: '',
            image: '',
            website: '',
            privacy: '',
          },
          user: {
            id: userAuth.uid,
          }
        });

      // Update apps count.
      const newCurrentAppsCount = Math.max(currentAppsCount + 1, 0);

      await firestore
        .collection('users')
        .doc(userAuth.uid)
        .update('developer.apps.current', newCurrentAppsCount);

      return {
        success: true,
        app: {
          description,
          id: appDoc.id,
          name,
          user: {
            id: userAuth.uid,
          },
        },
      };
      
    } catch (error) {
      console.error(error);
      throw new functions.https.HttpsError(
        'internal', 
        `There was an internal error while creating your new app. 
        Please try again or contact us if the problem persists".`,
      );
    }
  });

/**
 * Cloud function to call when an user wants to be removed from  
 * the dev program. This function will update properties values 
 * of the user's account, and mark the doc for deletion 
 * (defer delete due to sub-collections).
 */
export const deactivateDevProgram = functions
  .region('europe-west3')
  .https
  .onCall(async (data, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`
      );
    }

    try {
      const userSnapshot = await firestore
        .collection('users')
        .doc(userAuth.uid)
        .get();

      const userData = userSnapshot.data();

      if (!userSnapshot.exists || !userData) {
        throw new functions.https.HttpsError(
          'not-found',
          `The user [${userAuth.uid}] document doesn't exist. 
          It may occurs if your data has been lost or a bad internet connection. 
          Please try again later.`,
        );
      }

      const appsSnap = await firestore
        .collection('apps')
        .where('user.id', '==', userAuth.uid)
        .get();

      if (!appsSnap.empty) {
        for await (const appDoc of appsSnap.docs) {
          // Add a reference in the 'todelete' collection
          // in order to delete sub-collection documents.
          await firestore
            .collection('todelete')
            .doc(appDoc.id)
            .create({
              doc: {
                id: appDoc.id,
                conceptualType: 'dev app',
                dataType: 'document',
                hasChildren: true,
              },
              path: `apps/${appDoc.id}`,
              task: {
                createdAt: adminApp.firestore.FieldValue.serverTimestamp(),
                done: false,
                items: {
                  deleted: 0,
                  total: 0,
                },
                updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
              },
              user: {
                id: userAuth.uid,
              },
            });

          // Delete app doc.
          await appDoc.ref.delete();
        }
      }

      await userSnapshot.ref
        .update({
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
        });

      return {
        success: true,
        user: { id: userAuth.uid },
      };

    } catch (error) {
      console.error(error);
      throw new functions.https.HttpsError(
        'internal', 
        `There was an internal error while deactivating 
        your developer account. Please try again 
        or contact us if the problem persists".`,
      );
    }
  });

/**
 * Delete a user's app.
 */
export const deleteApp = functions
  .region('europe-west3')
  .https
  .onCall(async (data: DeleteAppParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    const { appId } = data;

    if (!appId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Tou must specify a [appId] argument 
        which has a type of string and represents the app you want to delete.`,
      )
    }

    try {
      // Add a reference in the 'todelete' collection
      // in order to delete sub-collection documents.
      await firestore
        .collection('todelete')
        .doc(appId)
        .create({
          doc: {
            id: appId,
            conceptualType: 'dev app',
            dataType: 'document',
            hasChildren: true,
          },
          path: `apps/${appId}`,
          task: {
            createdAt: adminApp.firestore.FieldValue.serverTimestamp(),
            done: false,
            items: {
              deleted: 0,
              total: 0,
            },
            updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
          },
          user: {
            id: userAuth.uid,
          },
        });

      // Delete app doc.
      await firestore
        .collection('apps')
        .doc(appId)
        .delete();

      // Update apps count.
      const docUser = await firestore
        .collection('users')
        .doc(userAuth.uid)
        .get();

      const userData = docUser.data();

      if (!userData) {
        throw new functions.https.HttpsError(
          'not-found',
          `The user [${userAuth.uid}] document doesn't exist. 
          It may occurs if your data has been lost or a bad internet connection. 
          Please try again later.`,
        );
      }

      let currentAppsCount: number = userData.developer?.apps?.current ?? 0;
      currentAppsCount = Math.max(currentAppsCount - 1, 0);

      await firestore
        .collection('users')
        .doc(userAuth.uid)
        .update('developer.apps.current', currentAppsCount);

      return {
        success: true,
        app: {
          id: appId,
          user: {
            id: userAuth.uid,
          },
        },
      };
    } catch (error) {
      console.error(error);
      throw new functions.https.HttpsError(
        'internal',
        `There was an internal error while deactivating 
        your developer account. Please try again 
        or contact us if the problem persists".`
      );
    }

  });

/**
 * Generate new keys for the specified app.
 * It can generate a new value for the primary key, secondary key or both.
 */
export const generateNewKeys = functions
  .region('europe-west3')
  .https
  .onCall(async (data: GenerateNewKeysParam, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    const { appId, resetPrimary, resetSecondary } = data;

    if (!appId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Tou must specify a [appId] argument 
        which has a type of string and represents the app you want to delete.`,
      )
    }

    try {
      const appSnap = await firestore
        .collection('apps')
        .doc(appId)
        .get();

      const appData = appSnap.data();

      if (!appData) {
        throw new functions.https.HttpsError(
          'not-found',
          `Sorry, but we didn't find the specified app's id [${appId}]. 
          Etheir it has been deleted or there may be a connection issue. 
          Please try again.`,
        );
      }

      const appUserId: string = appData.user.id;

      if (appUserId !== userAuth.uid) {
        throw new functions.https.HttpsError(
          'permission-denied',
          `You don't have the permission to update this app's data.`,
        );
      }

      const appUpdatePayload: any = {
        updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
      };

      if (resetPrimary) {
        const hash1 = require("crypto")
          .createHash("md5")
          .update(Date.now().toString())
          .digest("base64");

        appUpdatePayload.keys.primary = `${userAuth.uid},${hash1},k=1`;
      }
      
      if (resetSecondary) {
        const hash2 = require("crypto")
        .createHash("md5")
        .update(Date.now().toString())
        .digest("base64");
        
        appUpdatePayload.keys.secondary = `${userAuth.uid},${hash2},k=2`;
      }

      await appSnap.ref.update(appUpdatePayload);

      return {
        success: true,
        app: {
          id: appId,
          user: { 
            id: userAuth.uid, 
          },
        },
      };
    } catch (error) {
      console.error(error);
      throw new functions.https.HttpsError(
        'internal',
        `There was an internal error while deactivating 
        your developer account. Please try again 
        or contact us if the problem persists".`
      );
    }
  });

/**
 * Update the specified app's metadata.
 */
export const updateAppMetadata = functions
  .region('europe-west3')
  .https
  .onCall(async (data: UpdateAppMetadataParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`
      );
    }

    const { appId, name, description } = data;

    if (!appId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Tou must specify a [appId] argument 
        which has a type of string and represents the app you want to delete.`
      )
    }

    try {
      const appSnap = await firestore
        .collection('apps')
        .doc(appId)
        .get();

      const appData = appSnap.data();

      if (!appData) {
        throw new functions.https.HttpsError(
          'not-found',
          `Sorry, but we didn't find the specified app's id [${appId}]. 
          Etheir it has been deleted or there may be a connection issue. 
          Please try again.`
        );
      }

      const appUserId: string = appData.user.id;

      if (appUserId !== userAuth.uid) {
        throw new functions.https.HttpsError(
          'permission-denied',
          `You don't have the permission to update this app's data.`
        );
      }

      await appSnap.ref.update({
        name,
        description,
        updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        app: {
          id: appId,
          user: {
            id: userAuth.uid,
          },
        },
      };
    } catch (error) {
      console.error(error);
      throw new functions.https.HttpsError(
        'internal',
        `There was an internal error while deactivating 
        your developer account. Please try again 
        or contact us if the problem persists".`
      );
    }
  });

/**
 * Update the specified app's rights.
 */
export const updateAppRights = functions
  .region('europe-west3')
  .https
  .onCall(async (data: UpdateAppRightsParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`
      );
    }

    const { appId, rights } = data;

    if (!appId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Tou must specify a [appId] argument 
        which has a type of string and represents the app you want to delete.`
      )
    }

    try {
      const appSnap = await firestore
        .collection('apps')
        .doc(appId)
        .get();

      const appData = appSnap.data();

      if (!appData) {
        throw new functions.https.HttpsError(
          'not-found',
          `Sorry, but we didn't find the specified app's id [${appId}]. 
          Etheir it has been deleted or there may be a connection issue. 
          Please try again.`
        );
      }

      const appUserId: string = appData.user.id;

      if (appUserId !== userAuth.uid) {
        throw new functions.https.HttpsError(
          'permission-denied',
          `You don't have the permission to update this app's data.`
        );
      }

      await appSnap.ref.update({
        rights,
        updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        app: {
          id: appId,
          user: {
            id: userAuth.uid,
          },
        },
      };
    } catch (error) {
      console.error(error);
      throw new functions.https.HttpsError(
        'internal',
        `There was an internal error while deactivating 
        your developer account. Please try again 
        or contact us if the problem persists".`
      );
    }
  });
