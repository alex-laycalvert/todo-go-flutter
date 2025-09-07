import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:todo_mobile/ui/core/tags.dart';
import 'package:todo_mobile/ui/core/widgets/alert.dart';
import 'package:todo_mobile/ui/core/widgets/button.dart';
import 'package:todo_mobile/ui/todo/todo_view_model.dart';

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<TodoViewModel>(context, listen: false);
      viewModel.fetchTodo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TodoViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, viewModel),
        Expanded(child: _buildBody(context, viewModel)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, TodoViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 4.0),
      child: Row(
        children: [
          BackButton(onPressed: () => context.pop()),
          Hero(
            tag: Tags.todoTitle(viewModel.todoId),
            child: Text(
              viewModel.todo?.title ?? viewModel.todoTitle ?? 'Todo',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, TodoViewModel viewModel) {
    if (viewModel.fetching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Alert(
                variant: AlertVariant.error,
                message: 'Error: ${viewModel.error}',
              ),
              Button(
                variant: ButtonVariant.primary,
                text: "Retry",
                onPressed: () {
                  viewModel.fetchTodo();
                },
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.todo == null) {
      return const Center(child: Text('No data'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(viewModel.todo!.description),
          Button(
            variant: ButtonVariant.primary,
            text: "Mark Complete",
            onPressed: viewModel.completeTodo,
          ),
        ],
      ),
    );
  }
}
