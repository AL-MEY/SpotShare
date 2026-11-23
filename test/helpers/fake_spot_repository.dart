import 'dart:async';

import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/domain/repositories/spot_repository.dart';

class FakeSpotRepository implements SpotRepository {
  FakeSpotRepository({this.spot, List<Spot>? recent}) : recent = recent ?? [];

  Spot? spot;
  List<Spot> recent;
  Failure? failure;
  final requestedRecentLimits = <int>[];
  final spotController = StreamController<Spot>.broadcast();
  final _recentController = StreamController<List<Spot>>.broadcast();

  Future<void> dispose() async {
    await spotController.close();
    await _recentController.close();
  }

  void emit(Spot spot) {
    this.spot = spot;
    spotController.add(spot);
  }

  void emitRecent(List<Spot> spots) {
    recent = spots;
    _recentController.add(spots);
  }

  // Pousse une erreur dans les flux ouverts.
  void emitFailure(Failure failure) {
    spotController.addError(failure);
    _recentController.addError(failure);
  }

  @override
  Stream<Spot> watchSpot(String spotId) async* {
    final failure = this.failure;
    if (failure != null) throw failure;
    final current = spot;
    if (current != null && current.id == spotId) yield current;
    yield* spotController.stream.where((s) => s.id == spotId);
  }

  @override
  Stream<List<Spot>> watchRecentSpots({int limit = 20}) async* {
    requestedRecentLimits.add(limit);
    final failure = this.failure;
    if (failure != null) throw failure;
    yield recent;
    yield* _recentController.stream;
  }
}
