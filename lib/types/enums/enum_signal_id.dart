/// Enumerated signal ids.
/// These are unique to listen to specific changes.
enum EnumSignalId {
  /// Navigation bar signal id.
  /// Used to listen to changes in navigation bar
  /// (like when it should be displayed or hidden).
  navigationBar,

  /// Firebase auth signal id.
  /// Used to listen to changes in firebase authentication.
  userAuth,

  /// Firestore signal id.
  /// Used to listen to changes in firestore.
  userFirestore,
}
