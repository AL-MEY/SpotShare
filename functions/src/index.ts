import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { setGlobalOptions } from 'firebase-functions/v2';
import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { recomputeRatingStats } from './aggregates.js';

// Doit correspondre à la localisation de la base Firestore (eur3 → europe-west1).
export const REGION = 'europe-west1';

setGlobalOptions({ region: REGION });
initializeApp();

const db = getFirestore();

export const onRatingWritten = onDocumentWritten('spots/{spotId}/ratings/{uid}', (event) =>
  recomputeRatingStats(db, event.params.spotId),
);
