import assert from 'node:assert/strict';
import { test } from 'node:test';
import { geohashFor, locationChanged } from '../src/geohash.js';

const paris = { latitude: 48.8584, longitude: 2.2945 };

test('geohashFor(48.8584, 2.2945) vaut u09tunquc', () => {
  assert.equal(geohashFor(48.8584, 2.2945), 'u09tunquc');
});

test('locationChanged est faux quand la position ne bouge pas', () => {
  assert.equal(locationChanged(paris, { ...paris }), false);
});

test('locationChanged est vrai quand la position bouge', () => {
  assert.equal(locationChanged(paris, { ...paris, longitude: 2.3 }), true);
});

test('locationChanged est vrai à la création', () => {
  assert.equal(locationChanged(undefined, paris), true);
});

test('locationChanged est faux à la suppression', () => {
  assert.equal(locationChanged(paris, undefined), false);
});
