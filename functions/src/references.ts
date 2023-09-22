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
      const referenceSnapshot = await firestore
        .collection('references')
        .limit(limit)
        .offset(offset)
        .get();

      if (referenceSnapshot.empty || referenceSnapshot.size === 0) {
        hasNext = false;
      }

      for await (const referenceDoc of referenceSnapshot.docs) {
        const referenceData = referenceDoc.data();
        if (!referenceData) { continue; }

        // const created_at = referenceData.createdAt || adminApp.firestore.FieldValue.serverTimestamp();
        // const updated_at = referenceData.updatedAt || adminApp.firestore.FieldValue.serverTimestamp();
        // const release = {
        //   original: referenceData.release?.release ?? referenceData.release?.original ?? null,
        //   before_common_era: referenceData.release?.beforeJC ?? false,
        //   // beforeJC: adminApp.firestore.FieldValue.delete(),
        //   // release: adminApp.firestore.FieldValue.delete(),
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
        //   ...referenceData.urls,
        //   ...{
        //     // affiliate: adminApp.firestore.FieldValue.delete(),
        //     image: referenceData.urls.image ?? "",
        //     image_name: referenceData.urls.imageName ?? "",
        //     // imageName: adminApp.firestore.FieldValue.delete(),
        //     prime_video: referenceData.urls.primeVideo ?? "",
        //     // primeVideo: adminApp.firestore.FieldValue.delete(),
        //   },
        // };

        const urls = referenceData.urls;
        delete urls.primeVideo;
        delete urls.imageName;

        await referenceDoc.ref.update({
          lang: adminApp.firestore.FieldValue.delete(),
          image: referenceData.image || {
            credits: {
              before_common_era: false,
              company: "",
              date: null,
              location: "",
              name: "",
              artist: "",
              url: "",
            },
          },
          urls,
        });

        // Update & Delete unecessaries fields.
        // await referenceDoc.ref.update({
        //   created_at,
        //   createdAt: adminApp.firestore.FieldValue.delete(),
        //   language: referenceData.lang ?? "en",
        //   linkedRefs: adminApp.firestore.FieldValue.delete(),
        //   random: adminApp.firestore.FieldValue.delete(),
        //   release,
        //   summary_localized: referenceData.summaryLang ?? {},
        //   summaryLang: adminApp.firestore.FieldValue.delete(),
        //   type_localized: referenceData.typeLang ?? {},
        //   typeLang: adminApp.firestore.FieldValue.delete(),
        //   updated_at,
        //   updatedAt: adminApp.firestore.FieldValue.delete(),
        //   urls,
        // });

        updatedCount++;
      }

      currIteration++;
      offset += referenceSnapshot.size;
      totalCount += referenceSnapshot.size;
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
 * Delete target references from the database.
 */
export const deleteReferences = functions
  .region('europe-west3')
  .https
  .onCall(async (params, context) => {
    const userAuth = context.auth;
    const { referenceIds, idToken } = params;

    if (!referenceIds) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Missing [referenceIds] argument (array of strings). 
        The function must be called with [referenceIds]
        representing the references to delete.`,
      );
    }

    if (!Array.isArray(referenceIds)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The [referenceIds] argument is not an array, but a ${typeof referenceIds}. 
        Please provid a valid array of strings.`,
      );
    }

    if (referenceIds.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The [referenceIds] argument is an empty array. 
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
    const manageReferenceRight = userRights['user:managereference'];

    if (!manageReferenceRight) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the right to perform this action.,`
      );
    }

    const payloadArray = Array<any>();

    for await (const referenceId of referenceIds) {
      const referenceDoc = await firestore
        .collection('references')
        .doc(referenceId)
        .get();

      const referenceData = referenceDoc.data();

      if (!referenceDoc.exists || !referenceData) {
        throw new functions.https.HttpsError(
          'data-loss',
          `The document (reference) [${referenceId}] doesn't exist. 
          It may have been deleted.`,
        );
      }

      await referenceDoc.ref.delete();

      const payload: Record<string, any> = {
        success: true,
        reference: {
          id: referenceId,
        },
      };

      payloadArray.push(payload);
    }

    return {
      success: true,
      entries: payloadArray,
    };
  });
