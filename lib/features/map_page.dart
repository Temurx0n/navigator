import 'package:flutter/material.dart';

import './widgets/map_controls.dart';
import './widgets/map_view.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          MapView(),
          MapControls(),
        ],
      ),
    );
  }
}