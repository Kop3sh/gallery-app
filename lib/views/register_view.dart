import 'package:bloc_course/bloc/app_bloc.dart';
import 'package:bloc_course/bloc/app_event.dart';
import 'package:bloc_course/extensions/if_debugging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterView extends HookWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emailController =
        useTextEditingController(text: 'example@domain.com'.ifDebugging);
    final passwordController =
        useTextEditingController(text: '123456'.ifDebugging);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rgister'),
      ),
      body: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              hintText: 'Enter your email here...',
            ),
            keyboardType: TextInputType.emailAddress,
            keyboardAppearance: Brightness.dark,
          ),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              hintText: 'Enter your password here',
            ),
            keyboardAppearance: Brightness.dark,
            obscureText: true,
            obscuringCharacter: '*',
          ),
          TextButton(
            onPressed: () {
              final email = emailController.text;
              final password = passwordController.text;
              context
                  .read<AppBloc>()
                  .add(AppEventRegister(email: email, password: password));
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppBloc>().add(const AppEventGoToLogin());
            },
            child: const Text('Already registered? Log in here!'),
          ),
        ],
      ),
    );
  }
}
