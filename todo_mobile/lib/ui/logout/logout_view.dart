import 'package:todo_mobile/router/routes.dart';
import 'package:todo_mobile/ui/core/widgets/alert.dart';
import 'package:todo_mobile/ui/core/widgets/button.dart';
import 'package:todo_mobile/ui/logout/logout_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LogoutView extends StatelessWidget {
  const LogoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LogoutViewModel>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 20.0,
        children: [
          const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 18.0),
          ),
          if (viewModel.error != null)
            Alert(variant: AlertVariant.error, message: viewModel.error!),
          SizedBox(
            width: 200,
            child: Button(
              variant: ButtonVariant.danger,
              text: viewModel.loggingOut ? 'Logging out...' : 'Logout',
              onPressed: viewModel.loggingOut
                  ? null
                  : () {
                      viewModel.logout(() {
                        context.go(Routes.login);
                      });
                    },
            ),
          ),
        ],
      ),
    );
  }
}
