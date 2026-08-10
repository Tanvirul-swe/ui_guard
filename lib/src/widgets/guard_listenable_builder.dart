import 'package:flutter/widgets.dart';

/// Lightweight builder that rebuilds when [listenable] notifies.
class GuardListenableBuilder extends StatelessWidget {
  final Listenable listenable;
  final WidgetBuilder builder;

  const GuardListenableBuilder({
    super.key,
    required this.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) => builder(context),
    );
  }
}
