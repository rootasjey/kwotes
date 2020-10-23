import * as FileType from 'file-type';
import * as functions from 'firebase-functions';
import got from 'got';

import { adminApp } from './adminApp';

const firestore = adminApp.firestore();

// The following function generate an image from a provided URL
// and upload the image to Firebase storage thanks to Cloud function.
// ------------------
// onAdd[Type]PP    : generate and save a new image from an url (object.urls.image).
// onUpdate[Type]PP : delete the existing image file, upload a new one and update prop.
// onDelete[Type]PP : delete existing image file.
// ------------------

// Author
// ------
export const onAddAuthorPP = functions
  .region('europe-west3')
  .firestore
  .document('authors/{authorId}')
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    const onlineURL = data.urls.image;

    if (!onlineURL) { return; }

    const bucket = adminApp.storage().bucket();
    const stream = got.stream(onlineURL);
    const fileType = await FileType.fromStream(stream);

    // -- Upload, Naming, & Update Firestore
    const suffix = Date.now();
    const imageName = `${data.name}-${suffix}.${fileType?.ext}`;
    
    const uploadedFile = bucket.file(`images/pp/${imageName}`);

    const buffer = await got.get(onlineURL).buffer();
    await uploadedFile.save(
      buffer, 
      {
        metadata: {
          contentType: fileType?.mime,
          predefinedAcl: 'publicRead',
        },
      });

    const previewURL = `https://firebasestorage.googleapis.com/v0/b/memorare-98eee.appspot.com/o/images%2Fpp%2F${imageName}?alt=media`;

    return firestore
      .collection('authors')
      .doc(context.params.authorId)
      .update({
        'urls.image': previewURL,
        'urls.imageName': imageName,
      });
  });

export const onUpdateAuthorPP = functions
  .region('europe-west3')
  .firestore
  .document('authors/{authorId}')
  .onUpdate(async (snapshot, context) => {
    const beforeData = snapshot.before.data();
    const afterData = snapshot.after.data();
    
    const onlineURL: string = afterData.urls.image;

    if (!onlineURL) { return; }

    // Image URL didn't change.
    if (onlineURL === beforeData.urls.image) {
      return;
    }

    // New URL is a Firebase storage one, so it's okay.
    if (onlineURL.indexOf('firebasestorage.googleapis.com') > -1 
      || onlineURL.indexOf('/memorare-') > -1) {
      return;
    }

    const bucket = adminApp.storage().bucket();

    // Delete previous stored image
    if (afterData.urls.imageName) {
      await bucket.file(`images/pp/${afterData.urls.imageName}`).delete();
    }

    const stream = got.stream(onlineURL);
    const fileType = await FileType.fromStream(stream);

    // -- Upload, Naming, & Update Firestore
    const suffix = Date.now();
    const imageName = `${afterData.name}-${suffix}.${fileType?.ext}`;

    const uploadedFile = bucket.file(`images/pp/${imageName}`);

    const buffer = await got.get(onlineURL).buffer();
    await uploadedFile.save(
      buffer,
      {
        metadata: {
          contentType: fileType?.mime,
          predefinedAcl: 'publicRead',
        },
      });

    const previewURL = `https://firebasestorage.googleapis.com/v0/b/memorare-98eee.appspot.com/o/images%2Fpp%2F${imageName}?alt=media`;

    return firestore
      .collection('authors')
      .doc(context.params.authorId)
      .update({
        'urls.image': previewURL,
        'urls.imageName': imageName,
      });
  });

export const onDeleteAuthorPP = functions
  .region('europe-west3')
  .firestore
  .document('authors/{authorId}')
  .onDelete(async (snapshot) => {
    const data = snapshot.data();
    const onlineURL: string = data.urls.image;

    if (!onlineURL) { return; }

    // URL is NOT a Firebase storage pattern, so there's nothing to delete.
    if (onlineURL.indexOf('firebasestorage.googleapis.com') < 0
      && onlineURL.indexOf('/memorare-') < 0) {
      return;
    }

    const bucket = adminApp.storage().bucket();

    // Delete previous stored image
    if (data.urls.imageName) {
      await bucket.file(`images/pp/${data.urls.imageName}`).delete();
    }

    return true;
  });

// Reference
// ---------
export const onAddReferencePP = functions
  .region('europe-west3')
  .firestore
  .document('references/{referenceId}')
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    const onlineURL = data.urls.image;

    if (!onlineURL) { return; }

    const stream = got.stream(onlineURL);
    const fileType = await FileType.fromStream(stream);
    const bucket = adminApp.storage().bucket();

    // -- Upload, Naming, & Update Firestore
    const suffix = Date.now();
    const imageName = `${data.name}-${suffix}.${fileType?.ext}`;

    const uploadedFile = bucket.file(`images/pp/${imageName}`);

    const buffer = await got.get(onlineURL).buffer();
    await uploadedFile.save(
      buffer,
      {
        metadata: {
          contentType: fileType?.mime,
          predefinedAcl: 'publicRead',
        },
      });

    const previewURL = `https://firebasestorage.googleapis.com/v0/b/memorare-98eee.appspot.com/o/images%2Fpp%2F${imageName}?alt=media`;

    return firestore
      .collection('references')
      .doc(context.params.referenceId)
      .update({
        'urls.image': previewURL,
        'urls.imageName': imageName,
      });
  });

export const onUpdateReferencePP = functions
  .region('europe-west3')
  .firestore
  .document('references/{referenceId}')
  .onUpdate(async (snapshot, context) => {
    const beforeData = snapshot.before.data();
    const afterData = snapshot.after.data();

    const onlineURL: string = afterData.urls.image;

    if (!onlineURL) { return; }

    // Image URL didn't change.
    if (onlineURL === beforeData.urls.image) {
      return;
    }

    // New URL is a Firebase storage one, so it's okay.
    if (onlineURL.indexOf('firebasestorage.googleapis.com') > -1
      || onlineURL.indexOf('/memorare-') > -1) {
      return;
    }

    const bucket = adminApp.storage().bucket();

    // Delete previous stored image
    if (afterData.urls.imageName) {
      await bucket.file(`images/pp/${afterData.urls.imageName}`).delete();
    }

    const stream = got.stream(onlineURL);
    const fileType = await FileType.fromStream(stream);

    // -- Upload, Naming, & Update Firestore
    const suffix = Date.now();
    const imageName = `${afterData.name}-${suffix}.${fileType?.ext}`;

    const uploadedFile = bucket.file(`images/pp/${imageName}`);

    const buffer = await got.get(onlineURL).buffer();
    await uploadedFile.save(
      buffer,
      {
        metadata: {
          contentType: fileType?.mime,
          predefinedAcl: 'publicRead',
        },
      });

    const previewURL = `https://firebasestorage.googleapis.com/v0/b/memorare-98eee.appspot.com/o/images%2Fpp%2F${imageName}?alt=media`;

    return firestore
      .collection('references')
      .doc(context.params.referenceId)
      .update({
        'urls.image': previewURL,
        'urls.imageName': imageName,
      });
  });

export const onDeleteReferencePP = functions
  .region('europe-west3')
  .firestore
  .document('references/{referenceId}')
  .onDelete(async (snapshot) => {
    const data = snapshot.data();
    const onlineURL: string = data.urls.image;

    if (!onlineURL) { return; }

    // URL is NOT a Firebase storage pattern, so there's nothing to delete.
    if (onlineURL.indexOf('firebasestorage.googleapis.com') < 0
      && onlineURL.indexOf('/memorare-') < 0) {
      return;
    }

    const bucket = adminApp.storage().bucket();

    // Delete previous stored image
    if (data.urls.imageName) {
      await bucket.file(`images/pp/${data.urls.imageName}`).delete();
    }

    return true;
  });
