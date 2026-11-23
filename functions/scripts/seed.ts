import { initializeApp } from 'firebase-admin/app';
import { GeoPoint, getFirestore, Timestamp } from 'firebase-admin/firestore';
import { ratingStatsFrom } from '../src/aggregates.js';
import {
  BASE_DATE,
  commentPool,
  HOUR_MS,
  seedSpots as spots,
  users,
} from './seed_data.js';

const DEV_PROJECT_ID = 'spotshare-dev-b6185';

function parseProject(argv: string[]): string | undefined {
  const i = argv.indexOf('--project');
  return i >= 0 ? argv[i + 1] : undefined;
}

async function main() {
  const projectId = parseProject(process.argv.slice(2));
  if (projectId !== DEV_PROJECT_ID) {
    console.error(
      `Refus : le seed ne tourne que sur le projet dev (${DEV_PROJECT_ID}). ` +
        `Usage : npm run seed -- --project ${DEV_PROJECT_ID}` +
        (projectId ? ` (reçu : ${projectId})` : ''),
    );
    process.exit(1);
  }

  initializeApp({ projectId });
  const db = getFirestore();
  const batch = db.batch();
  const userIds = users.map((u) => u.id);

  users.forEach((u, i) => {
    batch.set(db.doc(`users/${u.id}`), {
      displayName: u.displayName,
      bio: u.bio,
      avatarUrl: null,
      updatedAt: Timestamp.fromMillis(BASE_DATE + i * HOUR_MS),
    });
  });

  spots.forEach((spot, s) => {
    const spotTime = BASE_DATE + s * 24 * HOUR_MS;

    // Chaque utilisateur sauf l'auteur note le spot (valeur 3 à 5, déterministe).
    const raters = userIds.filter((id) => id !== spot.authorId);
    const values = raters.map((_, r) => 3 + ((s + r) % 3));
    raters.forEach((uid, r) => {
      batch.set(db.doc(`spots/${spot.id}/ratings/${uid}`), {
        value: values[r],
        updatedAt: Timestamp.fromMillis(spotTime + (r + 1) * HOUR_MS),
      });
    });

    for (let n = 1; n <= spot.commentCount; n++) {
      batch.set(db.doc(`spots/${spot.id}/comments/seed-comment-${s + 1}-${n}`), {
        authorId: userIds[(s + n) % userIds.length],
        text: commentPool[(s + n) % commentPool.length],
        createdAt: Timestamp.fromMillis(spotTime + (n + 2) * HOUR_MS),
      });
    }

    // Mêmes compteurs que ceux écrits par les Cloud Functions.
    const average = values.length === 0 ? null : values.reduce((sum, v) => sum + v, 0) / values.length;
    batch.set(db.doc(`spots/${spot.id}`), {
      title: spot.title,
      description: spot.description,
      category: spot.category,
      address: spot.address,
      location: new GeoPoint(spot.lat, spot.lng),
      media: spot.media,
      tags: spot.tags,
      authorId: spot.authorId,
      createdAt: Timestamp.fromMillis(spotTime),
      ...ratingStatsFrom(values.length, average),
      commentCount: spot.commentCount,
      favoriteCount: 0,
    });
  });

  await batch.commit();
  console.log(`Seed terminé sur ${projectId} : ${spots.length} spots, ${users.length} profils.`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
