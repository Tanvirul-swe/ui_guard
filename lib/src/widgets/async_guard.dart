import 'package:flutter/material.dart';

import '../core/guard.dart';
import 'access_guard.dart';

/// Signature for a builder that receives loaded user roles.
typedef AsyncRoleBuilder = Widget Function(
  BuildContext context,
  List<String> roles,
);

/// A widget that asynchronously loads user roles (e.g. from secure storage,
/// remote API, or auth services) and renders child guards once resolved.
///
/// ### Example (Issue #5 Planned API):
/// ```dart
/// AsyncGuard(
///   roleFuture: loadUserRolesFromServer(),
///   builder: (context, roles) => AccessGuard(
///     guard: Guard()..setUserRoles(roles),
///     requiredRoles: ['admin'],
///     builder: (_) => const Text("Admin Dashboard"),
///   ),
/// );
/// ```
///
/// Or using the convenience constructor [AsyncGuard.guard]:
/// ```dart
/// AsyncGuard.guard(
///   roleFuture: loadUserRolesFromServer(),
///   requiredRoles: ['admin'],
///   builder: (_) => const Text("Admin Dashboard"),
///   fallbackBuilder: (_) => const Text("Access Denied"),
/// );
/// ```
class AsyncGuard extends StatefulWidget {
  /// The future that delivers user roles.
  final Future<List<String>>? roleFuture;

  /// A function that returns a future for user roles.
  ///
  /// Preferred when instantiating directly in `build` methods to prevent
  /// re-triggering the future on parent rebuilds.
  final Future<List<String>> Function()? roleLoader;

  /// Builder invoked once roles are successfully resolved.
  final AsyncRoleBuilder builder;

  /// Optional widget builder shown while waiting for roles to load.
  final WidgetBuilder? loadingBuilder;

  /// Optional widget shown while waiting for roles to load.
  final Widget? loading;

  /// Optional builder shown if [roleFuture] / [roleLoader] throws an error.
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  )? errorBuilder;

  /// Optional widget shown if [roleFuture] / [roleLoader] throws an error.
  final Widget? error;

  /// Optional callback invoked when loading fails with an error.
  final void Function(Object error, StackTrace? stackTrace)? onError;

  /// Optional callback invoked when roles are successfully loaded.
  final void Function(List<String> roles)? onLoaded;

  /// Initial roles used before the future completes.
  final List<String>? initialRoles;

  const AsyncGuard({
    super.key,
    this.roleFuture,
    this.roleLoader,
    required this.builder,
    this.loadingBuilder,
    this.loading,
    this.errorBuilder,
    this.error,
    this.onError,
    this.onLoaded,
    this.initialRoles,
  }) : assert(
          roleFuture != null || roleLoader != null,
          'Either roleFuture or roleLoader must be provided to AsyncGuard.',
        );

  /// Convenience constructor that automatically gates content using [AccessGuard].
  AsyncGuard.guard({
    super.key,
    this.roleFuture,
    this.roleLoader,
    required List<String> requiredRoles,
    required WidgetBuilder builder,
    WidgetBuilder? fallbackBuilder,
    this.loadingBuilder,
    this.loading,
    this.errorBuilder,
    this.error,
    this.onError,
    this.onLoaded,
    this.initialRoles,
  })  : builder = ((context, roles) => AccessGuard(
              guard: Guard()..setUserRoles(roles),
              requiredRoles: requiredRoles,
              builder: builder,
              fallbackBuilder: fallbackBuilder,
            )),
        assert(
          roleFuture != null || roleLoader != null,
          'Either roleFuture or roleLoader must be provided to AsyncGuard.',
        );

  @override
  State<AsyncGuard> createState() => _AsyncGuardState();
}

class _AsyncGuardState extends State<AsyncGuard> {
  late Future<List<String>> _future;
  bool _hasNotifiedSuccess = false;

  @override
  void initState() {
    super.initState();
    _initFuture();
  }

  void _initFuture() {
    _hasNotifiedSuccess = false;
    if (widget.roleLoader != null) {
      _future = widget.roleLoader!();
    } else {
      _future = widget.roleFuture!;
    }
  }

  @override
  void didUpdateWidget(AsyncGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.roleFuture != null && widget.roleFuture != oldWidget.roleFuture) ||
        (widget.roleLoader != null && widget.roleLoader != oldWidget.roleLoader)) {
      setState(() {
        _initFuture();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _future,
      initialData: widget.initialRoles,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error!;
          final stackTrace = snapshot.stackTrace;
          widget.onError?.call(error, stackTrace);

          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, error, stackTrace);
          }
          if (widget.error != null) {
            return widget.error!;
          }
          return const SizedBox.shrink();
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          if (widget.loadingBuilder != null) {
            return widget.loadingBuilder!(context);
          }
          if (widget.loading != null) {
            return widget.loading!;
          }
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        final roles = snapshot.data ?? const <String>[];
        if (snapshot.connectionState == ConnectionState.done &&
            !_hasNotifiedSuccess) {
          _hasNotifiedSuccess = true;
          if (widget.onLoaded != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                widget.onLoaded!(roles);
              }
            });
          }
        }

        return widget.builder(context, roles);
      },
    );
  }
}
