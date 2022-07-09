import 'package:bloc_course/bloc/person.dart';
import 'package:flutter/foundation.dart' show immutable;

// enum PersonUrl {
//   persons1,
//   persons2,
// }

// extension UrlStrin on PersonUrl {
//   String get urlString {
//     switch (this) {
//       case PersonUrl.persons1:
//         // return 'http://127.0.0.1:5500/api/persons1.json';
//         return 'http://10.0.2.2:5500/api/persons1.json';
//       case PersonUrl.persons2:
//         // return 'http://127.0.0.1:5500/api/persons2.json';
//         return 'http://10.0.2.2:5500/api/persons2.json';
//     }
//   }
// }

const persons1Url = 'http://10.0.2.2:5500/api/persons1.json';
const persons2Url = 'http://10.0.2.2:5500/api/persons2.json';

typedef PersonsLoader = Future<Iterable<Person>> Function(String url);

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonsAction implements LoadAction {
  final String url;
  final PersonsLoader loader;

  const LoadPersonsAction({
    required this.url,
    required this.loader,
  }) : super();
}
