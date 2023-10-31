import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';

const firestore = adminApp.firestore();
const METRICS_COLLECTION_NAME = "metrics";

// -----
// Apps
// -----
export const onCreateApp = functions
  .region('europe-west3')
  .firestore
  .document('apps/{appId}')
  .onCreate(async (appSnap) => {
    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('apps')
      .get();

    const metricData = metricSnap.data();
    if (!metricSnap.exists || !metricData) {
      return false;
    }

    const total: number = metricData.total;
    await metricSnap.ref.update({
      total: total + 1,
    });

    // Update user's apps count.
    const appData = appSnap.data();

    const docUser = await firestore
    .collection('users')
    .doc(appData.user.id)
    .get();
    
    const userData = docUser.data();
    
    if (!docUser.exists || !userData) {
      return true;
    }
    
    let currentAppsCount: number = userData.developer?.apps?.current ?? 0;
    currentAppsCount = Math.max(currentAppsCount + 1, 0);

    await firestore
      .collection('users')
      .doc(appData.user.id)
      .update('developer.apps.current', currentAppsCount);

    return true;
  });

export const onDeleteApp = functions
  .region('europe-west3')
  .firestore
  .document('apps/{appId}')
  .onDelete(async (appSnap) => {
    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('apps')
      .get();

    const metricData = metricSnap.data();
    if (!metricSnap.exists || !metricData) {
      return false;
    }

    const total: number = metricData.total;
    await metricSnap.ref.update({
      total: Math.max(0, total - 1),
    });

    const appData = appSnap.data();
    if (!appData) {
      return true;
    }

    // Update user's apps count.
    const docUser = await firestore
      .collection('users')
      .doc(appData.user.id)
      .get();

    const userData = docUser.data();

    if (!docUser.exists || !userData) {
      return true;
    }

    let currentAppsCount: number = userData.developer?.apps?.current ?? 0;
    currentAppsCount = Math.max(currentAppsCount - 1, 0);

    await firestore
      .collection('users')
      .doc(appData.user.id)
      .update('developer.apps.current', currentAppsCount);

    return true;
  });

// ------
// Topics
// ------
export const onCreateTopic = functions
  .region('europe-west3')
  .firestore
  .document('topics/{topicId}')
  .onCreate(async () => {
    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('topics')
      .get();

    const metricData = metricSnap.data();
    if (!metricSnap.exists || !metricData) {
      return false;
    }

    const total: number = metricData.total;
    await metricSnap.ref.update({
      total: total + 1,
    });

    return true;
  });

export const onDeleteTopic = functions
  .region('europe-west3')
  .firestore
  .document('topics/{topicId}')
  .onDelete(async () => {
    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('topics')
      .get();

    const metricData = metricSnap.data();
    if (!metricSnap.exists || !metricData) {
      return false;
    }

    const total: number = metricData.total;
    await metricSnap.ref.update({
      total: Math.max(0, total - 1),
    });

    return true;
  });

// ------
// Users
// ------
export const onCreateUser = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}')
  .onCreate(async (userSnap) => {
    const userData = userSnap.data();
    const isDev: boolean = userData.developer?.is_active;

    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('users')
      .get();

    const metricData = metricSnap.data();
    if (!metricSnap.exists || !metricData) {
      return false;
    }

    const total: number = metricData.total + 1;
    const payload: Record<string, number> = { total };

    if (isDev) {
      payload.dev = metricData.dev + 1;
    }

    await metricSnap.ref.update(payload);
    return true;
  });

export const onUpdateUser = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}')
  .onUpdate(async (change) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    if (!beforeData || !afterData) {
      return;
    }

    const devBefore: boolean = beforeData.developer?.is_active ?? false;
    const devAfter: boolean = afterData.developer?.is_active ?? false;

    if (devAfter === devBefore) {
      return;
    }

    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('users')
      .get();

    const metricData = metricSnap.data();

    if (!metricSnap.exists || !metricData) {
      return false;
    }

    let dev: number = metricData.dev;

    // New dev account.
    if (devBefore === false && devAfter === true) {
      dev++;
    }

    // Closed dev account
    if (devBefore === true && devAfter === false) {
      dev--;
    }

    await metricSnap.ref.update({
      dev,
    });

    return true;
  });

export const onDeleteUser = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}')
  .onDelete(async (userSnap) => {
    const userData = userSnap.data();
    const wasDev: boolean = userData.developer?.is_active ?? false;

    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('users')
      .get();

    const metricData = metricSnap.data();
    if (!metricSnap.exists || !metricData) {
      return false;
    }

    const total: number = Math.max(0, metricData.total - 1);
    const payload: Record<string, number> = { total };

    if (wasDev) {
      payload.dev = Math.max(0, metricData.dev - 1);
    }

    await metricSnap.ref.update(payload);
    return true;
  });

// --------
// Authors
// --------
export const onCreateAuthor = functions
  .region('europe-west3')
  .firestore
  .document('authors/{authorId}')
  .onCreate(async () => {
    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('authors')
      .get();

    const metricData = metricSnap.data();
    if (!metricSnap.exists || !metricData) {
      return false;
    }

    const total: number = metricData.total;
    await metricSnap.ref.update({
      total: total + 1,
    });

    return true;
  });

export const onDeleteAuthor = functions
  .region('europe-west3')
  .firestore
  .document('authors/{authorId}')
  .onDelete(async () => {
    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('authors')
      .get();

    const metricData = metricSnap.data();
    if (!metricSnap.exists || !metricData) {
      return false;
    }

    const total: number = metricData.total;
    await metricSnap.ref.update({
      total: Math.max(0, total - 1),
    });

    return true;
  });

// ------
// Quotes
// ------
export const onCreateQuote = functions
  .region('europe-west3')
  .firestore
  .document('quotes/{quoteId}')
  .onCreate(async (quoteSnap) => {
    const quoteData = quoteSnap.data();
    const language: string = quoteData.language;

    const metricSnapshot = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('quotes')
      .get();

    const metricData = metricSnapshot.data();

    if (!metricSnapshot.exists || !metricData) {
      return false;
    }

    const total: number = metricData.total + 1;
    const payload: Record<string, number> = { total };

    if (language && metricData[language]) {
      payload[language] = metricData[language] + 1;
    }

    await metricSnapshot.ref.update(payload);

    // Update user's stats.
    const userSnap = await firestore
      .collection('users')
      .doc(quoteData.user.id)
      .get();

    const userData = userSnap.data();
    if (!userSnap.exists || !userData) { 
      return; 
    }

    const userPub: number = userData.metrics.quotes.published ?? 0;
    await userSnap.ref.update(
      'metrics.quotes.published', 
      userPub + 1,
    );

    return true;
  });

export const onDeleteQuote = functions
  .region('europe-west3')
  .firestore
  .document('quotes/{quoteId}')
  .onDelete(async (quoteSnap) => {
    const quoteData = quoteSnap.data();
    const language: string = quoteData.language;

    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('quotes')
      .get();

    const metricData = metricSnap.data();

    if (metricSnap.exists && metricData) {
      const total = Math.max(0, metricData.total - 1);
      const payload: Record<string, number> = { total };

      if (language && metricData[language]) {
        payload[language] = Math.max(0, metricData[language] - 1);
      }

      await metricSnap.ref.update(payload);
    }

    // Update user's stats.
    const userSnap = await firestore
      .collection('users')
      .doc(quoteData.user.id)
      .get();

    const userData = userSnap.data();
    if (!userSnap.exists || !userData) { 
      return; 
    }

    if (!userData) { return; }
    const userPub: number = userData.metrics.published ?? 0;
    await userSnap.ref.update(
      'metrics.quotes.published', 
      Math.max(0, userPub - 1),
    );
    return true;
  });

// ----------
// TempQuotes
// ----------
export const onCreateDraft = functions
  .region('europe-west3')
  .firestore
  .document('drafts/{draftId}')
  .onCreate(async (draftSnap) => {
    const draftData = draftSnap.data();
    const language: string = draftData.language;

    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('drafts')
      .get();

    const metricData = metricSnap.data();
    if (!metricSnap.exists || !metricData) {
      return false;
    }
    
    const submitted = metricData.submitted;
    const total: number = metricData.submitted.total + 1;
    const payload = {
      ...submitted,
      ...{ total },
    }

    if (language && submitted[language]) {
      payload[language] = submitted[language] + 1;
    }

    await metricSnap.ref.update("submitted", payload);

    // User metrics update.
    const userId: string = draftData.user.id;
    const userSnap = await firestore
      .collection('users')
      .doc(userId)
      .get();

    const userData = userSnap.data();
    if (!userSnap.exists || !userData) { 
      return; 
    }

    const userSubmitted: number = userData.metrics.quotes.submitted ?? 0;
    await userSnap.ref.update(
      'metrics.quotes.submitted', 
      userSubmitted + 1,
    );

    return true;
  });

export const onDeleteDraft = functions
  .region('europe-west3')
  .firestore
  .document('drafts/{draftId}')
  .onDelete(async (draftSnap) => {
    const draftData = draftSnap.data();
    const language: string = draftData.language;

    const quoteMetrics = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('drafts')
      .get();

    const quoteMetricData = quoteMetrics.data();

    if (quoteMetrics.exists && quoteMetricData) {
      const submitted = quoteMetricData.submitted;
      const total = Math.max(0, submitted.total - 1);
      const payload = {
        ...submitted,
        ...{ total },
      }

      if (language && submitted[language]) {
        payload[language] = Math.max(0, submitted[language] - 1);
      }

      await quoteMetrics.ref.update("submitted", payload);
    }

    // User stats update.
    const userId: string = draftData.user.id;
    const userSnap = await firestore
      .collection('users')
      .doc(userId)
      .get();

    const userData = userSnap.data();
    if (!userSnap.exists || !userData) { 
      return; 
    }

    const userSubmitted: number = userData.metrics.quotes.submitted ?? 0;
    await userSnap.ref.update(
      'metrics.quotes.submitted', 
      Math.max(0, userSubmitted - 1),
    );

    return true;
  });

// ----------
// References
// ----------
export const onCreateReference = functions
  .region('europe-west3')
  .firestore
  .document('references/{referenceId}')
  .onCreate(async (refSnap) => {
    const refData = refSnap.data();
    const language: string = refData.language || refData.lang;

    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('references')
      .get();

    const metricData = metricSnap.data();
    if (!metricSnap.exists || !metricData) {
      return false;
    }

    const total: number = metricData.total + 1;
    const payload: Record<string, number> = { total };

    if (language && metricData[language]) {
      payload[language] = metricData[language] + 1;
    }

    await metricSnap.ref.update(payload);
    return true;
  });

export const onDeleteReference = functions
  .region('europe-west3')
  .firestore
  .document('references/{referenceId}')
  .onDelete(async (refSnap) => {
    const refData = refSnap.data();
    const language: string = refData.language;

    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('references')
      .get();

    const metricData = metricSnap.data();

    if (!metricSnap.exists || !metricData) {
      return false;
    }

    const total = Math.max(0, metricData.total - 1);
    const payload: Record<string, number> = { total };

    if (language && metricData[language]) {
      payload[language] = Math.max(0, metricData[language] - 1);
    }

    await metricSnap.ref.update(payload);
    return true;
  });


// --------
// Comments
// --------
export const onCreateComment = functions
  .region('europe-west3')
  .firestore
  .document('comments/{commentId}')
  .onCreate(async () => {
    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('comments')
      .get();

    const metricData = metricSnap.data();

    if (!metricSnap.exists || !metricData) {
      return false;
    }
    
    const total: number = metricData.total + 1;
    const payload: Record<string, number> = { total };
    await metricSnap.ref.update(payload);
    
    return true;
  });

export const onDeleteComment = functions
  .region('europe-west3')
  .firestore
  .document('comments/{commentId}')
  .onDelete(async () => {
    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('comments')
      .get();

    const metricData = metricSnap.data();
    if (!metricSnap.exists || !metricData) {
      return false;
    }

    const total = Math.max(0, metricData.total - 1);
    const payload: Record<string, number> = { total };
    await metricSnap.ref.update(payload);

    return true;
  });

// ----------
// Favourites
// ----------
export const onCreateFavourite = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/favourites/{quoteId}')
  .onCreate(async ({}, context) => {
    const quoteDoc = await firestore
      .collection('quotes')
      .doc(context.params.quoteId)
      .get();

    const quoteData = quoteDoc.data();
    if (!quoteDoc.exists || !quoteData) {
      return;
    }

    const quoteLikes: number = quoteData.metrics?.likes ?? 0;
    const userSnap = await firestore
      .collection('users')
      .doc(context.params.userId)
      .get();

    const userData = userSnap.data();
    if (userSnap.exists && userData) {
      const userFavourites: number = userData.metrics?.favourites ?? 0;
      await userSnap.ref.update('metrics.favourites', userFavourites + 1);
    }

    return await quoteDoc.ref.update(
      'metrics.likes', 
      quoteLikes + 1,
    );
  });

export const onDeleteFavourite = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/favourites/{quoteId}')
  .onDelete(async ({}, context) => {
    const quoteDoc = await firestore
      .collection('quotes')
      .doc(context.params.quoteId)
      .get();

    const quoteData = quoteDoc.data();
    if (!quoteDoc.exists || !quoteData) {
      return false;
    }

    const userSnap = await firestore
      .collection('users')
      .doc(context.params.userId)
      .get();

    const userData = userSnap.data();
    if (userSnap.exists && userData) {
      const userFavourites: number = userData.metrics?.favourites ?? 0;
      await userSnap.ref.update(
        'metrics.favourites', 
        Math.max(0, userFavourites - 1),
      );
    }

    const quoteLikes: number = quoteData.metrics?.likes ?? 0;
    await quoteDoc.ref.update(
      'metrics.likes', 
      Math.max(0, quoteLikes - 1),
    );

    return true;
  });

// --------
// Drafts
// --------
export const onCreateUserDraft = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/drafts/{draftId}')
  .onCreate(async ({ }, context) => {
    const userSnap = await firestore
      .collection('users')
      .doc(context.params.userId)
      .get();

    const userData = userSnap.data();
    if (!userSnap.exists || !userData) { 
      return false; 
    }

    const userDrafts: number = userData.metrics?.drafts ?? 0;
    await userSnap.ref.update(
      'metrics.drafts', 
      userDrafts + 1,  
    );

    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('drafts')
      .get();

    const metricData = metricSnap.data();
    if (!metricSnap.exists || !metricData) {
      return false;
    }

    const userCount = metricData.user + 1;
    await metricSnap.ref.update("user", userCount);
    return true;
  });

export const onDeleteUserDraft = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/drafts/{draftId}')
  .onDelete(async ({ }, context) => {
    const userSnap = await firestore
      .collection('users')
      .doc(context.params.userId)
      .get();

    const userData = userSnap.data();
    if (!userSnap.exists || !userData) { 
      return false; 
    }

    const userDrafts: number = userData.metrics.drafts ?? 0;
    await userSnap.ref.update(
      'metrics.drafts', 
      Math.max(0, userDrafts - 1),
    );

    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('drafts')
      .get();

    const metricData = metricSnap.data();
    if (!metricSnap.exists || !metricData) {
      return false;
    }

    const userCount = Math.max(0, metricData.user - 1);
    await metricSnap.ref.update("user", userCount);
    return true;
  });

// -------
// Lists
// -------

/**
 * Increment user's list count on create list.
 */
export const onCreateList = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/lists/{listId}')
  .onCreate(async ({ }, context) => {
    const user = await firestore
      .collection('users')
      .doc(context.params.userId)
      .get();

    const userData = user.data();
    if (!user.exists || !userData) { 
      return false; 
    }

    const userLists: number = userData.metrics?.lists ?? 0;
    await user.ref.update(
      'metrics.lists', 
      userLists + 1,
    );

    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('lists')
      .get();

    const metricData = metricSnap.data();
    if (!metricSnap.exists || !metricData) {
      return false;
    }

    const total = metricData.total + 1;
    const payload: Record<string, number> = { total };
    await metricSnap.ref.update(payload);

    return true;
  });

/**
 * Decrement user's list count on create list.
 */
export const onDeleteList = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/lists/{listId}')
  .onDelete(async ({ }, context) => {
    const user = await firestore
      .collection('users')
      .doc(context.params.userId)
      .get();

    const userData = user.data();
    if (!user.exists || !userData) { 
      return false; 
    }

    const userLists: number = userData.metrics.lists ?? 0;
    await user.ref.update(
      'metrics.lists', 
      Math.max(0, userLists - 1),
    );

    const metricSnap = await firestore
      .collection(METRICS_COLLECTION_NAME)
      .doc('lists')
      .get();

    const metricData = metricSnap.data();
    if (!metricSnap.exists || !metricData) {
      return false;
    }

    const total = Math.max(0, metricData.total - 1);
    const payload: Record<string, number> = { total };
    await metricSnap.ref.update(payload);

    return true;
  });


// --------------------
// Quotes inside lists
// --------------------

/**
 * Increment user's list `itemsCount` when a new quote is created.
 */
export const onCreateQuoteInList = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/lists/{listId}/quotes/{quoteId}')
  .onCreate(async ({ }, context) => {
    const { userId, listId } = context.params;

    const listSnapshot = await firestore
      .collection('users')
      .doc(userId)
      .collection('lists')
      .doc(listId)
      .get();

    const listData = listSnapshot.data();
    if (!listSnapshot.exists || !listData) {
      return false;
    }

    const item_count = listData.item_count ?? 0;
    await listSnapshot.ref.update({
      item_count: item_count + 1,
    });

    return true;
  });

/**
 * Decrement user's list `itemsCount` when a new quote is added.
 */
export const onDeleteQuoteInList = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/lists/{listId}/quotes/{quoteId}')
  .onDelete(async ({ }, context) => {
    const { userId, listId } = context.params;

    const listSnapshot = await firestore
      .collection('users')
      .doc(userId)
      .collection('lists')
      .doc(listId)
      .get();

    const listData = listSnapshot.data();
    if (!listSnapshot.exists || !listData) {
      return;
    }

    const itemCount = listData.item_count ??  0;
    await listSnapshot.ref.update({
      item_count: Math.max(0, itemCount - 1),
    });

    return true;
  });
