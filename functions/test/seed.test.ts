import assert from 'node:assert/strict';
import { test } from 'node:test';
import { seedSpots } from '../scripts/seed_data.js';

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
