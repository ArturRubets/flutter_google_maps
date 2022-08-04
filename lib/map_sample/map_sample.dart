import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'location_service.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final _controller = Completer<GoogleMapController>();
  final _searchController = TextEditingController();

  static const _googlePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14,
  );

  final _markers = <Marker>{};
  final _polygons = <Polygon>{};
  final polygonLatLngs = <LatLng>[];
  var _polygonIdCounter = 1;

  Future<void> _goToPlace(Map<String, dynamic> place) async {
    final geometry = place['geometry'] as Map<String, dynamic>;
    final location = geometry['location'] as Map<String, dynamic>;
    final latitude = location['lat'] as double;
    final longitude = location['lng'] as double;

    final controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 12,
        ),
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
                child: TextFormField(
                  controller: _searchController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Search by City',
                    contentPadding: EdgeInsets.only(left: 10),
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  final place =
                      await LocationService().getPlace(_searchController.text);
                  return _goToPlace(place);
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
