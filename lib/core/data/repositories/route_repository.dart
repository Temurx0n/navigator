import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class RouteRepository {
  final FirebaseFirestore _firestore;
  final Connectivity _connectivity;

  RouteRepository({
    FirebaseFirestore? firestore,
    Connectivity? connectivity,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _connectivity = connectivity ?? Connectivity();

  Future<bool> _hasInternet() async {
    final result = await _connectivity.checkConnectivity();

    return result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.ethernet);
  }

  Future<void> savePoint(Point point) async {
    final hasInternet = await _hasInternet();

    if (hasInternet) {
      await _firestore.collection('routes').add({
        'latitude': point.latitude,
        'longitude': point.longitude,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await uploadPendingPoints();
      return;
    }

    await _saveLocally(point);
  }

  Future<void> _saveLocally(Point point) async {
    final prefs = await SharedPreferences.getInstance();

    final localPoints =
        prefs.getStringList('pending_route_points') ?? [];

    localPoints.add(
      jsonEncode({
        'latitude': point.latitude,
        'longitude': point.longitude,
      }),
    );

    await prefs.setStringList(
      'pending_route_points',
      localPoints,
    );
  }

  Future<void> uploadPendingPoints() async {
    if (!await _hasInternet()) return;

    final prefs = await SharedPreferences.getInstance();

    final localPoints =
        prefs.getStringList('pending_route_points') ?? [];

    if (localPoints.isEmpty) return;

    for (final item in localPoints) {
      final data = jsonDecode(item);

      await _firestore.collection('routes').add({
        'latitude': data['latitude'],
        'longitude': data['longitude'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await prefs.remove('pending_route_points');
  }
}