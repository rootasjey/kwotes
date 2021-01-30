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

interface NotifFuncParams {
  userId: string;
  userData: any;
  notifSnapshot: FirebaseFirestore.QueryDocumentSnapshot;
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

interface UpdateUsernameParams {
  newUsername: string;
}
