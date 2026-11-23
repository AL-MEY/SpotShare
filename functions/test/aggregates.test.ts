import assert from 'node:assert/strict';
import { test } from 'node:test';
import { ratingStatsFrom } from '../src/aggregates.js';

test('ratingStatsFrom sans note donne 0 et 0', () => {
  assert.deepEqual(ratingStatsFrom(0, null), { ratingCount: 0, averageRating: 0 });
});

test('ratingStatsFrom arrondit 4.3333 à 4.33', () => {
  assert.deepEqual(ratingStatsFrom(3, 4.3333), { ratingCount: 3, averageRating: 4.33 });
});
