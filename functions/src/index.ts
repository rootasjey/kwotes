import * as functions         from 'firebase-functions';

import { apiModule }          from './api/index';

import * as developersFunc    from './developers';
import * as imagesFunc        from './images';
import * as listsFunc         from './lists';
import * as mentionsFunc      from './mentions';
import * as notificationsFunc from './notifications';
import * as quotidiansFunc    from './quotidians';
import * as quotesFunc        from './quotes';
import * as searchFunc        from './search';
import * as statsFunc         from './stats';
import * as tempQuotesFunc    from './tempQuotes';
import * as usersFunc         from './users';

export const developers     = developersFunc;
export const images         = imagesFunc;
export const lists          = listsFunc;
export const notifications  = notificationsFunc;
export const mentions       = mentionsFunc;
export const quotidians     = quotidiansFunc;
export const quotes         = quotesFunc;
export const search         = searchFunc;
export const stats          = statsFunc;
export const tempQuotes     = tempQuotesFunc;
export const users          = usersFunc;

// API
export const api = functions
  .region('us-central1')
  .https
  .onRequest(apiModule);
