class GeoPosition {
  const GeoPosition({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      other is GeoPosition &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
