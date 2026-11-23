import { AggregateField, type Firestore } from 'firebase-admin/firestore';

// Code gRPC NOT_FOUND : le document à mettre à jour n'existe plus.
const GRPC_NOT_FOUND = 5;

export function ratingStatsFrom(count: number, average: number | null) {
  return {
    ratingCount: count,
    averageRating: average === null ? 0 : Math.round(average * 100) / 100,
  };
}

// Met à jour le spot ; s'il a été supprimé entre-temps, on ignore l'erreur.
async function updateSpot(db: Firestore, spotId: string, data: Record<string, number>) {
  try {
    await db.doc(`spots/${spotId}`).update(data);
  } catch (err) {
    if ((err as { code?: unknown }).code !== GRPC_NOT_FOUND) throw err;
  }
}

export async function recomputeRatingStats(db: Firestore, spotId: string): Promise<void> {
  const snapshot = await db
    .collection(`spots/${spotId}/ratings`)
    .aggregate({
      count: AggregateField.count(),
      average: AggregateField.average('value'),
    })
    .get();
  const { count, average } = snapshot.data();
  await updateSpot(db, spotId, ratingStatsFrom(count, average));
}

// Paires collection/champ autorisées ; la tâche 22 y ajoute les favoris.
type CountTarget = { collection: 'comments'; field: 'commentCount' };

export async function recomputeCount(
  db: Firestore,
  spotId: string,
  collection: CountTarget['collection'],
  field: CountTarget['field'],
): Promise<void> {
  const snapshot = await db
    .collection(`spots/${spotId}/${collection}`)
    .count()
    .get();
  await updateSpot(db, spotId, { [field]: snapshot.data().count });
}
