import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';

const firestore = adminApp.firestore();

/**
 * Add quote's id to the randoms collection when a quote is created.
 * Triggered when a quote is created.
 */
export const onCreateQuote = functions
  .region('europe-west3')
  .firestore
  .document('quotes/{quoteId}')
  .onCreate(async (quoteSnapshot) => {
    const quoteData = quoteSnapshot.data();
    const language: string = quoteData.language;

    const randomSnapshot = await firestore
      .collection('randoms')
      .orderBy('index', 'desc')
      .where('language', '==', language)
      .limit(1)
      .get();

    if (randomSnapshot.empty || randomSnapshot.size === 0) {
      return;
    }

    const randomDocument = randomSnapshot.docs[0];
    const randomData = randomDocument.data();
    const index: number = randomData.index;
    const items: string[] = randomData.items;

    if (items.includes(quoteSnapshot.id)) {
      return;
    }

    const newItems = items.concat([quoteSnapshot.id]);

    if (newItems.length < 1000) {
      await randomDocument.ref.update({
        items: newItems,
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      });

      await quoteSnapshot.ref.update({
        random_group_id: `quotes_${language}_${index}`,
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      });

      return;
    }
    
    // Handle new document creation.
    const newIndex = index + 1;

    await firestore
      .collection('randoms')
      .doc(`quotes_${language}_${newIndex}`)
      .create({
        created_at: adminApp.firestore.FieldValue.serverTimestamp(),
        index: newIndex,
        items: [quoteSnapshot.id],
        language,
        type: "quotes",
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      });

    await quoteSnapshot.ref.update({
      random_group_id: `quotes_${language}_${newIndex}`,
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });
  });

/**
 * Remove quote's id from the randoms collection when a quote is deleted.
 * Triggered when a quote is deleted.
 */
export const onDeleteQuote = functions
  .region('europe-west3')
  .firestore
  .document('quotes/{quoteId}')
  .onDelete(async (quoteSnapshot) => {
    const quoteData = quoteSnapshot.data();
    const randomGroupId: string = quoteData.random_group_id;

    if (!randomGroupId) {
      return;
    }

    const randomSnapshot = await firestore
      .collection('randoms')
      .doc(randomGroupId)
      .get();

    const randomData = randomSnapshot.data();
    if (!randomSnapshot.exists || !randomData) {
      return;
    }

    const items: string[] = randomData.items;
    const newItems = items.filter((item) => item !== quoteSnapshot.id);

    return await randomSnapshot.ref.update({
      items: newItems,
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });
  })

/**
 * If a quote's language is updated, remove its id from the previous randoms collection
 * and add it to the new one.
 * Triggered when a quote is updated.
 * */
export const onUpdateQuote = functions
  .region('europe-west3')
  .firestore
  .document('quotes/{quoteId}')
  .onUpdate(async (quoteSnapshot) => {
    const beforeData = quoteSnapshot.before.data();
    const afterData = quoteSnapshot.after.data();

    if (!beforeData || !afterData) {
      return;
    }

    const beforeLanguage = beforeData.language;
    const afterLanguage = afterData.language;

    if (beforeLanguage === afterLanguage) {
      return;
    }

    const quoteId = quoteSnapshot.after.id;
    const oldRandomGroupId: string = beforeData.random_group_id;

    const oldRandomSnapshot = await firestore
      .collection('randoms')
      .doc(oldRandomGroupId)
      .get();

    const oldRandomData = oldRandomSnapshot.data();
    if (!oldRandomSnapshot.exists || !oldRandomData) {
      return;
    }

    const oldItems: string[] = oldRandomData.items;
    const oldFilteredItems = oldItems.filter((item) => item !== quoteId);

    // Remove the updated quote from existing random document.
    await oldRandomSnapshot.ref.update({
      items: oldFilteredItems,
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });

    // Add the updated quote to new random document.
    const newRandomSnapshot = await firestore
      .collection('randoms')
      .orderBy('index', 'desc')
      .where('language', '==', afterLanguage)
      .limit(1)
      .get();

    if (newRandomSnapshot.empty || newRandomSnapshot.size === 0) {
      await firestore
      .collection('randoms')
      .doc(`quotes_${afterLanguage}_0`)
      .create({
        created_at: adminApp.firestore.FieldValue.serverTimestamp(),
        index: 0,
        items: [quoteId],
        language: afterLanguage,
        type: "quotes",
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      });

      await quoteSnapshot.after.ref.update({
        random_group_id: `quotes_${afterLanguage}_0`,
      });
      return;
    }

    const newRandomDocument = newRandomSnapshot.docs[0];
    const newRandomData = newRandomDocument.data();
    const newItems = newRandomData.items;
    const newFilteredItems = newItems.concat([quoteId]);

    await newRandomDocument.ref.update({
      items: newFilteredItems,
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });

    await quoteSnapshot.after.ref.update({
      random_group_id: newRandomDocument.id,
      update_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });
  })
