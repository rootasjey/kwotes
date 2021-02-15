import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { checkUserIsSignedIn } from './utils';

const firestore = adminApp.firestore();

/**
 * Delete target authors from the database.
 */
export const deleteAuthors = functions
  .region('europe-west3')
  .https
  .onCall(async (params, context) => {
    const userAuth = context.auth;
    const { authorIds, idToken } = params;

    if (!authorIds) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Missing [authorIds] argument (array of strings). 
        The function must be called with [authorIds]
        representing the authors to delete.`,
      );
    }

    if (!Array.isArray(authorIds)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The [authorIds] argument you provided is not an array, but a ${typeof authorIds}. 
        Please provid a valid array of strings.`,
      );
    }

    if (authorIds.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The [authorIds] argument is an empty array. 
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
    const manageAuthorRight = userRights['user:manageauthor'];

    if (!manageAuthorRight) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the right to perform this action.,`
      );
    }

    const payloadArray = Array<any>();

    for await (const authorId of authorIds) {
      const authorDoc = await firestore
        .collection('authors')
        .doc(authorId)
        .get();

      const authorData = authorDoc.data();

      if (!authorDoc.exists || !authorData) {
        throw new functions.https.HttpsError(
          'data-loss',
          `The document (author) [${authorId}] doesn't exist. 
          It may have been deleted.`,
        );
      }

      await authorDoc.ref.delete();

      const payload: Record<string, any> = {
        success: true,
        author: {
          id: authorId,
        },
      };

      payloadArray.push(payload);
    }

    return {
      success: true,
      entries: payloadArray,
    };
  });
