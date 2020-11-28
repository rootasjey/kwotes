import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';

const firestore = adminApp.firestore();

// Replace `user.stats.favourite` -> `user.stats.fav`
export const updateProp = functions
  .region('europe-west3')
  .https
  .onRequest(async (request, response) => {
    const snapshot = await firestore
      .collection('users')
      .get();

      if (snapshot.empty) {
        return;
      }

      for await (const doc of snapshot.docs) {
        const data = doc.data();
        const fav = data.stats.favourites || data.stats.fav;

        await doc.ref
          .update({
            'stats.fav': fav,
            'stats.favourites': adminApp.firestore.FieldValue.delete(),
          });
      }

      response.status(200).send('done');
  });

export const onFavAdded = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/favourites/{quoteId}')
  .onCreate(async (snapshot, context) => {
    const quoteData = snapshot.data();
    if (!quoteData) { return; }

    let quoteFav: number = quoteData.stats.fav ?? 0;

    if (!quoteData.stats.fav) { // TODO: Remove after some months
      quoteFav = quoteData.stats.likes ?? 0;
    }

    const user = await firestore
      .collection('users')
      .doc(context.params.userId)
      .get();

    const userData = user.data();

    if (userData) {
      let userFav: number = userData.stats.likes ?? 0;
      
      if (!userData.stats.fav) { // TODO: Remove after some months
        userFav = userData.stats.likes ?? 0;
      }

      await user.ref.update('stats.fav', userFav + 1);
    }
      
    return await snapshot.ref
      .update('stats.fav', quoteFav + 1);
  });

export const onFavDeleted = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/favourites/{quoteId}')
  .onDelete(async (snapshot, context) => {
    const quoteData = snapshot.data();
    if (!quoteData) { return; }

    let quoteFav: number = quoteData.stats.fav ?? 0;

    if (!quoteData.stats.fav) { // TODO: Remove after some months
      quoteFav = quoteData.stats.likes ?? 0;
    }

    const user = await firestore
      .collection('users')
      .doc(context.params.userId)
      .get();

    const userData = user.data();

    if (userData) {
      let userFav: number = userData.stats.fav ?? 0;
      
      if (!userData.stats.fav) { // TODO: Remove after some months
        userFav = userData.stats.likes ?? 0;
      }

      await user.ref
        .update('stats.fav', Math.max(0, userFav - 1));
    }

    return await snapshot.ref
      .update('stats.fav', Math.max(0, quoteFav - 1));
  });
