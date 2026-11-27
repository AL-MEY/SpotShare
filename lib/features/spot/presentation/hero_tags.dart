// Même tag côté liste et fiche : l'image du spot voyage d'un écran à l'autre.
String spotMediaHeroTag(String spotId, int index) =>
    index == 0 ? 'spot-image-$spotId' : 'spot-media-$spotId-$index';
