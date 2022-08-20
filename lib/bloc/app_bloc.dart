import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:bloc_course/auth/auth_errros.dart';
import 'package:bloc_course/bloc/app_event.dart';
import 'package:bloc_course/bloc/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bloc_course/utils/upload_image.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc()
      : super(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        ) {
    on<AppEventGoToRegistration>(
      (event, emit) {
        emit(
          const AppStateInRegistrationView(isLoading: false),
        );
      },
    );
    on<AppEventLogIn>(
      (event, emit) async {
        emit(
          const AppStateLoggedOut(isLoading: true),
        );
        try {
          final email = event.email;
          final password = event.password;
          final userCredentail = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          final user = userCredentail.user!;
          final images = await _getImages(user.uid);
          emit(
            AppStateLoggedIn(
              isLoading: false,
              user: user,
              images: images,
            ),
          );
        } on FirebaseAuthException catch (e) {
          emit(
            AppStateLoggedOut(
              isLoading: false,
              authError: AuthError.from(e),
            ),
          );
        }
      },
    );
    on<AppEventGoToLogin>(
      (event, emit) {
        emit(
          const AppStateLoggedOut(isLoading: false),
        );
      },
    );
    on<AppEventRegister>(
      ((event, emit) async {
        // starts loading
        emit(
          const AppStateInRegistrationView(isLoading: true),
        );
        final email = event.email;
        final password = event.password;
        try {
          final credentials = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);
          emit(
            AppStateLoggedIn(
              isLoading: false,
              user: credentials.user!,
              images: const [],
            ),
          );
        } on FirebaseAuthException catch (e) {
          emit(
            AppStateInRegistrationView(
              isLoading: false,
              authError: AuthError.from(e),
            ),
          );
        }
      }),
    );
    on<AppEventInitialze>((event, emit) async {
      // get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        );
        return;
      } else {
        // get user's uploaded images
        final images = await _getImages(user.uid);
        emit(
          AppStateLoggedIn(
            isLoading: false,
            user: user,
            images: images,
          ),
        );
      }
    });
    // handles log out event
    on<AppEventLogOut>(
      ((event, emit) async {
        emit(
          const AppStateLoggedOut(isLoading: true),
        );
        await FirebaseAuth.instance.signOut();
        emit(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        );
      }),
    );
    // handles uploading images
    on<AppEventUploadImage>(
      ((event, emit) async {
        final user = state.user;
        if (user == null) {
          //log user out if no actual user in the app state
          emit(
            const AppStateLoggedOut(isLoading: false, authError: null),
          );
          return;
        }
        // start loading
        emit(
          AppStateLoggedIn(
            isLoading: true,
            user: user,
            images: state.images ?? [],
          ),
        );
        // upload file (img)
        final file = File(event.filePathToUpload);
        await uploadImage(
          file: file,
          userId: user.uid,
        );
        // after upload is complete grab the latest file refs
        final images = await _getImages(user.uid);
        // emit new images and stops loading
        emit(
          AppStateLoggedIn(
            isLoading: false,
            user: user,
            images: images,
          ),
        );
      }),
    );
    // handles account deletion
    on<AppEventDeleteAccount>(
      ((event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        // log the user out if we don't have current user
        if (user == null) {
          emit(
            const AppStateLoggedOut(isLoading: false),
          );
          return;
        }
        // start loading
        emit(
          AppStateLoggedIn(
            isLoading: true,
            user: user,
            images: state.images ?? [],
          ),
        );
        // delete user folder
        try {
          // delete user folder
          final folderContent =
              await FirebaseStorage.instance.ref(user.uid).listAll();
          for (final item in folderContent.items) {
            await item.delete().catchError((_) {});
          }
          await FirebaseStorage.instance
              .ref(user.uid)
              .delete()
              .catchError((_) {});
          // delete user
          await user.delete();
          // log user out
          await FirebaseAuth.instance.signOut();
          emit(
            const AppStateLoggedOut(
              isLoading: false,
            ),
          );
        } on FirebaseAuthException catch (e) {
          emit(
            AppStateLoggedIn(
              isLoading: true,
              user: user,
              images: state.images ?? [],
              authError: AuthError.from(e),
            ),
          );
        } on FirebaseException {
          // we might not be able to delte the folder,
          // we log user out
          emit(
            const AppStateLoggedOut(
              isLoading: false,
            ),
          );
        }
      }),
    );
  }

  Future<Iterable<Reference>> _getImages(String userId) =>
      FirebaseStorage.instance
          .ref(userId)
          .list()
          .then((listResult) => listResult.items);
}
