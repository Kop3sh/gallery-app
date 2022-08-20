import 'package:bloc_course/firebase_options.dart';
import 'package:bloc_course/views/app.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'package:firebase_core/firebase_core.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const App(),
  );
}
