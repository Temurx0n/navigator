class MapState {
  final bool isLoading;
  final bool isDarkMode;
  final String language;

  final double? latitude;
  final double? longitude;

  final double totalDistance;

  final List<MapPoint> routePoints;
  final bool shouldMoveToLocation;

  final bool hasInternet;

  const MapState({
    this.isLoading = false,
    this.isDarkMode = false,
    this.language = 'uz',
    this.latitude,
    this.longitude,
    this.totalDistance = 0,
    this.routePoints = const [],
    this.hasInternet = true,
    this.shouldMoveToLocation = false,
  });

  MapState copyWith({
    bool? isLoading,
    bool? isDarkMode,
    String? language,
    double? latitude,
    double? longitude,
    double? totalDistance,
    List<MapPoint>? routePoints,
    bool? hasInternet,
    bool? shouldMoveToLocation,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalDistance:
      totalDistance ?? this.totalDistance,
      routePoints:
      routePoints ?? this.routePoints,
      hasInternet:
      hasInternet ?? this.hasInternet,
      shouldMoveToLocation:
      shouldMoveToLocation ??
          this.shouldMoveToLocation,
    );
  }
}

class MapPoint {
  final double latitude;
  final double longitude;

  const MapPoint({
    required this.latitude,
    required this.longitude,
  });
}