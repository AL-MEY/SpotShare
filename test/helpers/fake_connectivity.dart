import 'package:connectivity_plus/connectivity_plus.dart';

class FakeConnectivity implements Connectivity {
  FakeConnectivity({bool online = true})
    : _results = [online ? ConnectivityResult.wifi : ConnectivityResult.none];

  final List<ConnectivityResult> _results;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _results;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}
