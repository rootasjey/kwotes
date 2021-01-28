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

interface DeleteListParams {
  listId: string;
  idToken: string;
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

interface UpdateUsernameParams {
  newUsername: string;
}
