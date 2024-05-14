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
  from_reference: {
    id: string;
  };
  image: ImageProp;
  is_fictional: boolean;
  id?: string;
  job: string;
  job_localized: {};
  name: string;
  summary: string;
  summary_localized: {};
  urls: IUrls;
}

interface ImageCredits {
  before_common_era: boolean;
  company: string;
  date?: FirebaseFirestore.Timestamp | null;
  location: string;
  name: string;
  artist: string;
  url: string;
}

interface ImageProp {
  credits: ImageCredits;
}

interface IFromReference {
  id: string;
}

interface IPointInTime {
  before_common_era: boolean;
  city: string;
  country: string;
  date?: FirebaseFirestore.Timestamp | null;
}

interface IReference {
  id?: string;
  image: ImageProp;
  language: string;
  name: string;
  release: IRelease;
  summary: string;
  type: IReferenceType;
  urls: IUrls;
}

interface IRelease {
  original?: FirebaseFirestore.Timestamp | null;
  before_common_era: boolean;
}

interface IReferenceType {
  primary: string;
  secondary: string;
}

interface ITempQuote {
  author: IAuthor;
  comments: string[];
  created_at: Date;
  id?: string;
  language: string;
  name: string;
  reference: IReference;
  topics: string[];
  user: {
    id: string;
  };
  updated_at: Date;
  validation: {
    comment: {
      name: string;
      updated_at: Date;
    },
    status: string;
    updated_at: Date;
  };
}

interface IUrls {
  amazon: string;
  facebook: string;
  image: string;
  image_name: string;
  imdb: string;
  instagram: string;
  netflix: string;
  prime_video: string;
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
  language: string;
  guessType: 'author' | 'reference';
  previousQuestionsIds?: Array<string>;
}

interface TopicMap {
  [key: string]: boolean;
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
