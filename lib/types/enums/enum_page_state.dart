/// Different page's states.
enum EnumPageState {
  /// Buying an in app purchase.
  buyingInAppPurchase,

  /// Buying a subscription.
  buyingSubscription,

  /// Check if the username is available.
  checkingUsername,

  /// Check if the email is available.
  checkingEmail,

  /// Creating a new account.
  creatingAccount,

  /// Creating a new list.
  creatingList,

  /// An action has been completed.
  done,

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

  /// Loading quotes.
  loadingQuotes,

  /// Loading random quotes.
  loadingRandomQuotes,

  /// Loading reference's data.
  loadingReference,

  /// Opening the app store.
  openingStore,

  /// Looking for data results according of the user input.
  searching,

  /// Looking for more data results according of the user input.
  searchingMore,

  /// Submitting a quote for validation.
  submittingQuote,

  /// Updating a quote.
  updatingQuote,

  /// Updating an email.
  updatingEmail,

  /// Updating a password.
  updatingPassword,

  /// Updating a username.
  updatingUsername,

  /// Validating a quote.
  validatingQuote,
}
