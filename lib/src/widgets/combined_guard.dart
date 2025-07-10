import 'package:flutter/material.dart';
import '../core/guard.dart';
import '../core/guard_utils.dart';

/// A flexible access control widget that combines roles, permissions,
/// and custom conditions into a single guard.
class CombinedGuard extends StatelessWidget {
  final Guard guard;

  /// Required roles the user must have.
  final List<String> requiredRoles;

  /// Required permissions the user must have.
  final List<String> requiredPermissions;

  /// Optional additional custom condition (e.g., environment flags, business rules).
  final bool Function()? condition;

  /// Widget shown if access is granted.
  final WidgetBuilder builder;

  /// Optional fallback if access is denied.
  final WidgetBuilder? fallbackBuilder;

  const CombinedGuard({
    super.key,
    required this.guard,
    this.requiredRoles = const [],
    this.requiredPermissions = const [],
    this.condition,
    required this.builder,
    this.fallbackBuilder,
  });

  bool _hasAccess() {
    return GuardUtils.evaluate(
      guard: guard,
      requiredRoles: requiredRoles,
      requiredPermissions: requiredPermissions,
      condition: condition,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _hasAccess()
        ? builder(context)
        : (fallbackBuilder?.call(context) ?? const SizedBox.shrink());
  }
}
