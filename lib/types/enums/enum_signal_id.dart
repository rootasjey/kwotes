/// Enumerated signal ids.
/// These are unique to listen to specific changes.
enum EnumSignalId {
  /// App frame border color signal id.
  /// According to the first random quote.
  /// Used to listen to changes in app frame color.
  frameBorderColor,

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
