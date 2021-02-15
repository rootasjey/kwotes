import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';

const firestore = adminApp.firestore();

/**
 * Unlink all quotes with the deleted author, if any.
 * Set the quote's [author.id], [author.name] 
 * properties to empty strings.
 */
export const onDeleteAuthor = functions
  .region('europe-west3')
  .firestore
  .document('authors/{authorId}')
  .onDelete(async (authorSnap) => {
    const authorId = authorSnap.id;

    const allQuotesWithDeletedAuthor = await firestore
      .collection('quotes')
      .where('author.id', '==', authorId)
      .get();

    if (allQuotesWithDeletedAuthor.empty) {
      return true;
    }

    for await (const quoteDoc of allQuotesWithDeletedAuthor.docs) {
      await quoteDoc.ref.update({
        author: {
          id: '',
          name: '',
        }
      }
      );
    }

    return true;
  });

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
      return true;
    }

    const allQuotesWithThisAuthor = await firestore
      .collection('quotes')
      .where('author.id', '==', authorId)
      .get();

    if (allQuotesWithThisAuthor.empty) {
      return true;
    }

    for await (const quoteDoc of allQuotesWithThisAuthor.docs) {
      await quoteDoc.ref.update(
        'author.name', 
        afterName,
      );
    }

    return true;
  });

/**
 * Unlink all quotes with the deleted reference, if any.
 * Set the quote's [reference.id], [reference.name] 
 * properties to empty strings.
 */
export const onDeleteReference = functions
  .region('europe-west3')
  .firestore
  .document('references/{referenceId}')
  .onDelete(async (referenceSnap) => {
    const referenceId = referenceSnap.id;

    const allQuotesWithDeletedReference = await firestore
      .collection('quotes')
      .where('reference.id', '==', referenceId)
      .get();

    if (allQuotesWithDeletedReference.empty) {
      return true;
    }

    for await (const quoteDoc of allQuotesWithDeletedReference.docs) {
      await quoteDoc.ref.update({
        reference: {
          id: '',
          name: '',
        }
      }
      );
    }

    return true;
  });

/**
 * If [reference.name] is edited, 
 * update all quotes referencing this reference
 * Specifically the [quote.reference.name] property.
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
      return true;
    }

    let allQuotesWithThisReference = await firestore
      .collection('quotes')
      .where('reference.id', '==', referenceId)
      .get();

    if (allQuotesWithThisReference.empty) {
      allQuotesWithThisReference = await firestore
        .collection('quotes')
        .where('reference.id', '==', referenceId)
        .get();
    }

    if (allQuotesWithThisReference.empty) {
      return true;
    }

    for await (const quoteDoc of allQuotesWithThisReference.docs) {
      await quoteDoc.ref.update({
        reference: {
          name: afterName,
          id: referenceId,
        },
      });
    }

    return true;
  });
