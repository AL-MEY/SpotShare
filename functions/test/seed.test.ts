import assert from 'node:assert/strict';
import { test } from 'node:test';
import { seedSpots } from '../scripts/seed_data.js';
import { geohashFor } from '../src/geohash.js';

test('les médias du seed utilisent les types reconnus par l’app', () => {
  for (const spot of seedSpots) {
    assert.ok(spot.media.length > 0, spot.id);
    for (const m of spot.media) {
      assert.ok(m.type === 'photo' || m.type === 'video', `${spot.id}: ${m.type}`);
      if (m.type === 'video') {
        assert.ok(m.thumbnailUrl, spot.id);
        assert.ok(m.durationMs !== undefined && m.durationMs <= 60000, spot.id);
      }
    }
  }
});

test('chaque spot du seed a un geohash de 9 caractères', () => {
  for (const spot of seedSpots) {
    assert.equal(geohashFor(spot.lat, spot.lng).length, 9, spot.id);
  }
});
