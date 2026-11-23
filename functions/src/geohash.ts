import { geohashForLocation } from 'geofire-common';

export type LatLng = { latitude: number; longitude: number };

// Précision 9 (~5 m), suffisante pour les requêtes de proximité de la carte.
export function geohashFor(lat: number, lng: number): string {
  return geohashForLocation([lat, lng], 9);
}

// Faux à la suppression ; sert aussi de garde-fou contre la boucle d'écriture de la function.
export function locationChanged(before?: LatLng, after?: LatLng): boolean {
  if (!after) return false;
  if (!before) return true;
  return before.latitude !== after.latitude || before.longitude !== after.longitude;
}
