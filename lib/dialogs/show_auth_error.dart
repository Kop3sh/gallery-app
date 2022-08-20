import 'package:bloc_course/auth/auth_errros.dart';
import 'package:bloc_course/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart' show BuildContext;

Future<void> showAuthErrorDialog({
  required BuildContext context,
  required AuthError authError,
}) {
  return showGenericDialog<void>(
    context: context,
    title: authError.dialogTitle,
    content: authError.dialogText,
    optionBuilder: () => {
      'OK': true,
    },
  );
}
