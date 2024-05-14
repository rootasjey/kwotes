import * as express from 'express';
import { adminApp } from '../../adminApp';
import { checkAPIKey, isLangAvailable } from '../utils';

export const referencesRouter = express.Router()
  .use(checkAPIKey)
  .get('/', async (req, res, next) => {
    const startAfter = req.query.startAfter as string ?? '';

    const strOffset = req.query.offset as string ?? '0';
    const offset = parseInt(strOffset);

    const userStrLimit = req.query.limit as string ?? '12';
    const userIntLimit = parseInt(userStrLimit);

    const isLimitInRange = userIntLimit > 0 && userIntLimit < 21;
    const limit = isLimitInRange ? userIntLimit : 12;

    const language = req.query.language as string ?? 'en';

    const warningStr = isLimitInRange
      ? ''
      : `The value '${userStrLimit}' for the query string 'limit' is not valid. 
          Please use a value between '1' and '20' included.`;

    const responsePayload = {
      success: false,
      references: <FirebaseFirestore.DocumentData>[],
      error: {
        reason: '',
      },
      warning: warningStr,
    };

    if (!isLangAvailable(language)) {
      res.status(400).send({
        error: {
          reason: `The language ${language} is not available. 
            Please try the following values: 'en', 'fr'.`,
        }
      });
      return;
    }

    const query = adminApp.firestore()
      .collection('references')
      .where('language', '==', language)
      .offset(offset)
      .limit(limit);

    if (startAfter) {
      const startAfterDoc = await adminApp.firestore()
        .collection('references')
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

    const references = [];

    for (const doc of snapshot.docs) {
      const docData = doc.data();
      docData.id = doc.id;
      references.push(docData);
    }

    responsePayload.references = references;
    res.send({ response: responsePayload });
  })
  .get('/:id', async (req, res) => {
    const referenceId: string = req.params.id;

    if (!referenceId) {
      res
        .status(400)
        .send(`No id was provided. Please send a valid reference's id.`);

      return;
    }

    const referenceDoc = await adminApp.firestore()
      .collection('references')
      .doc(referenceId)
      .get();

    const referenceData = referenceDoc.data();

    if (!referenceData || !referenceDoc.exists) {
      res
        .status(404)
        .send(`No reference was found for the specified id: ${referenceId}.
          Maybe the data has been deleted.`);

      return;
    }

    res.send({ response: referenceData });
  })