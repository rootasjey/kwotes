import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';

const firestore = adminApp.firestore();

// -----
// Apps
// -----
export const onCreateApp = functions
  .region('europe-west3')
  .firestore
  .document('apps/{appId}')
  .onCreate(async () => {
    const statsSnap = await firestore
      .collection('stats')
      .doc('apps')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total: number = statsData.total;

    await statsSnap.ref.update({
      total: total + 1,
    });

    return true;
  });

export const onDeleteApp = functions
  .region('europe-west3')
  .firestore
  .document('apps/{appId}')
  .onDelete(async () => {
    const statsSnap = await firestore
      .collection('stats')
      .doc('apps')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total: number = statsData.total;

    await statsSnap.ref.update({
      total: Math.max(0, total - 1),
    });

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
    const statsSnap = await firestore
      .collection('stats')
      .doc('topics')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total: number = statsData.total;

    await statsSnap.ref.update({
      total: total + 1,
    });

    return true;
  });

export const onDeleteTopic = functions
  .region('europe-west3')
  .firestore
  .document('topics/{topicId}')
  .onDelete(async () => {
    const statsSnap = await firestore
      .collection('stats')
      .doc('topics')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total: number = statsData.total;

    await statsSnap.ref.update({
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
    const isDev: boolean = userData.developer.isProgramActive;

    const statsSnap = await firestore
      .collection('stats')
      .doc('users')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total: number = statsData.total + 1;
    const payload: Record<string, number> = { total };

    if (isDev) {
      payload.dev = statsData.dev + 1;
    }

    await statsSnap.ref.update(payload);
    return true;
  });

export const onUpdateUser = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}')
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    if (!before || !after) {
      return;
    }

    const devBefore: boolean = before.developer?.isProgramActive ?? false;
    const devAfter: boolean = after.developer?.isProgramActive ?? false;

    if (devAfter === devBefore) {
      return;
    }

    const statsSnap = await firestore
      .collection('stats')
      .doc('users')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    let dev: number = statsData.dev;

    // New dev account.
    if (devBefore === false && devAfter === true) {
      dev++;
    }

    // Closed dev account
    if (devBefore === true && devAfter === false) {
      dev--;
    }

    await statsSnap.ref.update({
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
    const wasDev: boolean = userData.developer.isProgramActive;

    const statsSnap = await firestore
      .collection('stats')
      .doc('users')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total: number = Math.max(0, statsData.total - 1);
    const payload: Record<string, number> = { total };

    if (wasDev) {
      payload.dev = Math.max(0, statsData.dev - 1);
    }

    await statsSnap.ref.update(payload);
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
    const statsSnap = await firestore
      .collection('stats')
      .doc('authors')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total: number = statsData.total;

    await statsSnap.ref.update({
      total: total + 1,
    });

    return true;
  });

export const onDeleteAuthor = functions
  .region('europe-west3')
  .firestore
  .document('authors/{authorId}')
  .onDelete(async () => {
    const statsSnap = await firestore
      .collection('stats')
      .doc('authors')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total: number = statsData.total;

    await statsSnap.ref.update({
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
    const lang: string = quoteData.lang;

    const statsSnap = await firestore
      .collection('stats')
      .doc('quotes')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total: number = statsData.total + 1;
    const payload: Record<string, number> = { total };

    if (lang && statsData[lang]) {
      payload[lang] = statsData[lang] + 1;
    }

    await statsSnap.ref.update(payload);

    // Update user's stats.
    const userSnap = await firestore
      .collection('users')
      .doc(quoteData.user.id)
      .get();

    const userData = userSnap.data();

    if (!userSnap.exists || !userData) { 
      return; 
    }

    const userPub: number = userData.stats.published ?? 0;

    await userSnap.ref.update(
      'stats.published', 
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
    const lang: string = quoteData.lang;

    const statsSnap = await firestore
      .collection('stats')
      .doc('quotes')
      .get();

    const statsData = statsSnap.data();

    if (statsSnap.exists && statsData) {
      const total = Math.max(0, statsData.total - 1);
      const payload: Record<string, number> = { total };

      if (lang && statsData[lang]) {
        payload[lang] = Math.max(0, statsData[lang] - 1);
      }

      await statsSnap.ref.update(payload);
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

    const userPub: number = userData.stats.published ?? 0;

    await userSnap.ref.update(
      'stats.published', 
      Math.max(0, userPub - 1),
    );
    return true;
  });

// ----------
// TempQuotes
// ----------
export const onCreateTempQuote = functions
  .region('europe-west3')
  .firestore
  .document('tempquotes/{tempQuoteId}')
  .onCreate(async (tempQuoteSnap) => {
    const quoteData = tempQuoteSnap.data();
    const lang: string = quoteData.lang;

    const statsSnap = await firestore
      .collection('stats')
      .doc('tempquotes')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total: number = statsData.total + 1;
    const payload: Record<string, number> = { total };

    if (lang && statsData[lang]) {
      payload[lang] = statsData[lang] + 1;
    }

    await statsSnap.ref.update(payload);

    // User stats update.
    const userId: string = quoteData.user.id;

    const userSnap = await firestore
      .collection('users')
      .doc(userId)
      .get();

    const userData = userSnap.data();
    
    if (!userSnap.exists || !userData) { 
      return; 
    }

    const userTempQuotes: number = userData.stats.tempQuotes ?? 0;

    await userSnap.ref.update(
      'stats.tempQuotes', 
      userTempQuotes + 1,
    );

    return true;
  });

export const onDeleteTempQuote = functions
  .region('europe-west3')
  .firestore
  .document('tempquotes/{tempQuoteId}')
  .onDelete(async (snapshot) => {
    const quoteData = snapshot.data();
    const lang: string = quoteData.lang;

    const quotesStats = await firestore
      .collection('stats')
      .doc('tempquotes')
      .get();

    const quotesStatsData = quotesStats.data();

    if (quotesStats.exists && quotesStatsData) {
      const total = Math.max(0, quotesStatsData.total - 1);
      const payload: Record<string, number> = { total };

      if (lang && quotesStatsData[lang]) {
        payload[lang] = Math.max(0, quotesStatsData[lang] - 1);
      }

      await quotesStats.ref.update(payload);
    }

    // User stats update.
    const userId: string = quoteData.user.id;

    const userSnap = await firestore
      .collection('users')
      .doc(userId)
      .get();

    const userData = userSnap.data();
    
    if (!userSnap.exists || !userData) { 
      return; 
    }

    const userTempQuotes: number = userData.stats.tempQuotes ?? 0;

    await userSnap.ref.update(
      'stats.tempQuotes', 
      Math.max(0, userTempQuotes - 1),
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
    const lang: string = refData.lang;

    const statsSnap = await firestore
      .collection('stats')
      .doc('references')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total: number = statsData.total + 1;
    const payload: Record<string, number> = { total };

    if (lang && statsData[lang]) {
      payload[lang] = statsData[lang] + 1;
    }

    await statsSnap.ref.update(payload);
    return true;
  });

export const onDeleteReference = functions
  .region('europe-west3')
  .firestore
  .document('references/{referenceId}')
  .onDelete(async (refSnap) => {
    const refData = refSnap.data();
    const lang: string = refData.lang;

    const statsSnap = await firestore
      .collection('stats')
      .doc('references')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total = Math.max(0, statsData.total - 1);
    const payload: Record<string, number> = { total };

    if (lang && statsData[lang]) {
      payload[lang] = Math.max(0, statsData[lang] - 1);
    }

    await statsSnap.ref.update(payload);
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
    const statsSnap = await firestore
      .collection('stats')
      .doc('comments')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }
    
    const total: number = statsData.total + 1;
    const payload: Record<string, number> = { total };
    await statsSnap.ref.update(payload);
    
    return true;
  });

export const onDeleteComment = functions
  .region('europe-west3')
  .firestore
  .document('comments/{commentId}')
  .onDelete(async () => {
    const statsSnap = await firestore
      .collection('stats')
      .doc('comments')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total = Math.max(0, statsData.total - 1);
    const payload: Record<string, number> = { total };
    await statsSnap.ref.update(payload);

    return true;
  });

// ----------
// Favourites
// ----------
export const onCreateFav = functions
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

    const quoteLikes: number = quoteData.stats?.likes ?? 0;

    const userSnap = await firestore
      .collection('users')
      .doc(context.params.userId)
      .get();

    const userData = userSnap.data();

    if (userSnap.exists && userData) {
      const userFav: number = userData.stats?.fav ?? 0;
      await userSnap.ref.update('stats.fav', userFav + 1);
    }

    return await quoteDoc.ref.update(
      'stats.likes', 
      quoteLikes + 1,
    );
  });

export const onDeleteFav = functions
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

    const quoteFav: number = quoteData.stats?.likes ?? 0;

    const userSnap = await firestore
      .collection('users')
      .doc(context.params.userId)
      .get();

    const userData = userSnap.data();

    if (userSnap.exists && userData) {
      const userFav: number = userData.stats?.fav ?? 0;
      await userSnap.ref.update(
        'stats.fav', 
        Math.max(0, userFav - 1),
      );
    }

    await quoteDoc.ref.update(
      'stats.likes', 
      Math.max(0, quoteFav - 1),
    );

    return true;
  });

// --------
// Drafts
// --------
export const onCreateDraft = functions
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

    const userDrafts: number = userData.stats?.drafts ?? 0;

    await userSnap.ref.update(
      'stats.drafts', 
      userDrafts + 1,  
    );

    const statsSnap = await firestore
      .collection('stats')
      .doc('drafts')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total = statsData.total + 1;
    const payload: Record<string, number> = { total };
    await statsSnap.ref.update(payload);

    return true;
  });

export const onDeleteDraft = functions
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

    const userDrafts: number = userData.stats.drafts ?? 0;

    await userSnap.ref.update(
      'stats.drafts', 
      Math.max(0, userDrafts - 1),
    );

    const statsSnap = await firestore
      .collection('stats')
      .doc('drafts')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total = Math.max(0, statsData.total - 1);
    const payload: Record<string, number> = { total };
    await statsSnap.ref.update(payload);

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

    const userLists: number = userData.stats?.lists ?? 0;

    await user.ref.update(
      'stats.lists', 
      userLists + 1,
    );

    const statsSnap = await firestore
      .collection('stats')
      .doc('lists')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total = statsData.total + 1;
    const payload: Record<string, number> = { total };
    await statsSnap.ref.update(payload);

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

    const userLists: number = userData.stats.lists ?? 0;

    await user.ref.update(
      'stats.lists', 
      Math.max(0, userLists - 1),
    );

    const statsSnap = await firestore
      .collection('stats')
      .doc('lists')
      .get();

    const statsData = statsSnap.data();

    if (!statsSnap.exists || !statsData) {
      return false;
    }

    const total = Math.max(0, statsData.total - 1);
    const payload: Record<string, number> = { total };
    await statsSnap.ref.update(payload);

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

    const itemsCount = listData.itemsCount ?? 0;

    await listSnapshot.ref.update({
      itemsCount: itemsCount + 1,
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

    const itemsCount = listData.itemsCount ?? 0;

    await listSnapshot.ref.update({
      itemsCount: Math.max(0, itemsCount - 1),
    });

    return true;
  });
