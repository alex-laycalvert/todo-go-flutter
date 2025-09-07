import 'package:todo_mobile/ui/add_todo/add_todo_view_model.dart';
import 'package:todo_mobile/ui/core/widgets/alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_mobile/ui/core/widgets/button.dart';

class AddTodoView extends StatelessWidget {
  const AddTodoView({super.key, required this.onAdded});

  final VoidCallback onAdded;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddTodoViewModel>(context);

    return Padding(
      padding: const EdgeInsets.only(
        top: 32.0,
        left: 32.0,
        right: 32.0,
        bottom: 64.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20.0,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Add Todo",
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Form(
            key: viewModel.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 20.0,
              children: [
                TextFormField(
                  controller: viewModel.formControllers['title'],
                  validator: viewModel.formValidators['title'],
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    enabled: !viewModel.adding,
                  ),
                ),
                TextFormField(
                  controller: viewModel.formControllers['description'],
                  validator: viewModel.formValidators['description'],
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                    enabled: !viewModel.adding,
                  ),
                ),
                if (viewModel.error != null)
                  Alert(variant: AlertVariant.error, message: viewModel.error!),
                Button(
                  variant: ButtonVariant.primary,
                  text: viewModel.adding ? "Adding..." : "Add Todo",
                  onPressed: viewModel.adding
                      ? null
                      : () {
                          if (!viewModel.formKey.currentState!.validate()) {
                            return;
                          }

                          viewModel.addTodo(() {
                            onAdded();
                            Navigator.of(context).pop();
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
