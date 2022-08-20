import 'package:bloc_course/bloc/app_bloc.dart';
import 'package:bloc_course/bloc/app_event.dart';
import 'package:bloc_course/bloc/app_state.dart';
import 'package:bloc_course/dialogs/loading_screen.dart';
import 'package:bloc_course/dialogs/show_auth_error.dart';
import 'package:bloc_course/views/login_view.dart';
import 'package:bloc_course/views/photo_gallery_view.dart';
import 'package:bloc_course/views/register_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppBloc>(
      create: (_) => AppBloc()
        ..add(
          const AppEventInitialze(),
        ),
      child: MaterialApp(
        title: 'Photo Library',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: BlocConsumer<AppBloc, AppState>(
          listener: (context, appState) {
            if (appState.isLoading) {
              LoadingScreen.instance()
                  .show(context: context, text: 'Loding...');
            } else {
              LoadingScreen.instance().hide();
            }

            final authError = appState.authError;
            if (authError != null) {
              showAuthErrorDialog(
                authError: authError,
                context: context,
              );
            }
          },
          builder: (context, appState) {
            if (appState is AppStateLoggedOut) {
              return const LoginView();
            } else if (appState is AppStateLoggedIn) {
              return const PhotoGalleryView();
            } else if (appState is AppStateInRegistrationView) {
              return const RegisterView();
            } else {
              return const Scaffold(
                body: Text('hello world'),
              );
            }
          },
        ),
      ),
    );
  }
}
