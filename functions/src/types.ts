
interface DataUpdateParams {
  beforeData: FirebaseFirestore.DocumentData;
  afterData: FirebaseFirestore.DocumentData;
  payload: any;
  docId: string;
}

interface NotifFuncParams {
  userData: any;
  notifSnapshot: FirebaseFirestore.QueryDocumentSnapshot;
}
