import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';

const firestore = adminApp.firestore();

export const onQuoteAdded = functions
  .region('europe-west3')
  .firestore
  .document('quotes/{quoteId}')
  .onCreate(async (snapshot) => {
    const quoteData = snapshot.data();
    if (!quoteData) { return; }

    const user = await firestore
      .collection('users')
      .doc(quoteData.user.id)
      .get();

    if (!user.exists) { return; }
    
    const userData = user.data();
    if (!userData) { return; }

    let userPub: number = userData.stats.published ?? 0;
    
    return await user.ref
      .update('stats.published', userPub + 1);
  });

export const onQuoteDeleted = functions
  .region('europe-west3')
  .firestore
  .document('quotes/{quoteId}')
  .onDelete(async (snapshot) => {
    const quoteData = snapshot.data();
    if (!quoteData) { return; }

    const user = await firestore
      .collection('users')
      .doc(quoteData.user.id)
      .get();

    if (!user.exists) { return; }

    const userData = user.data();
    if (!userData) { return; }

    let userPub: number = userData.stats.published ?? 0;
    
    return await user.ref
      .update('stats.published', Math.max(0, userPub - 1));
  });
