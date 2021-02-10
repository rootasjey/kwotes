import * as express from 'express';
import { adminApp } from '../../adminApp';
import { checkAPIKey } from '../utils';

export const authorsRouter = express.Router()
  .use(checkAPIKey)
  .get('/', async (req, res, next) => {
    const startAfter = req.query.startAfter as string ?? '';

    const strOffset = req.query.offset as string ?? '0';
    const offset = parseInt(strOffset);

    const userStrLimit = req.query.limit as string ?? '12';
    const userIntLimit = parseInt(userStrLimit);

    const isLimitInRange = userIntLimit > 0 && userIntLimit < 21;
    const limit = isLimitInRange ? userIntLimit : 12;

    const warningStr = isLimitInRange
      ? ''
      : `The value '${userStrLimit}' for the query string 'limit' is not valid. 
          Please use a value between '1' and '20' included.`;

    const responsePayload = {
      success: false,
      authors: <FirebaseFirestore.DocumentData>[],
      error: {
        reason: '',
      },
      warning: warningStr,
    };

    const query = adminApp.firestore()
      .collection('authors')
      .offset(offset)
      .limit(limit);

    if (startAfter) {
      const startAfterDoc = await adminApp.firestore()
        .collection('authors')
        .doc(startAfter)
        .get();

      query.startAfter(startAfterDoc);
    }

    let snapshot: FirebaseFirestore.QuerySnapshot<FirebaseFirestore.DocumentData>;

    try { snapshot = await query.get(); }
    catch (error) { next(error); return; }

    if (snapshot.empty) {
      res.status(404).send({
        error: {
          reason: `There is no data for this query.`
        }
      });
      return;
    }

    const authors = [];

    for (const doc of snapshot.docs) {
      const docData = doc.data();
      docData.id = doc.id;
      authors.push(docData);
    }

    responsePayload.authors = authors;
    res.send({ response: responsePayload });
  })
  .get('/:id', async (req, res) => {
    const authorId: string = req.params.id;

    if (!authorId) {
      res
        .status(400)
        .send(`No id was provided. Please send a valid author's id.`);

      return;
    }

    const authorDoc = await adminApp.firestore()
      .collection('authors')
      .doc(authorId)
      .get();

    const authorData = authorDoc.data();

    if (!authorData || !authorDoc.exists) {
      res
        .status(404)
        .send(`No author was found for the specified id: ${authorId}.
          Maybe the data has been deleted.`);

      return;
    }

    res.send({ response: authorData });
  });