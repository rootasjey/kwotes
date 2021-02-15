import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { checkUserIsSignedIn } from './utils';

const firestore = adminApp.firestore();

/**
 * Delete target references from the database.
 */
export const deleteReferences = functions
  .region('europe-west3')
  .https
  .onCall(async (params, context) => {
    const userAuth = context.auth;
    const { referenceIds, idToken } = params;

    if (!referenceIds) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Missing [referenceIds] argument (array of strings). 
        The function must be called with [referenceIds]
        representing the references to delete.`,
      );
    }

    if (!Array.isArray(referenceIds)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The [referenceIds] argument is not an array, but a ${typeof referenceIds}. 
        Please provid a valid array of strings.`,
      );
    }

    if (referenceIds.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The [referenceIds] argument is an empty array. 
        Please provid an array containing valid strings.`,
      );
    }

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    await checkUserIsSignedIn(context, idToken);

    const userDoc = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .get();

    const userData = userDoc.data();

    if (!userDoc.exists || !userData) {
      throw new functions.https.HttpsError(
        'not-found',
        `You caught a ghost. This user doesn't seem to exist.,`
      );
    }

    const userRights = userData.rights;
    const manageReferenceRight = userRights['user:managereference'];

    if (!manageReferenceRight) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the right to perform this action.,`
      );
    }

    const payloadArray = Array<any>();

    for await (const referenceId of referenceIds) {
      const referenceDoc = await firestore
        .collection('references')
        .doc(referenceId)
        .get();

      const referenceData = referenceDoc.data();

      if (!referenceDoc.exists || !referenceData) {
        throw new functions.https.HttpsError(
          'data-loss',
          `The document (reference) [${referenceId}] doesn't exist. 
          It may have been deleted.`,
        );
      }

      await referenceDoc.ref.delete();

      const payload: Record<string, any> = {
        success: true,
        reference: {
          id: referenceId,
        },
      };

      payloadArray.push(payload);
    }

    return {
      success: true,
      entries: payloadArray,
    };
  });
