import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_mobile/router/routes.dart';
import 'package:todo_mobile/ui/add_todo/add_todo_view.dart';
import 'package:todo_mobile/ui/add_todo/add_todo_view_model.dart';
import 'package:todo_mobile/ui/core/tags.dart';
import 'package:todo_mobile/ui/core/widgets/alert.dart';
import 'package:todo_mobile/ui/core/widgets/button.dart';
import 'package:todo_mobile/ui/todos/todos_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class TodosView extends StatefulWidget {
  const TodosView({super.key});

  @override
  State<TodosView> createState() => _TodosViewState();
}

class _TodosViewState extends State<TodosView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<TodosViewModel>(context, listen: false);
      viewModel.fetchTodos(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TodosViewModel>(context);

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SearchBar(
                hintText: 'Search todos',
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: viewModel.searchController,
                onSubmitted: (value) {
                  viewModel.fetchTodos(value);
                },
                enabled: !viewModel.fetching && viewModel.error == null,
              ),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(fixedSize: const Size(200, 40)),
              onPressed: viewModel.searchController.text.isEmpty
                  ? null
                  : () {
                      viewModel.searchController.clear();
                      viewModel.fetchTodos(null);
                    },
              label: const Text('Clear search'),
              icon: const Icon(Icons.clear),
            ),
            Expanded(child: _buildBody(context, viewModel)),
          ],
        ),

        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  useRootNavigator: true,
                  context: context,
                  builder: (context) {
                    return ChangeNotifierProvider(
                      create: (_) =>
                          AddTodoViewModel(todoRepository: context.read()),
                      child: AddTodoView(
                        onAdded: () {
                          viewModel.fetchTodos(viewModel.searchController.text);
                        },
                      ),
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, TodosViewModel viewModel) {
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
                  viewModel.fetchTodos(viewModel.searchController.text);
                },
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.todos.isEmpty) {
      return const Center(child: Text('No data'));
    }

    return ListView.builder(
      itemCount: viewModel.todos.length,
      itemBuilder: (context, index) {
        final todo = viewModel.todos[index];
        return Slidable(
          endActionPane: ActionPane(
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: viewModel.completing
                    ? null
                    : (context) {
                        viewModel.completeTodo(todo.id);
                      },
                icon: Icons.check,
                label: 'Done',
              ),
            ],
          ),
          child: ListTile(
            title: Hero(tag: Tags.todoTitle(todo.id), child: Text(todo.title)),
            subtitle: Text(todo.description),
            onTap: () {
              context.push(Routes.todoWithId(todo.id), extra: todo);
            },
          ),
        );
      },
    );
  }
}
