import 'package:flutter/material.dart';
import './language_button.dart';
import './location_buttons.dart';
import './theme_button.dart';

class MapControls extends StatelessWidget {
  const MapControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 50,
          right: 70,
          child: ThemeButton(),
        ),

        const Positioned(
          top: 50,
          right: 16,
          child: LanguageButton(),
        ),



        const Positioned(
          bottom: 30,
          right: 16,
          child: LocationButton(),
        ),

      ],
    );
  }
}