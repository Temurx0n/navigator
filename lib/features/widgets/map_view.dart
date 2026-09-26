import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:navigator_app/features/map/bloc/map_bloc.dart';
import 'package:navigator_app/features/map/bloc/map_event.dart';
import 'package:navigator_app/features/map/bloc/map_state.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  YandexMapController? _controller;

  bool _firstLocationMoved = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapBloc, MapState>(
      listenWhen: (previous, current) {
        // Birinchi GPS koordinata kelganda
        // kamerani user joyiga olib boramiz.
        final locationChanged =
            previous.latitude != current.latitude ||
                previous.longitude != current.longitude;

        final cameraRequested =
            previous.shouldMoveToLocation !=
                current.shouldMoveToLocation;

        return locationChanged || cameraRequested;
      },
      listener: (context, state) async {
        if (state.latitude == null ||
            state.longitude == null) {
          return;
        }

        final point = Point(
          latitude: state.latitude!,
          longitude: state.longitude!,
        );

        // Birinchi GPS kelganda avtomatik markazlashtirish.
        if (!_firstLocationMoved) {
          _firstLocationMoved = true;

          await moveToCurrentLocation(
            point,
            zoom: 17,
          );
        }

        // My Location tugmasi bosilganda.
        if (state.shouldMoveToLocation) {
          await moveToCurrentLocation(
            point,
            zoom: 17,
          );

          if (context.mounted) {
            context.read<MapBloc>().add(
              CameraMoveHandled(),
            );
          }
        }
      },
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          final route = state.routePoints
              .map(
                (point) => Point(
              latitude: point.latitude,
              longitude: point.longitude,
            ),
          )
              .toList();

          return YandexMap(
            nightModeEnabled: state.isDarkMode,

            onMapCreated: (controller) async {
              _controller = controller;

              // Yandex'ning o'z user-location layer'i.
              await controller.toggleUserLayer(
                visible: true,
                headingEnabled: false,
                autoZoomEnabled: false,
              );

              // Agar GPS xaritadan oldin kelgan bo'lsa,
              // darhol user joyiga o'tamiz.
              if (state.latitude != null &&
                  state.longitude != null &&
                  !_firstLocationMoved) {
                _firstLocationMoved = true;

                await moveToCurrentLocation(
                  Point(
                    latitude: state.latitude!,
                    longitude: state.longitude!,
                  ),
                  zoom: 17,
                );
              }
            },

            mapObjects: [
              if (route.length >= 2)
                PolylineMapObject(
                  mapId: const MapObjectId('route'),
                  polyline: Polyline(
                    points: route,
                  ),
                  strokeColor: Colors.blue,
                  strokeWidth: 5,
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> moveToCurrentLocation(
      Point point, {
        double zoom = 17,
      }) async {
    if (_controller == null) {
      return;
    }

    await _controller!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: point,
          zoom: zoom,
        ),
      ),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 1,
      ),
    );
  }
}