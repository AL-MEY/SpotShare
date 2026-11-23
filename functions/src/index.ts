import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { setGlobalOptions } from 'firebase-functions/v2';
import {
  onDocumentCreated,
  onDocumentDeleted,
  onDocumentWritten,
} from 'firebase-functions/v2/firestore';
import { recomputeCount, recomputeRatingStats, updateSpot } from './aggregates.js';
import { geohashFor, locationChanged } from './geohash.js';

// Doit correspondre à la localisation de la base Firestore (eur3 → europe-west1).
export const REGION = 'europe-west1';

setGlobalOptions({ region: REGION });
initializeApp();

const db = getFirestore();

const comments = { collection: 'comments', field: 'commentCount' } as const;
const favorites = { collection: 'favorites', field: 'favoriteCount' } as const;

export const onRatingWritten = onDocumentWritten('spots/{spotId}/ratings/{uid}', (event) =>
  recomputeRatingStats(db, event.params.spotId),
);

export const onCommentCreated = onDocumentCreated('spots/{spotId}/comments/{commentId}', (event) =>
  recomputeCount(db, event.params.spotId, comments),
);

export const onCommentDeleted = onDocumentDeleted('spots/{spotId}/comments/{commentId}', (event) =>
  recomputeCount(db, event.params.spotId, comments),
);

export const onFavoriteCreated = onDocumentCreated('spots/{spotId}/favorites/{uid}', (event) =>
  recomputeCount(db, event.params.spotId, favorites),
);

export const onFavoriteDeleted = onDocumentDeleted('spots/{spotId}/favorites/{uid}', (event) =>
  recomputeCount(db, event.params.spotId, favorites),
);

// Ne réécrit rien si la position est inchangée : sans cette garde, l'écriture du geohash relancerait la function.
export const onSpotWritten = onDocumentWritten('spots/{spotId}', (event) => {
  const before = event.data?.before.data()?.location;
  const after = event.data?.after.data()?.location;
  if (!locationChanged(before, after)) return;
  return updateSpot(db, event.params.spotId, {
    geohash: geohashFor(after.latitude, after.longitude),
  });
});
