import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { checkUserIsSignedIn } from './utils';

const firestore = adminApp.firestore();

export const configDeleteOldReference = functions
  .region('europe-west3')
  .https
  .onRequest(async ({}, resp) => {
    const limit = 200;
    let offset = 0;

    let hasNext = true;

    const maxIterations = 100;
    let currIteration = 0;
    let totalCount = 0;
    let updatedCount = 0;
    let missingDataCount = 0;

    while (hasNext && currIteration < maxIterations) {
      const quotesSnap = await firestore
        .collection('quotes')
        .limit(limit)
        .offset(offset)
        .get();

      if (quotesSnap.empty || quotesSnap.size === 0) {
        hasNext = false;
      }

      for await (const quoteDoc of quotesSnap.docs) {
        const quoteData = quoteDoc.data();
        if (!quoteData) { continue; }

        await quoteDoc.ref.update({
          random: adminApp.firestore.FieldValue.delete(),
          mainReference: adminApp.firestore.FieldValue.delete(),
        });

        updatedCount++;
      }

      currIteration++;
      offset += quotesSnap.size;
      totalCount += quotesSnap.size;
    }

    resp.send({
      'stopped at (offset)': offset,
      'iterations done': `${currIteration}/${maxIterations}`,
      'Docs counted': totalCount,
      'Docs updated:': updatedCount,
      'Docs with missing data:': missingDataCount,
    });
  });

/**
 * Delete a published quote 
 * with its associated author & reference if specified.
 * Update stats too.
 */
export const deleteQuotes = functions
  .region('europe-west3')
  .https
  .onCall(async (params, context) => {
    const userAuth = context.auth;
    const { quoteIds, idToken } = params;
    const deleteAuthor = params.deleteAuthor ?? false;
    const deleteReference = params.deleteReference ?? false;

    if (!quoteIds) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Missing [quoteIds] (array of strings) argument. 
        The function must be called with [quoteIds]
        representing the quotes to delete.`,
      );
    }

    if (!Array.isArray(quoteIds)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The [quoteIds] argument is not an array, but a ${typeof quoteIds}. 
        Please provid a valid array of strings.`,
      );
    }

    if (quoteIds.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The [quoteIds] argument is an empty array. 
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
    const manageQuoteRight = userRights['user:managequote'];

    if (!manageQuoteRight) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the right to perform this action.,`
      );
    }

    const payloadArray = Array<any>();

    for await (const quoteId of quoteIds) {
      const quoteDoc = await firestore
        .collection('quotes')
        .doc(quoteId)
        .get();

      const quoteData = quoteDoc.data();

      if (!quoteDoc.exists || !quoteData) {
        throw new functions.https.HttpsError(
          'data-loss',
          `The document (quote) [${quoteId}] doesn't exist. 
          It may have been deleted.`,
        );
      }

      const authorId: string = quoteData.author.id;
      const referenceId: string = quoteData.reference.id;

      await quoteDoc.ref.delete();

      const payload: Record<string, any> = {
        success: true,
        quote: {
          id: quoteId,
        },
      };

      if (deleteAuthor) {
        await deleteQuoteAuthor(authorId);
        payload.author = {
          id: authorId,
          deleted: deleteAuthor,
        };
      }

      if (deleteReference) {
        await deleteQuoteReference(referenceId);
        payload.reference = {
          id: referenceId,
          deleted: deleteReference,
        };
      }

      payloadArray.push(payload);      
    }

    return {
      success: true,
      entries: payloadArray,
    };
  });

/**
 * Delete the author and update stats.
 * @param authorId - Author's id to delete.
 */
async function deleteQuoteAuthor(authorId: string) {
  const authorDoc = await firestore
    .collection('authors')
    .doc(authorId)
    .get();

  if (!authorDoc.exists) {
    return;
  }

  await authorDoc.ref.delete();
}

/**
 * Delete the specified reference and update stats.
 * @param referenceId - Reference's id to delete.
 */
async function deleteQuoteReference(referenceId: string) {
  const referenceDoc = await firestore
    .collection('references')
    .doc(referenceId)
    .get();
    
  const referenceData = referenceDoc.data();

  if (!referenceDoc.exists || !referenceData) {
    return;
  }

  await referenceDoc.ref.delete();
}
