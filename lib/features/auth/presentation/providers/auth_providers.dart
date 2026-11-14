import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spotshare/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:spotshare/features/auth/domain/entities/app_user.dart';
import 'package:spotshare/features/auth/domain/repositories/auth_repository.dart';
import 'package:spotshare/features/auth/domain/usecases/send_password_reset_email.dart';
import 'package:spotshare/features/auth/domain/usecases/sign_in.dart';
import 'package:spotshare/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:spotshare/features/auth/domain/usecases/sign_out.dart';
import 'package:spotshare/features/auth/domain/usecases/sign_up.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(FirebaseAuth.instance, GoogleSignIn.instance),
);

final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).watchUser(),
);

final signInProvider = Provider(
  (ref) => SignIn(ref.watch(authRepositoryProvider)),
);

final signUpProvider = Provider(
  (ref) => SignUp(ref.watch(authRepositoryProvider)),
);

final signOutProvider = Provider(
  (ref) => SignOut(ref.watch(authRepositoryProvider)),
);

final sendPasswordResetEmailProvider = Provider(
  (ref) => SendPasswordResetEmail(ref.watch(authRepositoryProvider)),
);

final signInWithGoogleProvider = Provider(
  (ref) => SignInWithGoogle(ref.watch(authRepositoryProvider)),
);
