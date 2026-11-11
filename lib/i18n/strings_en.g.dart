///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsEn extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final TranslationsEn _root = this; // ignore: unused_field

	@override 
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$app$en app = _Translations$app$en._(_root);
	@override late final _Translations$home$en home = _Translations$home$en._(_root);
	@override late final _Translations$welcome$en welcome = _Translations$welcome$en._(_root);
	@override late final _Translations$login$en login = _Translations$login$en._(_root);
	@override late final _Translations$onboarding$en onboarding = _Translations$onboarding$en._(_root);
	@override late final _Translations$errors$en errors = _Translations$errors$en._(_root);
}

// Path: app
class _Translations$app$en extends Translations$app$fr {
	_Translations$app$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'SpotShare';
}

// Path: home
class _Translations$home$en extends Translations$home$fr {
	_Translations$home$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Welcome to SpotShare';
	@override String get subtitle => 'Share your best spots';
	@override String get signOut => 'Sign out';
}

// Path: welcome
class _Translations$welcome$en extends Translations$welcome$fr {
	_Translations$welcome$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get tagline => 'Share your best spots';
	@override String get start => 'Get started';
	@override String get alreadyHaveAccount => 'I already have an account';
}

// Path: login
class _Translations$login$en extends Translations$login$fr {
	_Translations$login$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Sign in';
	@override String get continueWithGoogle => 'Continue with Google';
}

// Path: onboarding
class _Translations$onboarding$en extends Translations$onboarding$fr {
	_Translations$onboarding$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Welcome';
}

// Path: errors
class _Translations$errors$en extends Translations$errors$fr {
	_Translations$errors$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$errors$network$en network = _Translations$errors$network$en._(_root);
	@override late final _Translations$errors$unauthenticated$en unauthenticated = _Translations$errors$unauthenticated$en._(_root);
	@override late final _Translations$errors$permissionDenied$en permissionDenied = _Translations$errors$permissionDenied$en._(_root);
	@override late final _Translations$errors$notFound$en notFound = _Translations$errors$notFound$en._(_root);
	@override late final _Translations$errors$invalidCredentials$en invalidCredentials = _Translations$errors$invalidCredentials$en._(_root);
	@override late final _Translations$errors$emailAlreadyUsed$en emailAlreadyUsed = _Translations$errors$emailAlreadyUsed$en._(_root);
	@override late final _Translations$errors$weakPassword$en weakPassword = _Translations$errors$weakPassword$en._(_root);
	@override late final _Translations$errors$unknown$en unknown = _Translations$errors$unknown$en._(_root);
	@override String get retry => 'Try again';
	@override String get close => 'Close';
	@override String get backHome => 'Back to home';
}

// Path: errors.network
class _Translations$errors$network$en extends Translations$errors$network$fr {
	_Translations$errors$network$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'No connection';
	@override String get message => 'Can’t connect. Check your network.';
}

// Path: errors.unauthenticated
class _Translations$errors$unauthenticated$en extends Translations$errors$unauthenticated$fr {
	_Translations$errors$unauthenticated$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Sign-in required';
	@override String get message => 'Sign in to continue.';
}

// Path: errors.permissionDenied
class _Translations$errors$permissionDenied$en extends Translations$errors$permissionDenied$fr {
	_Translations$errors$permissionDenied$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Not allowed';
	@override String get message => 'You’re not allowed to do this.';
}

// Path: errors.notFound
class _Translations$errors$notFound$en extends Translations$errors$notFound$fr {
	_Translations$errors$notFound$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Not found';
	@override String get message => 'Content not found.';
}

// Path: errors.invalidCredentials
class _Translations$errors$invalidCredentials$en extends Translations$errors$invalidCredentials$fr {
	_Translations$errors$invalidCredentials$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Wrong credentials';
	@override String get message => 'Check your email and password.';
}

// Path: errors.emailAlreadyUsed
class _Translations$errors$emailAlreadyUsed$en extends Translations$errors$emailAlreadyUsed$fr {
	_Translations$errors$emailAlreadyUsed$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Email already in use';
	@override String get message => 'An account already exists with this email. Sign in instead.';
}

// Path: errors.weakPassword
class _Translations$errors$weakPassword$en extends Translations$errors$weakPassword$fr {
	_Translations$errors$weakPassword$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Password too weak';
	@override String get message => 'Pick a longer password.';
}

// Path: errors.unknown
class _Translations$errors$unknown$en extends Translations$errors$unknown$fr {
	_Translations$errors$unknown$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Oops';
	@override String get message => 'Something went wrong. Try again.';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.title' => 'SpotShare',
			'home.welcome' => 'Welcome to SpotShare',
			'home.subtitle' => 'Share your best spots',
			'home.signOut' => 'Sign out',
			'welcome.tagline' => 'Share your best spots',
			'welcome.start' => 'Get started',
			'welcome.alreadyHaveAccount' => 'I already have an account',
			'login.title' => 'Sign in',
			'login.continueWithGoogle' => 'Continue with Google',
			'onboarding.title' => 'Welcome',
			'errors.network.title' => 'No connection',
			'errors.network.message' => 'Can’t connect. Check your network.',
			'errors.unauthenticated.title' => 'Sign-in required',
			'errors.unauthenticated.message' => 'Sign in to continue.',
			'errors.permissionDenied.title' => 'Not allowed',
			'errors.permissionDenied.message' => 'You’re not allowed to do this.',
			'errors.notFound.title' => 'Not found',
			'errors.notFound.message' => 'Content not found.',
			'errors.invalidCredentials.title' => 'Wrong credentials',
			'errors.invalidCredentials.message' => 'Check your email and password.',
			'errors.emailAlreadyUsed.title' => 'Email already in use',
			'errors.emailAlreadyUsed.message' => 'An account already exists with this email. Sign in instead.',
			'errors.weakPassword.title' => 'Password too weak',
			'errors.weakPassword.message' => 'Pick a longer password.',
			'errors.unknown.title' => 'Oops',
			'errors.unknown.message' => 'Something went wrong. Try again.',
			'errors.retry' => 'Try again',
			'errors.close' => 'Close',
			'errors.backHome' => 'Back to home',
			_ => null,
		};
	}
}
