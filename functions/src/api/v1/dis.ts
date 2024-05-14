import * as express from 'express';
import { adminApp } from '../../adminApp';
import { 
  checkAPIKey,
  getRandomAuthors, 
  getRandomIntInclusive, 
  getRandomQuoteAuthored,
  getRandomReferences,
} from '../utils';

export const disRouter = express.Router()
  .use(checkAPIKey)
  .get('/random', async (req, res, next) => {
    const language = req.query?.language as string ?? 'en';
    const guessStrType = req.query?.guessType as string ?? '';

    let guessType: ('author' | 'reference') = 'author';

    if (guessStrType) {
      guessType = guessStrType === 'author'
        ? 'author'
        : 'reference';
      } else {
      const rand = getRandomIntInclusive(0, 1);
      guessType = rand === 0 
        ? 'author' 
        : 'reference';
    }

    const responsePayload = {
      question: {
        guessType: 'author',
        quote: {
          id: '',
          name: '',
          topics: [],
        }
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

    try { 
      randQuoteRes = await getRandomQuoteAuthored({
        language,
        guessType,
      }); 

      // 2nd try if no authored quote is found.
      if (!randQuoteRes.quote) {
        randQuoteRes = await getRandomQuoteAuthored({
          language,
          guessType,
        });
      }
    } catch (error) { 
      next(error); 
      return; 
    }

    const selectedQuote = randQuoteRes.quote;

    if (!selectedQuote) {
      res.status(500).send({
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
          .doc(selectedQuote.reference.id)
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
    responsePayload.question.quote.id = selectedQuote.id;
    responsePayload.question.quote.name = selectedQuote.name;
    responsePayload.question.quote.topics = selectedQuote.topics;

    responsePayload.requestState.success = true;

    res.send({ response: responsePayload });
  })
  .post('/random', async (req, res, next) => {
    let language = req.query?.language as string ?? 'en';
    let guessStrType = req.query?.guessType as string ?? '';

    language = req.body.language ?? language;
    guessStrType = req.body.guessType ?? guessStrType;

    const previousQuestionsIdsStr: string = req.body.previousQuestionsIds;
    const previousQuestionsIds: Array<string> = JSON.parse(previousQuestionsIdsStr);

    let guessType: ('author' | 'reference') = 'author';

    if (guessStrType) {
      guessType = guessStrType === 'author'
        ? 'author'
        : 'reference';
    } else {
      const rand = getRandomIntInclusive(0, 1);
      guessType = rand === 0
        ? 'author'
        : 'reference';
    }

    const responsePayload = {
      question: {
        guessType: 'author',
        quote: {
          id: '',
          name: '',
          topics: [],
        }
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

    try {
      randQuoteRes = await getRandomQuoteAuthored({
        language,
        guessType,
        previousQuestionsIds,
      });

      // 2nd try if no authored quote is found.
      if (!randQuoteRes.quote) {
        randQuoteRes = await getRandomQuoteAuthored({
          language,
          guessType,
          previousQuestionsIds,
        });
      }
    } catch (error) {
      next(error);
      return;
    }

    const selectedQuote = randQuoteRes.quote;

    if (!selectedQuote) {
      res.status(500).send({
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
    //      fetch this reference's data to include in proposals.
    if (randQuoteRes.guessType === 'reference') {
      let answerReferenceSnap: FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>;

      try {
        answerReferenceSnap = await adminApp.firestore()
          .collection('references')
          .doc(selectedQuote.reference.id)
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

      try { 
        randAuthorsRes = await getRandomAuthors({ 
          except: selectedQuote.author.id 
        }); 
      }
      catch (error) { 
        next(error); 
        return; 
      }

      responsePayload.proposals.type = randAuthorsRes.type;
      responsePayload.proposals.values.push(...randAuthorsRes.values);
    }

    // 3.2. If the answer is a reference, fetch 2 more random references.
    if (randQuoteRes.guessType === 'reference') {
      let randReferencesRes: RandomMapArray;

      try { 
        randReferencesRes = await getRandomReferences({ 
          except: selectedQuote.reference.id 
        }); 
      }
      catch (error) { 
        next(error); 
        return; 
      }

      responsePayload.proposals.type = randReferencesRes.type;
      responsePayload.proposals.values.push(...randReferencesRes.values);
    }

    // 4. Prepare the response payload.
    responsePayload.question.guessType = randQuoteRes.guessType;
    responsePayload.question.quote.id = selectedQuote.id;
    responsePayload.question.quote.name = selectedQuote.name;
    responsePayload.question.quote.topics = selectedQuote.topics;

    responsePayload.requestState.success = true;

    res.send({ response: responsePayload });
  })
  .post('/check', async (req, res, next) => {
    const answerProposalId: string = req.body.answerProposalId;
    const guessType: string = req.body.guessType;
    const quoteId: string = req.body.quoteId;

    const responsePayload = {
      question: {
        guessType,
        quote: {
          id: quoteId,
        },
      },
      answerProposalId,
      isCorrect: false,
      correction: {
        id: '',
        name: '',
      },
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
        .doc(quoteId)
        .get();
      
    } catch (error) {
      next(error);
      return;
    }

    const quoteSnapData = quoteSnap.data();

    if (!quoteSnapData) {
      res.status(500).send({
        error: {
          reason: `Sorry, we couldn't fetch the data. 
            This is either due to a bad network or the quote's id does not exist. 
            Please try again.`,
        },
      });
      return;
    }

    if (guessType === 'author') {
      responsePayload.isCorrect = 
        quoteSnapData.author.id === answerProposalId;

      if (!responsePayload.isCorrect) {
        responsePayload.correction = {
          id: quoteSnapData.author.id,
          name: quoteSnapData.author.name,
        };
      }
    }

    if (guessType === 'reference') {
      responsePayload.isCorrect = 
        quoteSnapData.reference.id === answerProposalId;

      if (!responsePayload.isCorrect) {
        responsePayload.correction = {
          id: quoteSnapData.reference.id,
          name: quoteSnapData.reference.name,
        };
      }
    }    

    responsePayload.requestState.success = true;
    res.send({ response: responsePayload });
  });

function checkValidateRouteParams(body: any) {
  const answerProposalId: string = body.answerProposalId;
  const guessType: string = body.guessType;
  const quoteId: string = body.quoteId;

  const result = {
    success: true,
    message: '',
  };

  if (!answerProposalId) {
    result.success = false;
    result.message = `The request body is missing the following property [answerProposalId]. 
      [answerProposalId] is a string reprensenting a reference or an author id.`;
  }
  
  if (!guessType) {
    result.success = false;
    result.message = `The request body is missing the following property [guessType]. 
      [guessType] is a string equals to either 'author' or 'reference'`;
  }
  
  if (!quoteId) {
    result.success = false;
    result.message = `The request body is missing the following property [quoteId]. 
      [quoteId] is a string representing the quote to guess.`;
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
