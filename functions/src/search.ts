import * as functions from 'firebase-functions';
import algolia from 'algoliasearch';

const env = functions.config();

const client = algolia(env.algolia.appid, env.algolia.apikey);
const quotesIndex = client.initIndex('quotes');

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
    const data = snapshot.after.data();
    const objectID = snapshot.after.id;

    return quotesIndex.saveObject({
      objectID,
      ...data,
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

