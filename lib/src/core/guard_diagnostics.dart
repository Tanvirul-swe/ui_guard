import 'package:flutter/foundation.dart';

import 'access_decision.dart';

/// Debug helper for access-control logs.
class GuardDiagnostics {
  static bool enabled = false;

  static void logDecision(String source, AccessDecision decision) {
    if (!enabled || kReleaseMode) return;

    final details = <String>[];
    if (decision.missingRoles.isNotEmpty) {
      details.add('missingRoles=${decision.missingRoles.join(',')}');
    }
    if (decision.missingPermissions.isNotEmpty) {
      details.add('missingPermissions=${decision.missingPermissions.join(',')}');
    }
    if (decision.failedCondition) {
      details.add('failedCondition=true');
    }
    if (decision.reasonCode != null) {
      details.add('reasonCode=${decision.reasonCode}');
    }

    debugPrint(
      '[ui_guard][$source] allowed=${decision.allowed}${details.isEmpty ? '' : ' | ${details.join(' | ')}'}',
    );
  }
}
