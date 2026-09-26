import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../map/bloc/map_bloc.dart';
import '../map/bloc/map_event.dart';
import '../map/bloc/map_state.dart';

class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (previous, current) =>
      previous.isDarkMode != current.isDarkMode,
      builder: (context, state) {
        return FloatingActionButton(
          mini: true,
          heroTag: 'theme_button',
          onPressed: () {
            context.read<MapBloc>().add(
              MapThemeChanged(!state.isDarkMode),
            );
          },
          child: Icon(
            state.isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode,
          ),
        );
      },
    );
  }
}