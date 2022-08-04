import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'location_service.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final _controller = Completer<GoogleMapController>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();

  static const _googlePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14,
  );

  final _markers = <Marker>{};
  final _polygons = <Polygon>{};
  final _polylines = <Polyline>{};
  final polygonLatLngs = <LatLng>[];
  var _polygonIdCounter = 1;
  var _polylineIdCounter = 1;

  Future<void> _goToPlace(
    double latitude,
    double longitude,
    Map<String, dynamic> boundsNortheast,
    Map<String, dynamic> boundsSouthwest,
  ) async {
    final controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 12,
        ),
      ),
    );

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(boundsSouthwest['lat'], boundsSouthwest['lng']),
          northeast: LatLng(boundsNortheast['lat'], boundsNortheast['lng']),
        ),
        25,
      ),
    );
    _setMarker(LatLng(latitude, longitude));
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('markerId'),
          position: point,
        ),
      );
    });
  }

  void _setPolygon() {
    final polygonId = 'polygon_${_polygonIdCounter++}';
    _polygons.add(
      Polygon(
        polygonId: PolygonId(polygonId),
        points: polygonLatLngs,
        strokeWidth: 2,
        fillColor: Colors.transparent,
        strokeColor: Colors.redAccent,
      ),
    );
  }

  void _setPolyline(List<PointLatLng> points) {
    final polylineId = 'polygon_${_polylineIdCounter++}';
    _polylines.add(
      Polyline(
        polylineId: PolylineId(polylineId),
        points: points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(),
        color: Colors.blue,
        width: 2,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _setMarker(const LatLng(37.43296265331129, -122.08832357078792));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps')),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _originController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Origin',
                        contentPadding: EdgeInsets.only(left: 8),
                      ),
                    ),
                    TextFormField(
                      controller: _destinationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Destination',
                        contentPadding: EdgeInsets.only(left: 8),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  final direction = await LocationService().getDirections(
                    _originController.text,
                    _destinationController.text,
                  );
                  final startLocation = direction['startLocation'] as Map;
                  final latitude = startLocation['lat'] as double;
                  final longitude = startLocation['lng'] as double;
                  final boundsNortheast =
                      direction['boundsNortheast'] as Map<String, dynamic>;
                  final boundsSouthwest =
                      direction['boundsSouthwest'] as Map<String, dynamic>;
                  unawaited(
                    _goToPlace(
                      latitude,
                      longitude,
                      boundsNortheast,
                      boundsSouthwest,
                    ),
                  );

                  final polyline = direction['polyline'] as List<PointLatLng>;
                  _setPolyline(polyline);
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.terrain,
              markers: _markers,
              polygons: _polygons,
              polylines: _polylines,
              initialCameraPosition: _googlePlex,
              onMapCreated: _controller.complete,
              onTap: (point) {
                setState(() {
                  polygonLatLngs.add(point);
                  _setPolygon();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
