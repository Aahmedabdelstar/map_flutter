import 'package:flutter/material.dart';
import './theMap.dart';
import 'package:map_launcher/map_launcher.dart';

void main() => runApp(MapLauncherDemo());

class MapLauncherDemo extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: theMapClass(),
    );
  }
}