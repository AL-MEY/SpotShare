///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsFr = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.fr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fr>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$app$fr app = Translations$app$fr.internal(_root);
	late final Translations$home$fr home = Translations$home$fr.internal(_root);
	late final Translations$errors$fr errors = Translations$errors$fr.internal(_root);
}

// Path: app
class Translations$app$fr {
	Translations$app$fr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'SpotShare'
	String get title => 'SpotShare';
}

// Path: home
class Translations$home$fr {
	Translations$home$fr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Bienvenue sur SpotShare'
	String get welcome => 'Bienvenue sur SpotShare';

	/// fr: 'Partage tes meilleurs spots'
	String get subtitle => 'Partage tes meilleurs spots';
}

// Path: errors
class Translations$errors$fr {
	Translations$errors$fr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$errors$network$fr network = Translations$errors$network$fr.internal(_root);
	late final Translations$errors$unauthenticated$fr unauthenticated = Translations$errors$unauthenticated$fr.internal(_root);
	late final Translations$errors$permissionDenied$fr permissionDenied = Translations$errors$permissionDenied$fr.internal(_root);
	late final Translations$errors$notFound$fr notFound = Translations$errors$notFound$fr.internal(_root);
	late final Translations$errors$unknown$fr unknown = Translations$errors$unknown$fr.internal(_root);

	/// fr: 'Réessayer'
	String get retry => 'Réessayer';

	/// fr: 'Fermer'
	String get close => 'Fermer';

	/// fr: 'Retour à l’accueil'
	String get backHome => 'Retour à l’accueil';
}

// Path: errors.network
class Translations$errors$network$fr {
	Translations$errors$network$fr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Pas de connexion'
	String get title => 'Pas de connexion';

	/// fr: 'Connexion impossible. Vérifie ton réseau.'
	String get message => 'Connexion impossible. Vérifie ton réseau.';
}

// Path: errors.unauthenticated
class Translations$errors$unauthenticated$fr {
	Translations$errors$unauthenticated$fr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Connexion requise'
	String get title => 'Connexion requise';

	/// fr: 'Connecte-toi pour continuer.'
	String get message => 'Connecte-toi pour continuer.';
}

// Path: errors.permissionDenied
class Translations$errors$permissionDenied$fr {
	Translations$errors$permissionDenied$fr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Action non autorisée'
	String get title => 'Action non autorisée';

	/// fr: 'Tu n’as pas les droits pour cette action.'
	String get message => 'Tu n’as pas les droits pour cette action.';
}

// Path: errors.notFound
class Translations$errors$notFound$fr {
	Translations$errors$notFound$fr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Introuvable'
	String get title => 'Introuvable';

	/// fr: 'Contenu introuvable.'
	String get message => 'Contenu introuvable.';
}

// Path: errors.unknown
class Translations$errors$unknown$fr {
	Translations$errors$unknown$fr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Oups'
	String get title => 'Oups';

	/// fr: 'Une erreur est survenue. Réessaie.'
	String get message => 'Une erreur est survenue. Réessaie.';
}

/// The flat map containing all translations for locale <fr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.title' => 'SpotShare',
			'home.welcome' => 'Bienvenue sur SpotShare',
			'home.subtitle' => 'Partage tes meilleurs spots',
			'errors.network.title' => 'Pas de connexion',
			'errors.network.message' => 'Connexion impossible. Vérifie ton réseau.',
			'errors.unauthenticated.title' => 'Connexion requise',
			'errors.unauthenticated.message' => 'Connecte-toi pour continuer.',
			'errors.permissionDenied.title' => 'Action non autorisée',
			'errors.permissionDenied.message' => 'Tu n’as pas les droits pour cette action.',
			'errors.notFound.title' => 'Introuvable',
			'errors.notFound.message' => 'Contenu introuvable.',
			'errors.unknown.title' => 'Oups',
			'errors.unknown.message' => 'Une erreur est survenue. Réessaie.',
			'errors.retry' => 'Réessayer',
			'errors.close' => 'Fermer',
			'errors.backHome' => 'Retour à l’accueil',
			_ => null,
		};
	}
}
