/// Represents a detailed access-control decision.
class AccessDecision {
  final bool allowed;
  final List<String> missingRoles;
  final List<String> missingPermissions;
  final bool failedCondition;
  final String? reasonCode;

  const AccessDecision({
    required this.allowed,
    this.missingRoles = const [],
    this.missingPermissions = const [],
    this.failedCondition = false,
    this.reasonCode,
  });

  factory AccessDecision.allow() => const AccessDecision(allowed: true);

  factory AccessDecision.deny({
    List<String> missingRoles = const [],
    List<String> missingPermissions = const [],
    bool failedCondition = false,
    String? reasonCode,
  }) {
    return AccessDecision(
      allowed: false,
      missingRoles: missingRoles,
      missingPermissions: missingPermissions,
      failedCondition: failedCondition,
      reasonCode: reasonCode,
    );
  }
}
