import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { checkUserIsSignedIn } from './utils';

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
      const authorSnapshot = await firestore
        .collection('authors')
        .limit(limit)
        .offset(offset)
        .get();

      if (authorSnapshot.empty || authorSnapshot.size === 0) {
        hasNext = false;
      }

      for await (const authorDoc of authorSnapshot.docs) {
        const authorData = authorDoc.data();
        if (!authorData) { continue; }

        // const created_at = authorData.createdAt || adminApp.firestore.FieldValue.serverTimestamp();
        // const updated_at = authorData.updatedAt || adminApp.firestore.FieldValue.serverTimestamp();
        // const born = authorData.born || {
        //   before_common_era: false,
        //   city: "",
        //   country: "",
        //   date: null,
        // };
        // const death = authorData.death || {
        //   before_common_era: false,
        //   city: "",
        //   country: "",
        //   date: null,
        // };
        // const urls = {
        //   ...{
        //     amazon: "",
        //     facebook: "",
        //     image: "",
        //     image_name: "",
        //     imdb: "",
        //     instagram: "",
        //     netflix: "",
        //     prime_video: "",
        //     tiktok: "",
        //     twitch: "",
        //     twitter: "",
        //     website: "",
        //     wikipedia: "",
        //     youtube: "",
        //   },
        //   ...authorData.urls,
        //   ...{
        //     // affiliate: adminApp.firestore.FieldValue.delete(),
        //     image: authorData.urls.image ?? "",
        //     image_name: authorData.urls.imageName ?? "",
        //     // imageName: adminApp.firestore.FieldValue.delete(),
        //     prime_video: authorData.urls.primeVideo ?? "",
        //     // primeVideo: adminApp.firestore.FieldValue.delete(),
        //   },
        // };

        const urls = authorData.urls;
        delete urls.primeVideo;
        delete urls.imageName;

        await authorDoc.ref.update({
          urls,
        });

        // // Update & Delete unecessaries fields.
        // await authorDoc.ref.update({
        //   birth: {
        //     before_common_era: born.beforeJC ?? false,
        //     city: born.city ?? "",
        //     country: born.country ?? "",
        //     date: born.date ?? null,
        //   },
        //   born: adminApp.firestore.FieldValue.delete(),
        //   created_at,
        //   createdAt: adminApp.firestore.FieldValue.delete(),
        //   death: {
        //     before_common_era: death.beforeJC ?? false,
        //     city: death.city ?? "",
        //     country: death.country ?? "",
        //     date: death.date ?? null,
        //   },
        //   from_reference: authorData.fromReference || {
        //     id: "",
        //     name: "",
        //   },
        //   fromReference: adminApp.firestore.FieldValue.delete(),
        //   image: authorData.image || {
        //     credits: {
        //       before_common_era: false,
        //       company: "",
        //       date: null,
        //       location: "",
        //       name: "",
        //       artist: "",
        //       url: "",
        //     },
        //   },
        //   is_fictional: authorData.isFictional ?? false,
        //   isFictional: adminApp.firestore.FieldValue.delete(),
        //   job_localized: authorData.jobLang || {},
        //   jobLang: adminApp.firestore.FieldValue.delete(),
        //   random: adminApp.firestore.FieldValue.delete(),
        //   region: adminApp.firestore.FieldValue.delete(),
        //   summary_localized: authorData.summaryLang || {},
        //   summaryLang: adminApp.firestore.FieldValue.delete(),
        //   updated_at,
        //   updatedAt: adminApp.firestore.FieldValue.delete(),
        //   urls,
        // });

        updatedCount++;
      }

      currIteration++;
      offset += authorSnapshot.size;
      totalCount += authorSnapshot.size;
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
 * Delete target authors from the database.
 */
export const deleteAuthors = functions
  .region('europe-west3')
  .https
  .onCall(async (params, context) => {
    const userAuth = context.auth;
    const { authorIds, idToken } = params;

    if (!authorIds) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Missing [authorIds] argument (array of strings). 
        The function must be called with [authorIds]
        representing the authors to delete.`,
      );
    }

    if (!Array.isArray(authorIds)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The [authorIds] argument you provided is not an array, but a ${typeof authorIds}. 
        Please provid a valid array of strings.`,
      );
    }

    if (authorIds.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The [authorIds] argument is an empty array. 
        Please provid an array containing valid strings.`,
      );
    }

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    await checkUserIsSignedIn(context, idToken);

    const userDoc = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .get();

    const userData = userDoc.data();

    if (!userDoc.exists || !userData) {
      throw new functions.https.HttpsError(
        'not-found',
        `You caught a ghost. This user doesn't seem to exist.,`
      );
    }

    const userRights = userData.rights;
    const manageAuthorRight = userRights['user:manageauthor'];

    if (!manageAuthorRight) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the right to perform this action.,`
      );
    }

    const payloadArray = Array<any>();

    for await (const authorId of authorIds) {
      const authorDoc = await firestore
        .collection('authors')
        .doc(authorId)
        .get();

      const authorData = authorDoc.data();

      if (!authorDoc.exists || !authorData) {
        throw new functions.https.HttpsError(
          'data-loss',
          `The document (author) [${authorId}] doesn't exist. 
          It may have been deleted.`,
        );
      }

      await authorDoc.ref.delete();

      const payload: Record<string, any> = {
        success: true,
        author: {
          id: authorId,
        },
      };

      payloadArray.push(payload);
    }

    return {
      success: true,
      entries: payloadArray,
    };
  });
