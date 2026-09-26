import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:navigator_app/services/notification_service.dart';
import 'package:navigator_app/core/data/repositories/route_repository.dart';
import 'package:navigator_app/services/location_service.dart';

import './map_event.dart';
import './map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final LocationService locationService;
  final RouteRepository routeRepository;
  final Connectivity connectivity;
  final NotificationService notificationService;


  Timer? _locationTimer;
  StreamSubscription<List<ConnectivityResult>>?
  _connectivitySubscription;

  MapBloc({
    LocationService? locationService,
    RouteRepository? routeRepository,
    Connectivity? connectivity,
    NotificationService? notificationService,
  })  : locationService =
      locationService ?? LocationService(),
        routeRepository =
            routeRepository ?? RouteRepository(),
        connectivity =
            connectivity ?? Connectivity(),
  notificationService =
  notificationService ?? NotificationService(),
        super(const MapState()) {
    on<MapStarted>(_onMapStarted);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<MapLocationUpdated>(_onLocationUpdated);
    on<MapThemeChanged>(_onThemeChanged);
    on<MapLanguageChanged>(_onLanguageChanged);
    on<InternetStatusChanged>(
      _onInternetStatusChanged,
    );
    on<CameraMoveRequested>(
      _onCameraMoveRequested,
    );
    on<CameraMoveHandled>(
      _onCameraMoveHandled,
    );
  }

  Future<void> _onMapStarted(
      MapStarted event,
      Emitter<MapState> emit,
      ) async {
    emit(
      state.copyWith(
        isLoading: true,
      ),
    );

    await _checkInternet();

    _listenToConnectivity();

    await _requestLocation();

    emit(
      state.copyWith(
        isLoading: false,
      ),
    );
  }

  Future<void> _requestLocation() async {
    final serviceEnabled =
    await locationService.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    var permission =
    await locationService.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await locationService.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    await _getLocation();

    _locationTimer?.cancel();

    _locationTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) {
        add(
          GetCurrentLocation(),
        );
      },
    );
  }

  Future<void> _getLocation() async {
    try {
      final position =
      await locationService.getCurrentPosition();

      add(
        MapLocationUpdated(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (e) {
      print('Location error: $e');
    }
  }

  Future<void> _onGetCurrentLocation(
      GetCurrentLocation event,
      Emitter<MapState> emit,
      ) async {
    await _getLocation();
  }

  Future<void> _onLocationUpdated(
      MapLocationUpdated event,
      Emitter<MapState> emit,
      ) async {
    final newPoint = MapPoint(
      latitude: event.latitude,
      longitude: event.longitude,
    );

    double distance = 0;

    if (state.routePoints.isNotEmpty) {
      final previous = state.routePoints.last;

      distance = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        newPoint.latitude,
        newPoint.longitude,
      );
    }

    final previousDistance = state.totalDistance;
    final newTotalDistance =
        previousDistance + distance;

    final previousHundreds =
    (previousDistance / 100).floor();

    final newHundreds =
    (newTotalDistance / 100).floor();

    emit(
      state.copyWith(
        latitude: event.latitude,
        longitude: event.longitude,
        routePoints: [
          ...state.routePoints,
          newPoint,
        ],
        totalDistance: newTotalDistance,
      ),
    );

    await routeRepository.savePoint(
      Point(
        latitude: newPoint.latitude,
        longitude: newPoint.longitude,
      ),
    );

    if (newHundreds > previousHundreds) {
      for (
      int i = previousHundreds + 1;
      i <= newHundreds;
      i++
      ) {
        final reachedDistance = i * 100.0;

        await notificationService
            .showDistanceNotification(
          reachedDistance,
        );
      }
    }
  }

  Future<void> _checkInternet() async {
    final result =
    await connectivity.checkConnectivity();

    final connected = result.any(
          (item) =>
      item == ConnectivityResult.wifi ||
          item == ConnectivityResult.mobile ||
          item == ConnectivityResult.ethernet,
    );

    add(
      InternetStatusChanged(connected),
    );
  }

  void _listenToConnectivity() {
    _connectivitySubscription?.cancel();

    _connectivitySubscription =
        connectivity.onConnectivityChanged.listen(
              (results) {
            final connected = results.any(
                  (item) =>
              item == ConnectivityResult.wifi ||
                  item == ConnectivityResult.mobile ||
                  item == ConnectivityResult.ethernet,
            );

            add(
              InternetStatusChanged(connected),
            );

            if (connected) {
              routeRepository.uploadPendingPoints();
            }
          },
        );
  }

  void _onInternetStatusChanged(
      InternetStatusChanged event,
      Emitter<MapState> emit,
      ) {
    emit(
      state.copyWith(
        hasInternet: event.hasInternet,
      ),
    );
  }

  void _onThemeChanged(
      MapThemeChanged event,
      Emitter<MapState> emit,
      ) {
    emit(
      state.copyWith(
        isDarkMode: event.isDark,
      ),
    );
  }

  void _onLanguageChanged(
      MapLanguageChanged event,
      Emitter<MapState> emit,
      ) {
    emit(
      state.copyWith(
        language: event.language,
      ),
    );
  }

  Future<void> _onCameraMoveRequested(
      CameraMoveRequested event,
      Emitter<MapState> emit,
      ) async {
    await _getLocation();

    emit(
      state.copyWith(
        shouldMoveToLocation: true,
      ),
    );
  }

  void _onCameraMoveHandled(
      CameraMoveHandled event,
      Emitter<MapState> emit,
      ) {
    emit(
      state.copyWith(
        shouldMoveToLocation: false,
      ),
    );
  }

  @override
  Future<void> close() {
    _locationTimer?.cancel();
    _connectivitySubscription?.cancel();

    return super.close();
  }
}