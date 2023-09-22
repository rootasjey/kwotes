import * as functions from 'firebase-functions';

import { adminApp } from './adminApp';
import { checkUserIsSignedIn, getEmptyAuthor, getEmptyReference, sanitizeUrls } from './utils';

const firebaseTools = require('firebase-tools');
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
      const userSnapshot = await firestore
        .collection('users')
        .limit(limit)
        .offset(offset)
        .get();

      if (userSnapshot.empty || userSnapshot.size === 0) {
        hasNext = false;
      }

      for await (const userDoc of userSnapshot.docs) {
        const userData = userDoc.data();
        if (!userData) { continue; }

        // const language = userData.lang ?? userData.language ?? "en";
        // const metrics = userData.metrics ?? userData.stats;
        // const rights = userData.rights;
        // const developer = {
        //   apps: userData.developer?.apps ?? {current: 0, limit: 5},
        //   // isProgramActive: adminApp.firestore.FieldValue.delete(),
        //   is_active: userData.developer?.is_active ?? false,
        //   payment: {}
        // };
        

        // Update & Delete unecessaries fields.
        // await userDoc.ref.update({
        //   developer,
        //   language,
        //   lang: adminApp.firestore.FieldValue.delete(),
        //   metrics: {
        //     drafts: metrics?.drafts ?? 0,
        //     favourites: metrics?.favourites ?? metrics?.fav ?? 0,
        //     lists: metrics?.lists ?? 0,
        //     notifications: metrics?.notifications ?? 0,
        //     quotes: {
        //       proposed: metrics?.proposed ?? 0,
        //       published: metrics?.published ?? 0,
        //       submitted: metrics?.submitted ?? metrics?.tempQuotes ?? 0,
        //     },
        //   },
        //   name_lower_case: userData.name_lower_case ?? userData.nameLowerCase ?? userData.name.toLowerCase(),
        //   nameLowerCase: adminApp.firestore.FieldValue.delete(),
        //   rights: {
        //     "user:manage_data": rights["user:manage_data"] ?? rights["user:managedata"] ?? false,
        //     "user:manage_quotes": rights["user:manage_quotes"] ?? rights["user:managequote"] ?? false ,
        //     "user:manage_authors": rights["user:manage_authors"] ?? rights["user:manageauthor"] ?? false,
        //     "user:manage_references": rights["user:manage_references"] ?? rights["user:managereference"] ?? false,
        //     "user:manage_quotidians": rights["user:manage_quotidians"] ?? rights["user:managequotidian"] ?? false,
        //     "user:propose_quotes": rights["user:propose_quotes"] ?? rights["user:proposequote"] ?? false,
        //     "user:read_quotes": rights["user:read_quotes"] ?? rights["user:readquote"] ?? false,
        //     "user:validate_quotes": rights["user:validate_quotes"] ?? rights["user:validatequote"] ?? false,
        //     // "user:managequote": adminApp.firestore.FieldValue.delete(),
        //     // "user:manageauthor": adminApp.firestore.FieldValue.delete(),
        //     // "user:managedata": adminApp.firestore.FieldValue.delete(),
        //     // "user:managequotidian": adminApp.firestore.FieldValue.delete(),
        //     // "user:managereference": adminApp.firestore.FieldValue.delete(),
        //     // "user:proposequote": adminApp.firestore.FieldValue.delete(),
        //     // "user:readquote": adminApp.firestore.FieldValue.delete(),
        //     // "user:validatequote": adminApp.firestore.FieldValue.delete(),
        //   },
        //   stats: adminApp.firestore.FieldValue.delete(),
        // });
        // updatedCount++;

        userDoc.ref.collection('lists').get().then((listSnapshot) => {
          listSnapshot.forEach(async (listDoc) => {
            // const listData = listDoc.data();
            await listDoc.ref.update({
              // created_at: listData.created_at ?? listData.createdAt,
              createdAt: adminApp.firestore.FieldValue.delete(),
              iconUrl: adminApp.firestore.FieldValue.delete(),
              // item_count: listData.item_count ?? listData.itemsCount ?? 0,
              // itemsCount: adminApp.firestore.FieldValue.delete(),
              // is_public: listData.is_public ?? listData.isPublic,
              // isPublic: adminApp.firestore.FieldValue.delete(),
              // updated_at: listData.updated_at ?? listData.updatedAt,
              updatedAt: adminApp.firestore.FieldValue.delete(),
            });
            updatedCount++;

            listDoc.ref.collection('quotes').get().then((quoteSnapshot) => {
              quoteSnapshot.forEach(async (quoteDoc) => {
                const quoteData = quoteDoc.data();

                if (quoteData.quoteId) {
                  await quoteDoc.ref.parent.doc(quoteData.quoteId).set({
                    author: {
                      id: quoteData.author?.id ?? "",
                      name: quoteData.author?.name ?? "",
                    },
                    created_at: quoteData.created_at ?? quoteData.createdAt ?? adminApp.firestore.Timestamp.now(),
                    // createdAt: adminApp.firestore.FieldValue.delete(),
                    language: quoteData.language ?? quoteData.lang ?? "en",
                    name: quoteData.name,
                    topics: quoteData.topics,
                  });
                  await quoteDoc.ref.delete();
                } else {
                  await quoteDoc.ref.update({
                    created_at: quoteData.created_at ?? quoteData.createdAt ?? adminApp.firestore.Timestamp.now(),
                    createdAt: adminApp.firestore.FieldValue.delete(),
                    language: quoteData.language ?? quoteData.lang ?? "en",
                    lang: adminApp.firestore.FieldValue.delete(),
                  });
                }
                updatedCount++;
              });
            }).catch((err) => {
              functions.logger.error(err);
            });
          });
        }).catch((err) => {
          functions.logger.error(err);
        });

        // userDoc.ref.collection('favourites').get().then((favSnapshot) => {
        //   favSnapshot.forEach(async (favDoc) => {
        //     const favData = favDoc.data();
        //     await favDoc.ref.update({
        //       author: favData.author,
        //       created_at: favData.created_at ?? favData.createdAt,
        //       createdAt: adminApp.firestore.FieldValue.delete(),
        //       language: favData.language ?? favData.lang ?? "en",
        //       lang: adminApp.firestore.FieldValue.delete(),
        //       mainReference: adminApp.firestore.FieldValue.delete(),
        //       name: favData.name,
        //       quoteId: adminApp.firestore.FieldValue.delete(),
        //       reference: favData.mainReference || favData.reference,
        //       topics: favData.topics,
        //     });
        //     updatedCount++;
        //   });
        // }).catch((err) => {
        //   functions.logger.error(err);
        // });

        // userDoc.ref.collection('notifications').get().then((notifSnapshot) => {
        //   notifSnapshot.forEach(async (notifDoc) => {
        //     const notifData = notifDoc.data();
        //     await notifDoc.ref.update({
        //       body: notifData.body,
        //       created_at: notifData.created_at ?? notifData.createdAt,
        //       createdAt: adminApp.firestore.FieldValue.delete(),
        //       is_read: notifData.is_read ?? notifData.isRead,
        //       isRead: adminApp.firestore.FieldValue.delete(),
        //       path: notifData.path,
        //       send_push_notification: notifData.send_push_notification ?? notifData.sendPushNotification,
        //       sendPushNotification: adminApp.firestore.FieldValue.delete(),
        //       subject: notifData.subject,
        //       title: notifData.title,
        //       updated_at: notifData.updated_at ?? notifData.updatedAt,
        //       updatedAt: adminApp.firestore.FieldValue.delete(),
        //     });
        //     updatedCount++;
        //   });
        // }).catch((err) => {
        //   functions.logger.error(err);
        // });

        userDoc.ref.collection('drafts').get().then((draftSnapshot) => {
          draftSnapshot.forEach(async (draftDoc) => {
            const draftData = draftDoc.data();
            const authorDraft = draftData.author ?? getEmptyAuthor();
            const referenceDraft = draftData.reference ?? getEmptyReference();
            
            const birth = authorDraft.birth;
            const born = authorDraft.born;
            const death = authorDraft.death;

            const authorImage = authorDraft.image;
            const authorImageCredits = authorImage.credits;
            const authorImageDate = 
              typeof authorImageCredits.date === "number" 
              ? adminApp.firestore.Timestamp.fromMillis(authorImageCredits.date) 
              : authorImageCredits.date ?? null;
            
            authorImage.credits = {
              before_common_era: authorImageCredits.before_common_era ??  false,
              company: authorImageCredits.company ?? "",
              date: authorImageDate,
              location: authorImageCredits.location ?? "",
              name: authorImageCredits.name ?? "",
              artist: authorImageCredits.artist ?? "",
              url: authorImageCredits.url ?? "",
            }

            const authorUrls = sanitizeUrls(authorDraft.urls);

            const referenceImage = referenceDraft.image;
            const referenceImageCredits = referenceImage.credits;
            const referenceImageDate =
              typeof referenceImageCredits.date === "number"
                ? adminApp.firestore.Timestamp.fromMillis(referenceImageCredits.date)
                : referenceImageCredits.date ?? null;

            referenceImage.credits = {
              before_common_era: referenceImageCredits.before_common_era ??  false,
              company: referenceImageCredits.company ?? "",
              date: referenceImageDate,
              location: referenceImageCredits.location ?? "",
              name: referenceImageCredits.name ?? "",
              artist: referenceImageCredits.artist ?? "",
              url: referenceImageCredits.url ?? "",
            }

            const referenceUrls = sanitizeUrls(referenceDraft.urls);

            await draftDoc.ref.update({
              author: {
                birth: {
                  before_common_era: birth?.before_common_era ?? born?.beforeJC ?? false,
                  city: birth?.city ?? born?.city ?? "",
                  country: birth?.country ?? born?.country ?? "",
                  date: birth?.date ?? born?.date ?? null,
                },
                // born: adminApp.firestore.FieldValue.delete(),
                death: {
                  before_common_era: death?.before_common_era ?? death?.beforeJC ?? false,
                  city: death?.city ?? "",
                  country: death?.country ?? "",
                  date: death?.date ?? null,
                },
                from_reference: {
                  id: authorDraft.from_reference?.id ?? authorDraft.fromReference?.id ?? "",
                  name: authorDraft.from_reference?.name ?? authorDraft.fromReference?.name ?? "",
                },
                id: authorDraft?.id ?? "",
                image: authorImage ?? {
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
                is_fictional: authorDraft.is_fictional ?? authorDraft.isFictional ?? false,
                // isFictional: adminApp.firestore.FieldValue.delete(),
                job: authorDraft.job,
                name: authorDraft.name,
                summary: authorDraft.summary,
                urls: authorUrls,
                // urls: {
                //   ...authorDraft.urls,
                //   ...{
                //     // affiliate: adminApp.firestore.FieldValue.delete(),
                //     image: authorDraft?.urls?.image ?? "",
                //     image_name: authorDraft?.urls?.imageName ?? "",
                //     // imageName: adminApp.firestore.FieldValue.delete(),
                //     prime_video: authorDraft.urls?.primeVideo ?? "",
                //     // primeVideo: adminApp.firestore.FieldValue.delete(),
                //   },
                // },
              },
              created_at: draftData.created_at ?? draftData.createdAt,
              createdAt: adminApp.firestore.FieldValue.delete(),
              id: adminApp.firestore.FieldValue.delete(),
              language: draftData.language ?? draftData.lang ?? "en",
              lang: adminApp.firestore.FieldValue.delete(),
              name: draftData.name,
              reference: {
                id: referenceDraft?.id ?? "",
                image: referenceImage ?? {
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
                // lang: adminApp.firestore.FieldValue.delete(),
                language: referenceDraft.language ?? referenceDraft.lang ?? "en",
                name: referenceDraft.name,
                release: {
                  original: referenceDraft.release?.release ?? referenceDraft.release?.original ?? null,
                  before_common_era: referenceDraft?.release ?.before_common_era ?? referenceDraft?.release?.beforeJC ?? false,
                  // beforeJC: adminApp.firestore.FieldValue.delete(),
                  // release: adminApp.firestore.FieldValue.delete(),
                },
                summary: referenceDraft.summary,
                urls: referenceUrls,
                // urls: {
                //   ...referenceDraft.urls,
                //   ...{
                //     // affiliate: adminApp.firestore.FieldValue.delete(),
                //     image: referenceDraft?.urls?.image ?? "",
                //     image_name: referenceDraft?.urls?.imageName ?? "",
                //     // imageName: adminApp.firestore.FieldValue.delete(),
                //     prime_video: referenceDraft.urls.prime_video ?? referenceDraft.urls.primeVideo ?? "",
                //     // primeVideo: adminApp.firestore.FieldValue.delete(),
                //   },
                // }
              },
              metrics: draftData.metrics ?? draftData.stats ?? {
                likes: 0,
                shares: 0,
              },
              stats: adminApp.firestore.FieldValue.delete(),
              topics: draftData.topics,
              updated_at: draftData.updated_at ?? draftData.updatedAt,
              updatedAt: adminApp.firestore.FieldValue.delete(),
              user: draftData.user,
              validation: {
                comment: draftData.validation.comment,
                status: draftData.validation.status,
                updated_at: draftData.validation.updated_at ?? draftData.validation.updatedAt,
                // updatedAt: adminApp.firestore.FieldValue.delete(),
              },
            });
            updatedCount++;
          });
        }).catch((err) => {
          functions.logger.error(err);
        });
      }

      currIteration++;
      offset += userSnapshot.size;
      totalCount += userSnapshot.size;
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
 * TODO: TEMPORARY: Delete after execution.
 * Update list.quote document to use same id.
 * Must be used after app updates (mobile & web).
 */
export const configUpdateUserLists = functions
  .region('europe-west3')
  .https
  .onRequest(async ({}, res) => {
    // The app has very few users right now (less than 20).
    const userSnapshot = await firestore
      .collection('users')
      .limit(100)
      .get();

    // For each user
    userSnapshot.docs.forEach(async (userDoc) => {
      // Get all lists
      const listsSnapshot = await firestore
        .collection(`users/${userDoc.id}/lists`)
        .get();

      // For each list
      for await (const listDoc of listsSnapshot.docs) {
        // Get all quotes
        const quotesSnap = await firestore
          .collection(`users/${userDoc.id}/lists/${listDoc.id}/quotes`)
          .get();

        // For each quote
        for await (const quoteDoc of quotesSnap.docs) {
          const quoteData = quoteDoc.data();
          
          // Check if the quote has the `quoteId` prop.
          // If this prop. exists, it uses the old data model 
          // so it must be updated.
          if (quoteData.quoteId) {
            // Add a new quote doc with the right id and the same data.
            await firestore
              .collection(`users/${userDoc.id}/lists/${listDoc.id}/quotes`)
              .doc(quoteDoc.id)
              .set(quoteDoc.data());
  
            // Delete the old quote doc.
            await quoteDoc.ref.delete();
          }
        }
      }
    });

    res.status(200).send('done');
  });

export const checkEmailAvailability = functions
  .region('europe-west3')
  .https
  .onCall(async (data) => {
    const email: string = data.email;

    if (typeof email !== 'string' || email.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with one (string)
         argument [email] which is the email to check.`,
      );
    }

    if (!validateEmailFormat(email)) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid email address.`,
      );
    }

    const exists = await isUserExistsByEmail(email);
    const isAvailable = !exists;

    return {
      email,
      isAvailable,
    };
  });

export const checkUsernameAvailability = functions
  .region('europe-west3')
  .https
  .onCall(async (data) => {
    const name: string = data.name;

    if (typeof name !== 'string' || name.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with one (string)
         argument "name" which is the name to check.`,
      );
    }

    if (!validateNameFormat(name)) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [name]
         with at least 3 alpha-numeric characters (underscore is allowed) (A-Z, 0-9, _).`,
      );
    }

    const nameSnap = await firestore
      .collection('users')
      .where('name_lower_case', '==', name.toLowerCase())
      .limit(1)
      .get();

    return {
      name: name,
      isAvailable: nameSnap.empty,
    };
  });

/**
 * Create an user with Firebase auth then with Firestore.
 * Check user's provided arguments and exit if wrong.
 */
export const createAccount = functions
  .region('europe-west3')
  .https
  .onCall(async (data: CreateUserAccountParams) => {
    if (!checkCreateAccountData(data)) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with 3 string 
        arguments [username], [email] and [password].`,
      );
    }

    const { username, password, email } = data;

    const userRecord = await adminApp
    .auth()
    .createUser({
      displayName: username,
      password: password,
      email: email,
      emailVerified: false,
    });

    await adminApp.firestore()
    .collection('users')
    .doc(userRecord.uid)
    .set({
      developer: {
        apps: {
          current: 0,
          limit: 5,
        },
        is_program_active: false,
        payment: {}
      },
      email: email,
      language: 'en',
      metrics: {
        drafts: 0,
        favourites: 0,
        lists: 0,
        notifications: {
          total: 0,
          unread: 0,
        },
        quotes: {
          proposed: 0,
          published: 0,
          submitted: 0,
        },
      },
      name: username,
      name_lower_case: username.toLowerCase(),
      rights: {
        'user:manage_data'     : false,
        'user:manage_authors'   : false,
        'user:manage_quotes'    : false,
        'user:manage_quotidians': false,
        'user:manage_references': false,
        'user:propose_quote'   : true,
        'user:read_quote'      : true,
        'user:validate_quote'  : false,
      },
      settings: {
        notifications: {
          email: {
            drafts: true,
            quotidians: false,
          },
          push: {
            quotidians: true,
            drafts: true,
          }
        },
      },
      urls: {
        image: '',
        twitter: '',
        facebook: '',
        instagram: '',
        twitch: '',
        website: '',
        wikipedia: '',
        youtube: '',
      },
      uid: userRecord.uid,
    });

    return {
      user: {
        id: userRecord.uid, 
        email,
      },
    };
  });

function checkCreateAccountData(data: any) {
  if (Object.keys(data).length !== 3) {
    return false;
  }

  const keys = Object.keys(data);

  if (!keys.includes('username') 
    || !keys.includes('email') 
    || !keys.includes('password')) {
    return false;
  }

  if (typeof data['username'] !== 'string' || 
    typeof data['email'] !== 'string' || 
    typeof data['password'] !== 'string') {
    return false;
  }

  return true;
}

/**
 * Delete user's document from Firebase auth & Firestore.
 */
export const deleteAccount = functions
  .region('europe-west3')
  .https
  .onCall(async (data: DeleteAccountParams, context) => {
    const userAuth = context.auth;
    const { idToken } = data;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    await checkUserIsSignedIn(context, idToken);

    const userSnap = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .get();

    const userData = userSnap.data();

    if (!userSnap.exists || !userData) {
      throw new functions.https.HttpsError(
        'not-found',
        `This user document doesn't exist. It may have been deleted.`,
      );
    }

    await adminApp
      .auth()
      .deleteUser(userAuth.uid);

    await firebaseTools.firestore
      .delete(userSnap.ref.path, {
        project: process.env.GCLOUD_PROJECT,
        recursive: true,
        yes: true,
      });

    return {
      success: true,
      user: {
        id: userAuth.uid,
      },
    };
  });

async function isUserExistsByEmail(email: string) {
  const emailSnapshot = await firestore
    .collection('users')
    .where('email', '==', email)
    .limit(1)
    .get();

  if (!emailSnapshot.empty) {
    return true;
  }

  try {
    const userRecord = await adminApp
      .auth()
      .getUserByEmail(email);

    if (userRecord) {
      return true;
    }

    return false;

  } catch (error) {
    return false;
  }
}

async function isUserExistsByUsername(nameLowerCase: string) {
  const nameSnapshot = await firestore
    .collection('users')
    .where('name_lower_case', '==', nameLowerCase)
    .limit(1)
    .get();

  if (nameSnapshot.empty) {
    return false;
  }

  return true;
}

/**
 * Update an user's email in Firebase auth and in Firestore.
 * Several security checks are made (email format, password, email unicity)
 * before validating the new email.
 */
export const updateEmail = functions
  .region('europe-west3')
  .https
  .onCall(async (data: UpdateEmailParams, context) => {
    const userAuth = context.auth;
    const { idToken, newEmail } = data;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user (1).`,
      );
    }

    await checkUserIsSignedIn(context, idToken);
    const isFormatOk = validateEmailFormat(newEmail);

    if (!newEmail || !isFormatOk) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [newEmail] argument. 
        The value you specified is not in a correct email format.`,
      );
    }

    const isEmailTaken = await isUserExistsByEmail(newEmail);

    if (isEmailTaken) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The email specified is not available.
         Try specify a new one in the "newEmail" argument.`,
        );
    }

    await adminApp
      .auth()
      .updateUser(userAuth.uid, {
        email: newEmail,
        emailVerified: false,
      });

    await firestore
      .collection('users')
      .doc(userAuth.uid)
      .update({
        email: newEmail,
      });

    return {
      success: true,
      user: { id: userAuth.uid },
    };
  });

/**
 * Update a new username in Firebase auth and in Firestore.
 * Several security checks are made (name format & unicity, password)
 * before validating the new username.
 */
export const updateUsername = functions
  .region('europe-west3')
  .https
  .onCall(async (data: UpdateUsernameParams, context) => {
    const userAuth = context.auth;
    
    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    const { newUsername } = data;
    const isFormatOk = validateNameFormat(newUsername);

    if (!newUsername || !isFormatOk) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [newUsername].
         The value you specified is not in a correct format.`,
      );
    }

    const isUsernameTaken = await isUserExistsByUsername(newUsername.toLowerCase());

    if (isUsernameTaken) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The name specified is not available.
         Please try with a new one.`,
      );
    }

    await adminApp
      .auth()
      .updateUser(userAuth.uid, {
        displayName: newUsername,
      });

    await firestore
      .collection('users')
      .doc(userAuth.uid)
      .update({
        name: newUsername,
        name_lower_case: newUsername.toLowerCase(),
      });

    return {
      success: true,
      user: { id: userAuth.uid },
    };
  });

function validateEmailFormat(email: string) {
  const re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
}

function validateNameFormat(name: string) {
  const re = /[a-zA-Z0-9_]{3,}/;
  const matches = re.exec(name);

  if (!matches) { return false; }
  if (matches.length < 1) { return false; }

  const firstMatch = matches[0];
  return firstMatch === name;
}

