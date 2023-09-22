import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";

/// A stream subscription returning a map withing a query snapshot.
typedef DocSnapshotStreamSubscription
    = StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>;
