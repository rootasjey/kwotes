import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const firestore = admin.firestore();
const fcm = admin.messaging();

// Check that the new created doc is well-formatted.
export const newAccountCheck = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}')
  .onCreate(async (snapshot, context) => {
    let isOk = true;
    let data = snapshot.data();

    if (!data) {
      isOk = false;
      data = await populateUserData(snapshot);
    }

    // rights check
    if (typeof data.rights === 'undefined') {
      isOk = false;
      data.rights = {
        'user:managedata'     : false,
        'user:manageauthor'   : false,
        'user:managequote'    : false,
        'user:managequotidian': false,
        'user:managereference': false,
        'user:proposequote'   : true,
        'user:readquote'      : true,
        'user:validatequote'  : false,
      };
    }

    if (!await isUserNameOk(snapshot)) {
      isOk = false;
      data.name = `data.name-${Date.now()}`;
      data.nameLowerCase = `data.name-${Date.now()}`;
    }

    if (isOk) { return; }

    return await snapshot.ref
      .update(data);
  });

async function isUserNameOk(snapshot: functions.firestore.DocumentSnapshot) {
  const data = snapshot.data();
  if (!data) { return; }

  const nameLowerCase = data.nameLowerCase;

  const userNamesSnap = await firestore
    .collection('users')
    .where('nameLowerCase', '==', nameLowerCase)
    .limit(2)
    .get();

  const trueMatch = userNamesSnap.docs
    .filter((doc) => doc.id !== snapshot.id);

  return trueMatch.length === 0;
}

export const onFavAdded = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/favourites/{quoteId}')
  .onCreate(async (snapshot, context) => {
    const quoteSnap = await firestore
      .collection('quotes')
      .doc(snapshot.id)
      .get();

    if (!quoteSnap.exists) { return; }

    const data = quoteSnap.data();
    if (!data) { return; }

    const favCount: number = data.stats.likes;
    return await quoteSnap.ref
      .update({
        'stats.likes': favCount + 1,
      });
  });

export const onFavDeleted = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/favourites/{quoteId}')
  .onDelete(async (snapshot, context) => {
    const quoteSnap = await firestore
      .collection('quotes')
      .doc(snapshot.id)
      .get();

    if (!quoteSnap.exists) { return; }

    const data = quoteSnap.data();
    if (!data) { return; }

    const favCount: number = data.stats.likes;
    if (favCount === 0) { return; }

    return await quoteSnap.ref
      .update({
        'stats.likes': favCount - 1,
      });
  });

// Add all missing props.
async function populateUserData(snapshot: functions.firestore.DocumentSnapshot) {
  const user = await admin.auth().getUser(snapshot.id);
  const email = typeof user !== 'undefined' ?
    user.email : '';

  return {
    'email': email,
    'flag': '',
    'lang': 'en',
    'name': '',
    'nameLowerCase': '',
    'notifications': [],
    'pricing': 'free',
    'quota': {
      'current': 0,
      'date': Date.now(),
      'limit': 1,
    },
    'rights': {
      'user:managedata': false,
      'user:manageauthor': false,
      'user:managequote': false,
      'user:managequotidian': false,
      'user:managereference': false,
      'user:proposequote': true,
      'user:readquote': true,
      'user:validatequote': false,
    },
    'stats': {
      'favourites': 0,
      'lists': 0,
      'proposed': 0,
    },
    'tokens': {},
    'urls': {
      'image': '',
    },
    'uid': snapshot.id,
  };
}

// Prevent user's rights update.
// TODO: Allow admins to update user's rights.
export const updateUserCheck = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    if (!beforeData || !afterData) { return; }

    if (typeof beforeData.rights === 'undefined' ||
      typeof afterData.rights === 'undefined') {
        return;
      }

    let isOk = true;

    for (const [key, value] of Object.entries(afterData.rights)) {
      const isEqual = value === beforeData.rights[key];

      isOk = isOk && isEqual;
    }

    if (isOk) { return; }

    return await change.after.ref
      .update({
        'rights': beforeData.rights,
      });
  });

export const incrementQuoteQuota = functions
  .region('europe-west3')
  .firestore
  .document('tempquotes/{tempquoteId}')
  .onCreate(async (snapshot, context) => {
    const snapshotData = snapshot.data();
    if (!snapshotData) { return; }

    const userUid = snapshotData.user.id;
    if (!userUid) { return; }

    const userDoc = await firestore
      .collection('users')
      .doc(userUid)
      .get();

    if (!userDoc.exists) { return; }

    const data = userDoc.data();
    if (!data) { return; }

    const serverDate = new Date(context.timestamp);
    const quota = data.quota;

    let date = quota.date !== null && typeof quota.date !== 'undefined' ?
      quota.date.toDate() :
      new Date('January 1');

    let current: number = quota['current'];

    if (date.getDate() !== serverDate.getDate() ||
      date.getMonth() !== serverDate.getMonth() ||
      date.getFullYear() !== serverDate.getFullYear()) {

      current = 0;
      date = serverDate;
    }

    current += 1;

    return await userDoc.ref
      .update({
        'quota.date': admin.firestore.Timestamp.fromDate(date),
        'quota.current': current,
      });
  });

export const quotidiansMobileEN = functions
  .region('europe-west3')
  .pubsub
  .schedule('every day 08:00')
  .onRun(async (context) => {
    const date = new Date(context.timestamp);

    const monthNumber = date.getMonth() + 1;

    const month = monthNumber     < 10 ? `0${monthNumber}`    : monthNumber;
    const day   = date.getDate()  < 10 ? `0${date.getDate()}` : date.getDate();

    const dateId = `${date.getFullYear()}:${month}:${day}:en`;

    console.log(`quotidians EN - ${dateId}`);

    const quotidian = await firestore
      .collection('quotidians')
      .doc(dateId)
      .get();

    if (!quotidian.exists) { return; }

    const data = quotidian.data();
    if (!data) { return; }

    const quoteName = data['quote']['name'];

    const payload: admin.messaging.MessagingPayload = {
      data: {
        path: `/quote/${data['quote']['id']}`,
      },
      notification: {
        title: 'Quotidian',
        body: quoteName,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      }
    };

    return await fcm.sendToTopic('quotidians-mobile-en', payload);
  });

export const quotidiansMobileFR = functions
  .region('europe-west3')
  .pubsub
  .schedule('every day 08:00')
  .onRun(async (context) => {
    const date = new Date(context.timestamp);

    const monthNumber = date.getMonth() + 1;

    const month = monthNumber     < 10 ? `0${monthNumber}`    : monthNumber;
    const day   = date.getDate()  < 10 ? `0${date.getDate()}` : date.getDate();

    const dateId = `${date.getFullYear()}:${month}:${day}:fr`;

    console.log(`quotidians FR - ${dateId}`);

    const quotidian = await firestore
      .collection('quotidians')
      .doc(dateId)
      .get();

    if (!quotidian.exists) { return; }

    const data = quotidian.data();
    if (!data) { return; }

    const quoteName = data['quote']['name'];

    const payload: admin.messaging.MessagingPayload = {
      data: {
        path: `/quote/${data['quote']['id']}`,
      },
      notification: {
        title: 'Quotidian',
        body: quoteName,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      },
    };

    return await fcm.sendToTopic('quotidians-mobile-fr', payload);
  });
