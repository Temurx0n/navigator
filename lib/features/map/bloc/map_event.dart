abstract class MapEvent {}

class MapStarted extends MapEvent {}

class GetCurrentLocation extends MapEvent {}

class MapLocationUpdated extends MapEvent {
  final double latitude;
  final double longitude;

  MapLocationUpdated({
    required this.latitude,
    required this.longitude,
  });
}

class MapThemeChanged extends MapEvent {
  final bool isDark;

  MapThemeChanged(this.isDark);
}

class MapLanguageChanged extends MapEvent {
  final String language;

  MapLanguageChanged(this.language);
}

class InternetStatusChanged extends MapEvent {
  final bool hasInternet;

  InternetStatusChanged(this.hasInternet);
}
class CameraMoveRequested extends MapEvent {}

class CameraMoveHandled extends MapEvent {}