import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { checkUserIsSignedIn } from './utils';

const firestore = adminApp.firestore();


/**
 * TODO: TEMPORARY: Delete after execution.
 * Update references stats.
 */
export const updateTopicsStats = functions
  .region('europe-west3')
  .https
  .onRequest(async (params, resp) => {
    const limit = 200;
    let offset = 0;

    let hasNext = true;

    const maxIterations = 100;
    let currIteration = 0;

    let totalCount = 0;

    while (hasNext && currIteration < maxIterations) {
      const snapshot = await firestore
        .collection('topics')
        .limit(limit)
        .offset(offset)
        .get();

      if (snapshot.empty || snapshot.size === 0) {
        hasNext = false;
      }

      totalCount += snapshot.size;

      currIteration++;
      offset += snapshot.size;
    }

    // Update stats
    await firestore
      .collection('stats')
      .doc('topics')
      .update({
        total: totalCount,
      });

    console.log('-------ref--------');
    console.log(`stopped at (offset): ${offset}`);
    console.log(`iterations done: ${currIteration}/${maxIterations}`);
    console.log(`Docs counted: ${totalCount}`);

    resp.send({
      'stopped at (offset)': offset,
      'iterations done': `${currIteration}/${maxIterations}`,
      'Docs counted': totalCount,
    });
  });

/**
 * TODO: TEMPORARY: Delete after execution.
 * Update references stats.
 */
export const updateUsersStats = functions
  .region('europe-west3')
  .https
  .onRequest(async (params, resp) => {
    const limit = 200;
    let offset = 0;

    let hasNext = true;

    const maxIterations = 100;
    let currIteration = 0;

    let totalCount = 0;

    while (hasNext && currIteration < maxIterations) {
      const snapshot = await firestore
        .collection('users')
        .limit(limit)
        .offset(offset)
        .get();

      if (snapshot.empty || snapshot.size === 0) {
        hasNext = false;
      }

      totalCount += snapshot.size;

      currIteration++;
      offset += snapshot.size;
    }

    // Update stats
    await firestore
      .collection('stats')
      .doc('users')
      .update({
        total: totalCount,
      });

    console.log('-------ref--------');
    console.log(`stopped at (offset): ${offset}`);
    console.log(`iterations done: ${currIteration}/${maxIterations}`);
    console.log(`Docs counted: ${totalCount}`);

    resp.send({
      'stopped at (offset)': offset,
      'iterations done': `${currIteration}/${maxIterations}`,
      'Docs counted': totalCount,
    });
  });

/**
 * TODO: TEMPORARY: Delete after execution.
 * Update temp quotes stats.
 */
export const updateTQStats = functions
  .region('europe-west3')
  .https
  .onRequest(async (params, resp) => {
    const limit = 200;
    let offset = 0;

    let hasNext = true;

    const maxIterations = 100;
    let currIteration = 0;

    let totalCount = 0;

    while (hasNext && currIteration < maxIterations) {
      const snapshot = await firestore
        .collection('tempquotes')
        .limit(limit)
        .offset(offset)
        .get();

      if (snapshot.empty || snapshot.size === 0) {
        hasNext = false;
      }

      totalCount += snapshot.size;

      currIteration++;
      offset += snapshot.size;
    }

    // Update stats
    await firestore
      .collection('stats')
      .doc('tempquotes')
      .update({
        total: totalCount,
      });

    console.log('-------ref--------');
    console.log(`stopped at (offset): ${offset}`);
    console.log(`iterations done: ${currIteration}/${maxIterations}`);
    console.log(`Docs counted: ${totalCount}`);

    resp.send({
      'stopped at (offset)': offset,
      'iterations done': `${currIteration}/${maxIterations}`,
      'Docs counted': totalCount,
    });
  });

/**
 * TODO: TEMPORARY: Delete after execution.
 * Update references stats.
 */
export const updateTQStatsEN = functions
  .region('europe-west3')
  .https
  .onRequest(async (params, resp) => {
    const limit = 200;
    let offset = 0;

    let hasNext = true;

    const maxIterations = 100;
    let currIteration = 0;

    let totalCount = 0;

    while (hasNext && currIteration < maxIterations) {
      const snapshot = await firestore
        .collection('tempquotes')
        .where('lang', '==', 'en')
        .limit(limit)
        .offset(offset)
        .get();

      if (snapshot.empty || snapshot.size === 0) {
        hasNext = false;
      }

      totalCount += snapshot.size;

      currIteration++;
      offset += snapshot.size;
    }

    // Update stats
    await firestore
      .collection('stats')
      .doc('tempquotes')
      .update({
        en: totalCount,
      });

    console.log('-------ref--------');
    console.log(`stopped at (offset): ${offset}`);
    console.log(`iterations done: ${currIteration}/${maxIterations}`);
    console.log(`Docs counted: ${totalCount}`);

    resp.send({
      'stopped at (offset)': offset,
      'iterations done': `${currIteration}/${maxIterations}`,
      'Docs counted': totalCount,
    });
  });

/**
 * TODO: TEMPORARY: Delete after execution.
 * Update references stats.
 */
export const updateTQStatsFR = functions
  .region('europe-west3')
  .https
  .onRequest(async (params, resp) => {
    const limit = 200;
    let offset = 0;

    let hasNext = true;

    const maxIterations = 100;
    let currIteration = 0;

    let totalCount = 0;

    while (hasNext && currIteration < maxIterations) {
      const snapshot = await firestore
        .collection('tempquotes')
        .where('lang', '==', 'fr')
        .limit(limit)
        .offset(offset)
        .get();

      if (snapshot.empty || snapshot.size === 0) {
        hasNext = false;
      }

      totalCount += snapshot.size;

      currIteration++;
      offset += snapshot.size;
    }

    // Update stats
    await firestore
      .collection('stats')
      .doc('tempquotes')
      .update({
        fr: totalCount,
      });

    console.log('-------ref--------');
    console.log(`stopped at (offset): ${offset}`);
    console.log(`iterations done: ${currIteration}/${maxIterations}`);
    console.log(`Docs counted: ${totalCount}`);

    resp.send({
      'stopped at (offset)': offset,
      'iterations done': `${currIteration}/${maxIterations}`,
      'Docs counted': totalCount,
    });
  });

/**
 * Delete a published quote 
 * with its associated author & reference if specified.
 * Update stats too.
 */
export const deleteQuote = functions
  .region('europe-west3')
  .https
  .onCall(async (data, context) => {
    const userAuth = context.auth;
    const { quoteId, idToken } = data;
    const deleteAuthor = data.deleteAuthor ?? false;
    const deleteReference = data.deleteReference ?? false;

    if (!quoteId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Missing [quoteId] argument. The function must be called with [quoteId]
        representing the quote's id to delete.`,
      );
    }

    // 0.Check authentication & rights.
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
        `You got a ghost. This user doesn't seem to exist.,`
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

    const quoteDoc = await firestore
      .collection('quotes')
      .doc(quoteId)
      .get();

    const quoteData = quoteDoc.data();

    if (!quoteDoc.exists || !quoteData) {
      throw new functions.https.HttpsError(
        'data-loss',
        `The document [${quoteId}] doesn't exist. It may have been deleted.`,
      );
    }

    const authorId: string = quoteData.author.id;
    const reference = quoteData.reference;
    const referenceId: string = reference ? reference.id : quoteData.mainReference.id;
    const quoteLang: string = quoteData.lang;

    await quoteDoc.ref.delete();

    // Update quotes stats.
    const quotesStats = await firestore
      .collection('stats')
      .doc('quotes')
      .get();

    const quotesStatsData = quotesStats.data();

    if (quotesStats.exists && quotesStatsData) {
      const total = quotesStatsData.total - 1;
      const payload: Record<string, number> = { total };

      if (quoteLang && quotesStatsData[quoteLang]) {
        payload[quoteLang] = quotesStatsData[quoteLang] - 1;
      }

      await quotesStats.ref.update(payload);
    }

    if (deleteAuthor) {
      await deleteQuoteAuthor(authorId);
    }

    if (deleteReference) {
      await deleteQuoteReference(referenceId)
    }

    return {
      success: true,
      author: {
        id: authorId,
        deleted: deleteAuthor,
      },
      quote: {
        id: quoteId,
      },
      reference: {
        id: referenceId,
        deleted: deleteReference,
      },
    }
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

  const authorsStats = await firestore
    .collection('stats')
    .doc('authors')
    .get();

  const authorsStatsData = authorsStats.data();

  if (authorsStats.exists && authorsStatsData) {
    await authorsStats.ref.update({
      total: authorsStatsData.total + 1,
    });
  }
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

  const referenceLang: string = referenceData.lang;

  await referenceDoc.ref.delete();

  const referencesStats = await firestore
    .collection('stats')
    .doc('references')
    .get();

  const referencesStatsData = referencesStats.data();

  if (referencesStats.exists && referencesStatsData) {
    const total = referencesStatsData.total - 1;
    const payload: Record<string, number> = { total };

    if (referenceLang && referencesStatsData[referenceLang]) {
      payload[referenceLang] = referencesStatsData[referenceLang] - 1;
    }

    await referencesStats.ref.update(payload);
  }
}
