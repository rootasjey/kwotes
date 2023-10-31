/// Enum for quote operation.
enum EnumQuoteOperation {
  /// Update an existing draft in validation (admin).
  adminUpdateInValidation,

  /// Create a new draft quote.
  create,

  /// Restore a deleted quote.
  restore,

  /// Update an existing draft.
  update,

  /// Validate an existing draft into a quote.
  validate,
}
