import * as functions from 'firebase-functions';
import { sanitizeAuthor, sanitizeLang, sanitizeReference, sanitizeTopics } from './utils';
import { deepEqual } from 'fast-equals';
import { adminApp } from './adminApp';

/**
 * Triggered when a new draft quote is created (and submitted for validation).
 * Checks all parameters and deep nested properties.
 * @param snapshot - The document snapshot.
 */
export const onCreate = functions
  .region('europe-west3')
  .firestore
  .document('drafts/{draftId}')
  .onCreate(async (snapshot) => {
    const quoteData = snapshot.data();

    return snapshot.ref.update({
      author: sanitizeAuthor(quoteData.author),
      created_at: adminApp.firestore.Timestamp.now(),
      language: sanitizeLang(quoteData.language),
      reference: sanitizeReference(quoteData.reference),
      topics: sanitizeTopics(quoteData.topics),
      user: {
        id: quoteData.user.id
      },
      validation: {
        status: "",
        comment: {
          name: "",
          moderator_id: "",
          updated_at: adminApp.firestore.Timestamp.now(),
        },
        updated_at: adminApp.firestore.Timestamp.now(),
      },
      updated_at: adminApp.firestore.Timestamp.now(),
    });
  })

export const onCreateUserDraft = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/drafts/{draftId}')
  .onCreate(async (snapshot) => {
    return snapshot.ref.update({
      created_at: adminApp.firestore.Timestamp.now(),
      updated_at: adminApp.firestore.Timestamp.now(),
    });
  })

export const onUpdateUserDraft = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/drafts/{draftId}')
  .onUpdate(async (snapshot) => {
    if (!snapshot.after.exists) { return; }
    if (snapshot.after.isEqual(snapshot.before)) {
      functions.logger.info('(1) Draft quote unchanged. Exited at snapshot.after.isEqual.');
      return;
    }

    const beforeData = snapshot.before.data();
    const afterData = snapshot.after.data();

    if (areDrafsEqual(afterData, beforeData)) {
      functions.logger.info('(2) Draft unchanged. Exited at areDrafsEqual.');
      return;
    }

    return snapshot.after.ref.update({
      // author: sanitizeAuthor(afterData.author),
      // reference: sanitizeReference(afterData.reference),
      // topics: sanitizeTopics(afterData.topics),
      updated_at: adminApp.firestore.Timestamp.now(),
    });
  })

/**
 * Triggered when a draft quote is updated (and submitted for validation).
 * Checks all parameters and deep nested properties.
 * @param snapshot - The document snapshot.
 */
export const onUpdate = functions
  .region('europe-west3')
  .firestore
  .document('drafts/{draftId}')
  .onUpdate(async (snapshot) => {
    if (!snapshot.after.exists) { return; }
    if (snapshot.after.isEqual(snapshot.before)) { 
      functions.logger.info('(1) Draft unchanged. Exited at snapshot.after.isEqual.');
      return;
    }

    const beforeData = snapshot.before.data();
    const afterData = snapshot.after.data();

    if (areDrafsEqual(afterData, beforeData)) { 
      functions.logger.info('(2) Draft unchanged. Exited at areDrafsEqual.');
      return;
    }

    return snapshot.after.ref.update({
      author: sanitizeAuthor(afterData.author),
      reference: sanitizeReference(afterData.reference),
      topics: sanitizeTopics(afterData.topics),
      updated_at: adminApp.firestore.Timestamp.now(),
      validation: {
        status: afterData.validation?.status ?? "",
        comment: {
          name: afterData.validation?.comment.name ?? "",
          moderator_id: afterData.validation?.comment?.moderator_id ?? "",
          updated_at: afterData.validation?.comment?.updated_at ?? adminApp.firestore.Timestamp.now(),
        },
        updated_at: afterData.validation?.updated_at ?? adminApp.firestore.Timestamp.now(),
      }
    });
  });

/**
 * Compares two draft data and returns true if they are equal.
 * @param before Draft data before update.
 * @param after Draft data after update.
 * @returns Return true if the data are equal.
 */
function areDrafsEqual(
  before: FirebaseFirestore.DocumentData, 
  after: FirebaseFirestore.DocumentData) {
  functions.logger.info(`
  deepEqual(before.author, after.author): ${deepEqual(before.author, after.author)} | 
  before.language === after.language: ${before.language === after.language} | 
  deepEqual(before.metrics, after.metrics): ${deepEqual(before.metrics, after.metrics)} | 
  deepEqual(before.reference, after.reference): ${deepEqual(before.reference, after.reference)} | 
  deepEqual(before.topics, after.topics): ${deepEqual(before.topics, after.topics)}`
  );
  return (
    deepEqual(before.author, after.author)
    && before.language === after.language
    && deepEqual(before.reference, after.reference)
    && deepEqual(before.topics, after.topics)
    && deepEqual(before.user, after.user)
    && deepEqual(before.validation, after.validation)
  )
}
