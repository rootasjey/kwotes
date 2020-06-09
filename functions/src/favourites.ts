import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const firestore = admin.firestore();

export const onFavAdded = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/favourites/{quoteId}')
  .onCreate(async (snapshot, context) => {
    const quoteSnap = await firestore
      .collection('quotes')
      .doc(snapshot.id)
      .get();

    if (!quoteSnap.exists) { return; }

    const data = quoteSnap.data();
    if (!data) { return; }

    const favCount: number = data.stats.likes;
    return await quoteSnap.ref
      .update({
        'stats.likes': favCount + 1,
      });
  });

export const onFavDeleted = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/favourites/{quoteId}')
  .onDelete(async (snapshot, context) => {
    const quoteSnap = await firestore
      .collection('quotes')
      .doc(snapshot.id)
      .get();

    if (!quoteSnap.exists) { return; }

    const data = quoteSnap.data();
    if (!data) { return; }

    const favCount: number = data.stats.likes;
    if (favCount === 0) { return; }

    return await quoteSnap.ref
      .update({
        'stats.likes': favCount - 1,
      });
  });
