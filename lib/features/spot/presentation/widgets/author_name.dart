import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/features/spot/domain/entities/spot_author.dart';

// Nom affichable, ou chaîne vide si l'auteur est inconnu ou sans nom.
String authorNameOf(SpotAuthor? author) => author?.displayName.trim() ?? '';

// Premier chargement en cours : ni nom ni « Auteur inconnu », pour éviter un clignotement.
bool isAuthorPending(AsyncValue<SpotAuthor?> author) =>
    !author.hasValue && !author.hasError;
