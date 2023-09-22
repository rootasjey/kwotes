import * as functions from 'firebase-functions';
import algolia from 'algoliasearch';

const env = functions.config();

const client = algolia(env.algolia.appid, env.algolia.apikey);
const authorsIndex = client.initIndex('authors');
const quotesIndex = client.initIndex('quotes');
const referencesIndex = client.initIndex('references');

// Authors index
// ------------
export const onIndexAuthor = functions
  .region('europe-west3')
  .firestore
  .document('authors/{authorId}')
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    return authorsIndex.saveObject({
      objectID,
      ...data,
    })
  });

export const onReIndexAuthor = functions
  .region('europe-west3')
  .firestore
  .document('authors/{authorId}')
  .onUpdate(async (snapshot) => {
    const data = snapshot.after.data();
    const objectID = snapshot.after.id;

    return authorsIndex.saveObject({
      objectID,
      ...data,
    })
  });

export const onUnIndexAuthor = functions
  .region('europe-west3')
  .firestore
  .document('authors/{authorId}')
  .onDelete(async (snapshot) => {
    const objectID = snapshot.id;
    return authorsIndex.deleteObject(objectID);
  });

// Quotes index
// ------------
export const onIndexQuote = functions
  .region('europe-west3')
  .firestore
  .document('quotes/{quoteId}')
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    return quotesIndex.saveObject({
      objectID,
      ...data,
    })
  });

export const onReIndexQuote = functions
  .region('europe-west3')
  .firestore
  .document('quotes/{quoteId}')
  .onUpdate(async (snapshot) => {
    const beforeData = snapshot.before.data();
    const afterData = snapshot.after.data();
    const objectID = snapshot.after.id;

    // Prevent update index on stats changes
    const beforeLikes: number = beforeData.likes
      ?? beforeData.stats?.likes
      ?? beforeData.metrics?.likes
      ?? 0;

    const afterLikes: number = afterData.likes
      ?? afterData.stats?.likes
      ?? afterData.metrics?.likes
      ?? 0;

    const beforeShares: number = beforeData.shares
      ?? beforeData.stats?.shares
      ?? beforeData.metrics?.shares
      ?? 0;

    const afterShares: number = afterData.shares
      ?? afterData.stats?.shares
      ?? afterData.metrics?.shares
      ?? 0;

    if ((beforeLikes !== afterLikes) || (beforeShares !== afterShares)) {
      return;
    }

    return quotesIndex.saveObject({
      objectID,
      ...afterData,
    })
  });

export const onUnIndexQuote = functions
  .region('europe-west3')
  .firestore
  .document('quotes/{quoteId}')
  .onDelete(async (snapshot) => {
    const objectID = snapshot.id;
    return quotesIndex.deleteObject(objectID);
  });

// References index
// ----------------
export const onIndexReference = functions
  .region('europe-west3')
  .firestore
  .document('references/{referenceId}')
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    return referencesIndex.saveObject({
      objectID,
      ...data,
    })
  });

export const onReIndexReference = functions
  .region('europe-west3')
  .firestore
  .document('references/{referenceId}')
  .onUpdate(async (snapshot) => {
    const data = snapshot.after.data();
    const objectID = snapshot.after.id;

    return referencesIndex.saveObject({
      objectID,
      ...data,
    })
  });

export const onUnIndexReference = functions
  .region('europe-west3')
  .firestore
  .document('references/{referenceId}')
  .onDelete(async (snapshot) => {
    const objectID = snapshot.id;
    return referencesIndex.deleteObject(objectID);
  });
