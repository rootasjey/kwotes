interface AddAppParams {
  name: string;
  description: string;
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

interface UpdateStatsParams {
  appDoc: FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>;
  date: Date;
  dateId: string;
}

interface UpdateUsernameParams {
  newUsername: string;
}
