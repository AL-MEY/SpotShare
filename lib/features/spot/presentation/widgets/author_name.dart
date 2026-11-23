import 'package:spotshare/features/spot/domain/entities/spot_author.dart';

// Nom affichable, ou chaîne vide si l'auteur est inconnu ou sans nom.
String authorNameOf(SpotAuthor? author) => author?.displayName.trim() ?? '';
