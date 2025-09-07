import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_mobile/ui/home/home_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    return Center(child: Text('Welcome ${viewModel.user.name}!'));
  }
}
