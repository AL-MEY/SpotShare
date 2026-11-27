import assert from 'node:assert/strict';
import { test } from 'node:test';
import type { Firestore } from 'firebase-admin/firestore';
import { ratingStatsFrom, recomputeCount } from '../src/aggregates.js';

test('ratingStatsFrom sans note donne 0 et 0', () => {
  assert.deepEqual(ratingStatsFrom(0, null), { ratingCount: 0, averageRating: 0 });
});

test('ratingStatsFrom arrondit 4.3333 à 4.33', () => {
  assert.deepEqual(ratingStatsFrom(3, 4.3333), { ratingCount: 3, averageRating: 4.33 });
});

test('recomputeCount écrit le compte de la sous-collection dans le bon champ', async () => {
  const calls: { path: string; data: unknown }[] = [];
  const db = {
    collection: (path: string) => ({
      count: () => ({ get: async () => ({ data: () => ({ count: path.endsWith('favorites') ? 3 : 8 }) }) }),
    }),
    doc: (path: string) => ({
      update: async (data: unknown) => {
        calls.push({ path, data });
      },
    }),
  } as unknown as Firestore;

  await recomputeCount(db, 's1', { collection: 'favorites', field: 'favoriteCount' });
  await recomputeCount(db, 's1', { collection: 'comments', field: 'commentCount' });

  assert.deepEqual(calls, [
    { path: 'spots/s1', data: { favoriteCount: 3 } },
    { path: 'spots/s1', data: { commentCount: 8 } },
  ]);
});
