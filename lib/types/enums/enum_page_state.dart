/// Different page's states.
enum EnumPageState {
  /// Check if the username is available.
  checkingUsername,

  /// Creating a new list.
  creatingList,

  /// Loading data.
  loading,

  /// Loading more data.
  loadingMore,

  /// Waiting for user input.
  idle,

  /// An error occurred on data laod or after a user input.
  error,

  /// Loading author's data.
  loadingAuthor,

  /// Loading reference's data.
  loadingReference,

  /// Looking for data results according of the user input.
  searching,

  /// Looking for more data results according of the user input.
  searchingMore,

  /// Submitting a quote for validation.
  submittingQuote,

  /// Updating a quote.
  updatingQuote,

  /// Validating a quote.
  validatingQuote,
}
