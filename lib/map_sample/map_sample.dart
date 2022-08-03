import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final _controller = Completer<GoogleMapController>();

  static const _googlePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 4.4746,
  );

  static const _googlePlexMarker = Marker(
    markerId: MarkerId('_googlePlexMarker'),
    infoWindow: InfoWindow(title: 'Google Plex'),
    position: LatLng(37.42796133580664, -122.085749655962),
  );

  static const _lake = CameraPosition(
    bearing: 192.8334901395799,
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
    target: LatLng(37.43296265331129, -122.08832357078792),
  );

  static final _lakeMarker = Marker(
    markerId: const MarkerId('_lakeMarker'),
    infoWindow: const InfoWindow(title: 'Lake'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    position: const LatLng(37.43296265331129, -122.08832357078792),
  );

  static const _polyline = Polyline(
    polylineId: PolylineId('_polyline'),
    points: [
      LatLng(37.42796133580664, -122.085749655962),
      LatLng(37.43296265331129, -122.08832357078792),
    ],
    width: 5,
    color: Colors.red,
  );

  static const _polygon = Polygon(
    polygonId: PolygonId('polygonId'),
    points: [
      LatLng(37.43296265331129, -122.08832357078792),
      LatLng(37.42796133580664, -122.085749655962),
      LatLng(37.418, -122.092),
      LatLng(37.435, -122.092),
    ],
    strokeWidth: 5,
    fillColor: Colors.transparent,
    strokeColor: Colors.red,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.terrain,
        markers: {_googlePlexMarker, _lakeMarker},
        initialCameraPosition: _googlePlex,
        onMapCreated: _controller.complete,
        polylines: {_polyline},
        polygons: {_polygon},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final controller = await _controller.future;
    return controller.animateCamera(CameraUpdate.newCameraPosition(_lake));
  }
}
