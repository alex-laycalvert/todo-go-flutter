import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:todo_mobile/router/routes.dart';
import 'package:todo_mobile/ui/configure/configure_view_model.dart';
import 'package:todo_mobile/ui/core/widgets/alert.dart';
import 'package:todo_mobile/ui/core/widgets/button.dart';

class ConfigureView extends StatelessWidget {
  const ConfigureView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ConfigureViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            key: viewModel.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 20.0,
              children: [
                TextFormField(
                  controller: viewModel.formControllers['name'],
                  validator: viewModel.formValidators['name'],
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    enabled: !viewModel.configuring,
                  ),
                ),
                if (viewModel.error != null)
                  Alert(variant: AlertVariant.error, message: viewModel.error!),
                Button(
                  variant: ButtonVariant.primary,
                  text: 'Save',
                  onPressed: viewModel.configuring
                      ? null
                      : () {
                          viewModel.configure(() {
                            context.go(Routes.home);
                          });
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
