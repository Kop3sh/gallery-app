import 'package:bloc_course/bloc/bloc_actions.dart';
import 'package:bloc_course/bloc/person.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';

extension IsEqualIgnoringOrdering<T> on Iterable<T> {
  bool isEqualToIgnoringOrdering(Iterable<T> other) =>
      length == other.length &&
      {...this}.intersection({...other}).length == length;
}

@immutable
class FetchReuslt {
  final Iterable<Person> persons;
  final bool isRetrievedFromCache;

  const FetchReuslt({
    required this.persons,
    required this.isRetrievedFromCache,
  });

  @override
  String toString() =>
      'Fetch Result (isRetrievedFromCache = $isRetrievedFromCache, persons= $persons';

  @override
  bool operator ==(covariant FetchReuslt other) =>
      persons.isEqualToIgnoringOrdering(other.persons) &&
      isRetrievedFromCache == other.isRetrievedFromCache;

  @override
  int get hashCode => Object.hash(
        persons,
        isRetrievedFromCache,
      );
}

class PersonsBloc extends Bloc<LoadAction, FetchReuslt?> {
  final Map<String, Iterable<Person>> _cache = {};
  PersonsBloc() : super(null) {
    on<LoadPersonsAction>(
      (event, emit) async {
        final url = event.url;
        if (_cache.containsKey(url)) {
          final cachedPersons = _cache[url]!;
          final result = FetchReuslt(
            persons: cachedPersons,
            isRetrievedFromCache: true,
          );
          emit(result);
        } else {
          final loader = event.loader;
          final persons = await loader(url);
          _cache[url] = persons;
          final result =
              FetchReuslt(persons: persons, isRetrievedFromCache: false);
          emit(result);
        }
      },
    );
  }
}
