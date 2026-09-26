import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../map/bloc/map_bloc.dart';
import '../map/bloc/map_event.dart';

class LocationButton extends StatelessWidget {
  const LocationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'location_button',
      onPressed: () {
        context.read<MapBloc>().add(
          CameraMoveRequested(),
        );
      },
      child: const Icon(Icons.my_location),
    );
  }
}