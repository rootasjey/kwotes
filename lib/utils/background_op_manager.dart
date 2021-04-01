import 'package:fig_style/types/background_op.dart';
import 'package:flutter/widgets.dart';

/// A simple background operation manager
/// used to follow long running tasks.
class BackgroundOpManager {
  static BuildContext context;

  /// All operations related to quotes lists.
  static final listOp = Map<String, BackgroundOp>();

  /// Add a new list operation. Typically a delete list operation.
  static addListOp(BackgroundOp operation) {
    listOp.putIfAbsent(operation.itemId, () => operation);
  }

  /// Save context for reuse.
  static void setContext(BuildContext ctx) {
    context = ctx;
  }

  /// Set the target id operation's state to done.
  static void setOpDone(String id) {
    if (listOp.containsKey(id)) {
      listOp.remove(id);
    }
  }
}
