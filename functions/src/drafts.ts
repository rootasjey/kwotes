import * as functions from 'firebase-functions';
import { sanitizeAuthor, sanitizeLang, sanitizeReference, sanitizeTopics } from './utils';
import { deepEqual } from 'fast-equals';
import { adminApp } from './adminApp';

const firestore = adminApp.firestore();

export const configUpdateCollection = functions
  .region('europe-west3')
  .https
  .onRequest(async ({ }, resp) => {
    const limit = 200;
    let offset = 0;
    let hasNext = true;

    const maxIterations = 100;
    let currIteration = 0;
    let totalCount = 0;
    let updatedCount = 0;
    const missingDataCount = 0;

    while (hasNext && currIteration < maxIterations) {
      const draftSnap = await firestore
        .collection('drafts')
        .limit(limit)
        .offset(offset)
        .get();

      if (draftSnap.empty || draftSnap.size === 0) {
        hasNext = false;
      }

      for await (const draftDoc of draftSnap.docs) {
        const draftData = draftDoc.data();
        if (!draftData) { continue; }

        const validation = draftData.validation ?? {
          comment: {
            name: "",
            moderator_id: "",
            updated_at: null,
          },
          status: "",
          updated_at: null,
        };
        validation.comment = {
          name: draftData.validation?.comment?.name ?? "",
          moderator_id: draftData.validation?.comment?.moderator_id ?? "",
          updated_at: draftData.validation?.comment?.updated_at ?? null,
        }

        await draftDoc.ref.update({
          validation,
        });
        updatedCount++;
      }

      // const draftSnap2 = await firestore
      //   .collection('tempquotes')
      //   .limit(limit)
      //   .offset(offset)
      //   .get();

      // if (draftSnap.empty || draftSnap.size === 0) {
      //   hasNext = false;
      // }

      // for await (const draftDoc of draftSnap.docs) {
      //   const draftData = draftDoc.data();
      //   if (!draftData) { continue; }

      //   const authorDraft = draftData.author ?? getEmptyAuthor();
      //   const referenceDraft = draftData.reference ?? getEmptyReference();

      //   const birth = authorDraft.birth;
      //   const born = authorDraft.born;
      //   const death = authorDraft.death;

      //   const authorImage = authorDraft.image ?? {credits: {}};
      //   const authorImageCredits = authorImage?.credits ?? {};
      //   const authorImageDate =
      //     typeof authorImageCredits.date === "number"
      //       ? adminApp.firestore.Timestamp.fromMillis(authorImageCredits.date)
      //       : authorImageCredits.date ?? null;

      //   authorImage.credits = {
      //     before_common_era: authorImageCredits?.before_common_era ?? false,
      //     company: authorImageCredits?.company ?? "",
      //     date: authorImageDate,
      //     location: authorImageCredits?.location ?? "",
      //     name: authorImageCredits?.name ?? "",
      //     artist: authorImageCredits?.artist ?? "",
      //     url: authorImageCredits?.url ?? "",
      //   }

      //   const authorUrls = sanitizeUrls(authorDraft.urls);

      //   const referenceImage = referenceDraft.image ?? {credits: {}};
      //   const referenceImageCredits = referenceImage?.credits ?? {};
      //   const referenceImageDate =
      //     typeof referenceImageCredits.date === "number"
      //       ? adminApp.firestore.Timestamp.fromMillis(referenceImageCredits.date)
      //       : referenceImageCredits.date ?? null;

      //   referenceImage.credits = {
      //     before_common_era: referenceImageCredits?.before_common_era ?? false,
      //     company: referenceImageCredits?.company ?? "",
      //     date: referenceImageDate,
      //     location: referenceImageCredits?.location ?? "",
      //     name: referenceImageCredits?.name ?? "",
      //     artist: referenceImageCredits?.artist ?? "",
      //     url: referenceImageCredits?.url ?? "",
      //   }

      //   const referenceUrls = sanitizeUrls(referenceDraft.urls);

      //   await firestore.collection('drafts').doc(draftDoc.id).set({
      //     author: {
      //       birth: {
      //         before_common_era: birth?.before_common_era ?? born?.beforeJC ?? false,
      //         city: birth?.city ?? born?.city ?? "",
      //         country: birth?.country ?? born?.country ?? "",
      //         date: birth?.date ?? born?.date ?? null,
      //       },
      //       death: {
      //         before_common_era: death?.before_common_era ?? death?.beforeJC ?? false,
      //         city: death?.city ?? "",
      //         country: death?.country ?? "",
      //         date: death?.date ?? null,
      //       },
      //       from_reference: {
      //         id: authorDraft.from_reference?.id ?? authorDraft.fromReference?.id ?? "",
      //         name: authorDraft.from_reference?.name ?? authorDraft.fromReference?.name ?? "",
      //       },
      //       id: authorDraft?.id ?? "",
      //       image: authorImage ?? {
      //         credits: {
      //           before_common_era: false,
      //           company: "",
      //           date: null,
      //           location: "",
      //           name: "",
      //           artist: "",
      //           url: "",
      //         },
      //       },
      //       is_fictional: authorDraft.is_fictional ?? authorDraft.isFictional ?? false,
      //       job: authorDraft.job,
      //       name: authorDraft.name,
      //       summary: authorDraft.summary,
      //       urls: authorUrls,
      //     },
      //     created_at: draftData.created_at ?? draftData.createdAt,
      //     language: draftData.language ?? draftData.lang ?? "en",
      //     name: draftData.name,
      //     reference: {
      //       id: referenceDraft?.id ?? "",
      //       image: referenceImage ?? {
      //         credits: {
      //           before_common_era: false,
      //           company: "",
      //           date: null,
      //           location: "",
      //           name: "",
      //           artist: "",
      //           url: "",
      //         },
      //       },
      //       language: referenceDraft.language ?? referenceDraft.lang ?? "en",
      //       name: referenceDraft.name,
      //       release: {
      //         original: referenceDraft.release?.release ?? referenceDraft.release?.original ?? null,
      //         before_common_era: referenceDraft?.release?.before_common_era ?? referenceDraft?.release?.beforeJC ?? false,
      //       },
      //       summary: referenceDraft.summary,
      //       urls: referenceUrls,
      //     },
      //     metrics: draftData.metrics ?? draftData.stats ?? {
      //       likes: 0,
      //       shares: 0,
      //     },
      //     topics: draftData.topics,
      //     updated_at: draftData.updated_at ?? draftData.updatedAt,
      //     user: draftData.user,
      //     validation: {
      //       comment: draftData.validation?.comment ?? {
      //         name: draftData.validation?.comment?.name ?? "",
      //         moderator_id: draftData.validation?.comment?.moderator_id ?? "",
      //         updated_at: draftData.validation?.comment?.updated_at ?? null,
      //       },
      //       status: draftData.validation?.status ?? "",
      //       updated_at: draftData.validation?.updated_at ?? draftData.validation?.updatedAt ?? null,
      //     },
      //   });

      //   updatedCount++;
      // }

      currIteration++;
      offset += draftSnap.size;
      totalCount += draftSnap.size;
      functions.logger.info(`offset: ${offset} | currIteration: ${currIteration} | totalCount: ${totalCount}.`);
    }

    resp.send({
      'stopped at (offset)': offset,
      'iterations done': `${currIteration}/${maxIterations}`,
      'Docs counted': totalCount,
      'Docs updated:': updatedCount,
      'Docs with missing data:': missingDataCount,
    });
  });

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
