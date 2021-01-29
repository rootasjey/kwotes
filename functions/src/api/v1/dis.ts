import * as express from 'express';
import { adminApp } from '../../adminApp';
import { 
  getRandomAuthors, 
  getRandomQuoteAuthored,
  getRandomReferences,
} from '../utils';

export const disRouter = express.Router()
  .get('/random', async (req, res, next) => {
    const responsePayload = {
      question: {
        quoteId: '',
        quoteName: '',
        guessType: 'author',
      },
      proposals: {
        type: 'author',
        values: Array<FirebaseFirestore.DocumentData>(),
      },
      requestState: {
        success: false,
        error: {
          reason: '',
        },
        warning: '',
      },
    };

    // 1. Get a random quote with available author or reference.
    let randQuoteRes: RandQuoteResp;

    try { randQuoteRes = await getRandomQuoteAuthored(); } 
    catch (error) { next(error); return; }

    const selectedQuote = randQuoteRes.quote;

    if (!selectedQuote) {
      res.status(404).send({
        error: {
          reason: `Sorry, but we couldn't find a suitable quote. 
            Please try again.`,
        }
      });
      return;
    }

    // 2.1. If the returned quote has a known author,
    //      fetch this author's data to include in proposals.
    if (randQuoteRes.guessType === 'author') {
      let answerAuthorSnap: FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>;

      try {
        answerAuthorSnap = await adminApp.firestore()
          .collection('authors')
          .doc(selectedQuote.author.id)
          .get();
      } catch (error) {
        next(error);
        return;
      }
      
      const answerAuthorData = answerAuthorSnap.data();

      if (!answerAuthorData) {
        res.status(404).send({
          error: {
            reason: `Sorry, but we couldn't find a suitable author answer. 
            Please try again.`,
          }
        });
        return;
      }

      answerAuthorData.id = answerAuthorSnap.id;
      responsePayload.proposals.values.push(answerAuthorData);
    }
    
    // 2.2. If the returned quote has a known reference,
    //      fetch this author's data to include in proposals.
    if (randQuoteRes.guessType === 'reference') {
      let answerReferenceSnap: FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>; 

      try {
        answerReferenceSnap = await adminApp.firestore()
          .collection('references')
          .doc(selectedQuote.mainReference.id)
          .get();
      } catch (error) {
        next(error);
        return;
      }

      const answerReferenceData = answerReferenceSnap.data();

      if (!answerReferenceData) {
        res.status(404).send({
          error: {
            reason: `Sorry, but we couldn't find a suitable reference answer. 
            Please try again.`,
          }
        });
        return;
      }

      answerReferenceData.id = answerReferenceSnap.id;
      responsePayload.proposals.values.push(answerReferenceData);
    }

    // 3.1. If the answer is an author, fetch 2 more random authors.
    if (randQuoteRes.guessType === 'author') {
      let randAuthorsRes: RandomMapArray;

      try { randAuthorsRes = await getRandomAuthors(); } 
      catch (error) { next(error); return; }
      
      responsePayload.proposals.type = randAuthorsRes.type;
      responsePayload.proposals.values.push(...randAuthorsRes.values);
    }
    
    // 3.2. If the answer is a reference, fetch 2 more random references.
    if (randQuoteRes.guessType === 'reference') {
      let randReferencesRes: RandomMapArray;

      try { randReferencesRes = await getRandomReferences(); } 
      catch (error) { next(error); return; }

      responsePayload.proposals.type = randReferencesRes.type;
      responsePayload.proposals.values.push(...randReferencesRes.values);
    }

    // 4. Prepare the response payload.
    responsePayload.question.guessType = randQuoteRes.guessType;
    responsePayload.question.quoteId = selectedQuote.id;
    responsePayload.question.quoteName = selectedQuote.name;

    responsePayload.requestState.success = true;

    res.send({ response: responsePayload });
  })
  .post('/validate', async (req, res, next) => {
    const { answer, question } = req.body;

    const responsePayload = {
      question,
      answer,
      requestState: {
        success: false,
        error: {
          reason: '',
        },
        warning: '',
      },
    };

    const checkResult = checkValidateRouteParams(req.body);
    
    if (!checkResult.success) {
      res.status(400).send({
        error: {
          reason: checkResult.message,
        },
      });
      return;
    }

    let quoteSnap: FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>;

    try {
      quoteSnap = await adminApp.firestore()
        .collection('quotes')
        .doc(question.quoteId)
        .get();
      
    } catch (error) {
      next(error);
      return;
    }

    const quoteSnapData = quoteSnap.data();

    if (!quoteSnapData) {
      res.status(404).send({
        error: {
          reason: `Sorry, we couldn't fetch the data. 
            This is either due to a bad network or the quote's id does not exist. 
            Please try again.`,
        },
      });
      return;
    }

    if (question.guessType === 'author') {
      responsePayload.answer.isCorrect = 
        quoteSnapData.author.id === answer.value;
    }

    if (question.guessType === 'reference') {
      responsePayload.answer.isCorrect = 
        quoteSnapData.mainReference.id === answer.value;
    }

    res.send({ response: responsePayload });
  });

function checkValidateRouteParams(body: any) {
  const { answer, question } = body;
  const result = {
    success: true,
    message: '',
  };

  if (!answer) {
    result.success = false;
    result.message = `This endpoint must be called with a valid [answer] object. 
      The [answer] object should have 1 property filled with a string value 
      which is an author's id or a reference's id. 
      [answer.value] = 'author|reference's id.'`;
  }
  
  if (!answer.value) {
    result.success = false;
    result.message = `The request body is missing the following property [answer.value]. 
      This endpoint must be called with a valid [answer] object. 
      The [answer] object should have 1 property filled with a string value 
      which is an author's id or a reference's id. 
      [answer.value] = 'author|reference's id.'`;
  }
  
  if (!question) {
    result.success = false;
    result.message = `This endpoint must be called with a valid [question] object. 
      The [question] object should have 2 properties [question.quoteId] 
      which a string, and [question.guessType] which is also a string.`;
  }
  
  if (!question.guessType) {
    result.success = false;
    result.message = `The request body is missing the following property [question.guessType]. 
      This endpoint must be called with a valid [question] object. 
      The [question] object should have 2 properties [question.quoteId] which a string, 
      and [question.guessType] which is also a string.`;
  }
  
  if (question.guessType !== 'author' && question.guessType !== 'reference') {
    result.success = false;
    result.message = `The property [question.guessType] should either 
      be equal to 'author' or 'reference'. Any other values are invalid.`;
  }
    
    if (!question.quoteId) {
      result.success = false;
      result.message = `The request body is missing the following property [question.quoteId]. 
        This endpoint must be called with a valid [question] object. 
        The [question] object should have 2 properties [question.quoteId] 
        which a string, and [question.guessType] which is also a string.`;
    }

  return result;
}

interface RandQuoteResp {
  quote?: FirebaseFirestore.DocumentData;
  guessType: string;
}

interface RandomMapArray {
  type: string;
  values: any[];
}
