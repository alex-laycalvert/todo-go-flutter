import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_mobile/ui/app/app_view_model.dart';
import 'package:todo_mobile/ui/core/widgets/alert.dart';
import 'package:todo_mobile/ui/core/widgets/button.dart';

class AppView extends StatelessWidget {
  final Widget child;

  const AppView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AppViewModel>(context);

    if (viewModel.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Alert(variant: AlertVariant.error, message: viewModel.error!),
              Button(
                variant: ButtonVariant.primary,
                text: "Retry",
                onPressed: viewModel.refetch,
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}
