import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:spotshare/features/auth/domain/entities/app_user.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

class _MockGoogleAccount extends Mock implements GoogleSignInAccount {}

class _FakeAuthCredential extends Fake implements AuthCredential {}

class _MockUser extends Mock implements User {}

class _MockUserCredential extends Mock implements UserCredential {}

void main() {
  late _MockFirebaseAuth auth;
  late _MockGoogleSignIn google;
  late FirebaseAuthRepository repository;

  setUpAll(() => registerFallbackValue(_FakeAuthCredential()));

  setUp(() {
    auth = _MockFirebaseAuth();
    google = _MockGoogleSignIn();
    when(() => google.initialize()).thenAnswer((_) async {});
    repository = FirebaseAuthRepository(auth, google);
  });

  void whenSignInThrows(Object error) {
    when(
      () => auth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(error);
  }

  Future<void> signIn() => repository.signIn(email: 'a@b.c', password: 'pw');

  test('convertit l’utilisateur Firebase en AppUser', () {
    final user = _MockUser();
    when(() => user.uid).thenReturn('uid');
    when(() => user.email).thenReturn('a@b.c');
    when(() => auth.currentUser).thenReturn(user);
    when(() => auth.authStateChanges())
        .thenAnswer((_) => Stream.fromIterable([user, null]));

    const expected = AppUser(id: 'uid', email: 'a@b.c');
    expect(repository.currentUser, expected);
    expect(repository.watchUser(), emitsInOrder([expected, null]));
  });

  test('connecte avec l’e-mail et le mot de passe fournis', () async {
    when(() => auth.signInWithEmailAndPassword(email: 'a@b.c', password: 'pw'))
        .thenAnswer((_) async => _MockUserCredential());

    await signIn();

    verify(
      () => auth.signInWithEmailAndPassword(email: 'a@b.c', password: 'pw'),
    ).called(1);
  });

  test('renvoie InvalidCredentialsFailure sur de mauvais identifiants', () {
    whenSignInThrows(FirebaseAuthException(code: 'invalid-credential'));

    expect(signIn(), throwsA(isA<InvalidCredentialsFailure>()));
  });

  test('renvoie NetworkFailure quand le réseau est indisponible', () {
    whenSignInThrows(FirebaseAuthException(code: 'network-request-failed'));

    expect(signIn(), throwsA(isA<NetworkFailure>()));
  });

  test('connecte à Firebase avec le jeton Google', () async {
    final account = _MockGoogleAccount();
    when(() => account.authentication)
        .thenReturn(const GoogleSignInAuthentication(idToken: 'token'));
    when(() => google.authenticate()).thenAnswer((_) async => account);
    when(() => auth.signInWithCredential(any()))
        .thenAnswer((_) async => _MockUserCredential());

    await repository.signInWithGoogle();

    final credential =
        verify(() => auth.signInWithCredential(captureAny())).captured.single
            as OAuthCredential;
    expect(credential.idToken, 'token');
  });

  test('n’échoue pas quand l’utilisateur annule la connexion Google', () async {
    when(() => google.authenticate()).thenThrow(
      const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
    );

    await repository.signInWithGoogle();

    verifyNever(() => auth.signInWithCredential(any()));
  });

  test('renvoie UnknownFailure sur une erreur de configuration Google', () {
    when(() => google.authenticate()).thenThrow(
      const GoogleSignInException(
        code: GoogleSignInExceptionCode.clientConfigurationError,
      ),
    );

    expect(repository.signInWithGoogle(), throwsA(isA<UnknownFailure>()));
  });

  test('déconnecte aussi le compte Google', () async {
    when(() => auth.signOut()).thenAnswer((_) async {});
    when(() => google.signOut()).thenAnswer((_) async {});

    await repository.signOut();

    verify(() => auth.signOut()).called(1);
    verify(() => google.signOut()).called(1);
  });

  test('envoie l’e-mail de réinitialisation', () async {
    when(() => auth.sendPasswordResetEmail(email: 'a@b.c'))
        .thenAnswer((_) async {});

    await repository.sendPasswordResetEmail('a@b.c');

    verify(() => auth.sendPasswordResetEmail(email: 'a@b.c')).called(1);
  });

  test('ne révèle pas qu’un e-mail est inconnu à la réinitialisation', () {
    when(() => auth.sendPasswordResetEmail(email: any(named: 'email')))
        .thenThrow(FirebaseAuthException(code: 'user-not-found'));

    expect(repository.sendPasswordResetEmail('a@b.c'), completes);
  });

  test('renvoie NetworkFailure si la réinitialisation échoue hors ligne', () {
    when(() => auth.sendPasswordResetEmail(email: any(named: 'email')))
        .thenThrow(FirebaseAuthException(code: 'network-request-failed'));

    expect(
      repository.sendPasswordResetEmail('a@b.c'),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('renvoie EmailAlreadyUsedFailure à l’inscription', () {
    when(
      () => auth.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

    expect(
      repository.signUp(email: 'a@b.c', password: 'pw'),
      throwsA(isA<EmailAlreadyUsedFailure>()),
    );
  });
}
