interface AddAppParams {
  name: string;
  description: string;
}

interface AddTempQuoteParams {
  tempQuote: ITempQuote;
}

interface CreateListParams {
  quoteIds: string[];
  idToken: string;
  name: string;
  description: string;
  isPublic: boolean;
  iconType:string;
}

interface CreateUserAccountParams {
  email: string;
  password: string;
  username: string;
}

interface DataUpdateParams {
  beforeData: FirebaseFirestore.DocumentData;
  afterData: FirebaseFirestore.DocumentData;
  payload: any;
  docId: string;
}

interface DeleteAccountParams {
  idToken: string;
}

interface DeleteAppParams {
  appId: string;
}

interface DeleteListParams {
  listId: string;
  idToken: string;
}

interface DeleteListsParams {
  listIds: string[];
  idToken: string;
}

interface GenerateNewKeysParam {
  appId: string;
  resetPrimary: boolean;
  resetSecondary: boolean;
}

interface GetRandomAuthorsParams {
  /** Id to exclude when fetching random authors. */
  except?: string;
}

interface GetRandomReferencesParams {
  /** Id to exclude when fetching random references. */
  except?: string;
}

interface IAuthor {
  born: IPointInTime
  death: IPointInTime
  fromReference: {
    id: string;
  };
  isFictional: boolean;
  id?: string;
  job: string;
  name: string;
  summary: string;
  urls: IUrls;
}

interface IFromReference {
  id: string;
}

interface IPointInTime {
  beforeJC: boolean;
  city: string;
  country: string;
  date?: FirebaseFirestore.Timestamp;
}

interface IReference {
  id?: string;
  lang: string;
  name: string;
  release: IRelease;
  summary: string;
  type: IReferenceType;
  urls: IUrls;
}

interface IRelease {
  original?: FirebaseFirestore.Timestamp;
  beforeJC: boolean;
}

interface IReferenceType {
  primary: string;
  secondary: string;
}

interface ITempQuote {
  author: IAuthor;
  comments: string[];
  createdAt: Date;
  id?: string;
  lang: string;
  name: string;
  reference: IReference;
  topics: string[];
  user: {
    id: string;
  };
  updatedAt: Date;
  validation: {
    comment: {
      name: string;
      updatedAt: Date;
    },
    status: string;
    updatedAt: Date;
  };
}

interface IUrls {
  amazon: string;
  facebook: string;
  image: string;
  instagram: string;
  netflix: string;
  primeVideo: string;
  twitch: string;
  twitter: string;
  website: string;
  wikipedia: string;
  youtube: string;
}

interface NotifFuncParams {
  userId: string;
  userData: any;
  notifSnapshot: FirebaseFirestore.QueryDocumentSnapshot;
}

interface RandomQuoteAuthoredParams {
  lang: string;
  guessType: 'author' | 'reference';
  previousQuestionsIds?: Array<string>;
}

interface UpdateEmailParams {
  newEmail: string;
  idToken: string;
}

interface UpdateAppMetadataParams {
  appId: string;
  name: string;
  description: string;
}

interface UpdateAppRightsParams {
  appId: string;
  rights: Map<string, boolean>;
}

interface UpdateDailyStatsParams {
  appDoc: FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>;
  callsLimit: number;
  date: Date;
  dayDateId: string;
}

interface UpdateListParams {
  idToken: string;
  listId: string;
  name: string;
  description: string;
  isPublic: boolean;
}

interface UpdateListItemsParams {
  quoteIds: string[];
  listId: string;
  idToken: string;
}

interface UpdateStatsParams {
  appDoc: FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>;
  date: Date;
  dateId: string;
}

interface UpdateUsernameParams {
  newUsername: string;
}

interface ValidateTempQuoteParams {
  idToken: string;
  tempQuoteId: string;
}
