import * as express from 'express';
import { adminApp } from '../../adminApp';
import { checkAPIKey } from '../utils';

export const topicsRouter = express.Router()
  .use(checkAPIKey)
  .get('/', async ({}, res) => {
    const snapshot = await adminApp.firestore()
      .collection('topics')
      .get();

    if (snapshot.empty) {
      res
        .status(404)
        .send({ 
          response: `No data was found. It may be a network or server error.`
        });

      return;
    }

    const topicsColors: any[] = [];

    snapshot.docs.forEach((doc) => {
      const docData = doc.data();
      if (docData) {
        topicsColors.push(docData);
      }
    });

    res.send({ response: topicsColors });
  });