import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';

const firestore = adminApp.firestore();

/**
 * If [author.name] is edited,
 * update all quotes referencing this author.
 * Specifically [quote.author.name] property.
 */
export const onUpdateAuthor = functions
  .region('europe-west3')
  .firestore
  .document('authors/{authorId}')
  .onUpdate(async (snapshot) => {
    const beforeData = snapshot.before.data();
    const afterData = snapshot.after.data();
    const authorId = snapshot.after.id;

    const beforeName: string = beforeData.name;
    const afterName: string = afterData.name;

    if (beforeName === afterName) {
      return;
    }

    const allQuotesWithAuthor = await firestore
      .collection('quotes')
      .where('author.id', '==', authorId)
      .get();

    if (allQuotesWithAuthor.empty) {
      return;
    }

    for await (const quoteDoc of allQuotesWithAuthor.docs) {
      await quoteDoc.ref.update(
        'author.name', 
        afterName,
      );
    }

    return true;
  });

/**
 * If [reference.name] is edited, 
 * update all quotes referencing this reference
 * Specifically the [quote.mainReference.name] property.
 */
export const onUpdateReference = functions
  .region('europe-west3')
  .firestore
  .document('references/{referenceId}')
  .onUpdate(async (snapshot) => {
    const beforeData = snapshot.before.data();
    const afterData = snapshot.after.data();
    const referenceId = snapshot.after.id;

    const beforeName: string = beforeData.name;
    const afterName: string = afterData.name;

    if (beforeName === afterName) {
      return;
    }

    let allQuotesWithReference = await firestore
      .collection('quotes')
      .where('reference.id', '==', referenceId)
      .get();

    if (allQuotesWithReference.empty) {
      allQuotesWithReference = await firestore
        .collection('quotes')
        .where('mainReference.id', '==', referenceId)
        .get();
    }

    if (allQuotesWithReference.empty) {
      return;
    }

    for await (const quoteDoc of allQuotesWithReference.docs) {
      await quoteDoc.ref.update({
        mainReference: {
          name: afterName,
          id: referenceId,
        },
        reference: { // new prop. to replace [mainReference]
          name: afterName,
          id: referenceId,
        },
      });
    }

    return true;
  });
