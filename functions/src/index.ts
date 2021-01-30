import * as functions         from 'firebase-functions';

import { apiModule }          from './api/index';

import * as developersFunc    from './developers';
import * as draftsFunc        from './drafts';
import * as favouritesFunc    from './favourites';
import * as imagesFunc        from './images';
import * as listsFunc         from './lists';
import * as notificationsFunc from './notifications';
import * as publishedFunc     from './published';
import * as quotidiansFunc    from './quotidians';
import * as searchFunc        from './search';
import * as tempQuotesFunc    from './tempQuotes';
import * as usersFunc         from './users';

export const developers     = developersFunc;
export const drafts         = draftsFunc;
export const favourites     = favouritesFunc;
export const images         = imagesFunc;
export const lists          = listsFunc;
export const notifications  = notificationsFunc;
export const published      = publishedFunc;
export const quotidians     = quotidiansFunc;
export const search         = searchFunc;
export const tempQuotes     = tempQuotesFunc;
export const users          = usersFunc;

// API
export const api = functions
  .region('us-central1')
  .https
  .onRequest(apiModule);
