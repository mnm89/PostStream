import 'dart:async';
import 'dart:developer';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_in_flutter/data/locations.dart' as locations;
import 'package:google_maps_in_flutter/helpers/map_helper.dart';
import 'package:google_maps_in_flutter/helpers/map_marker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller = Completer();

  /// Set of displayed markers and cluster markers on the map
  Set<Marker> _markers = {};

  /// Minimum zoom at which the markers will cluster
  final int _minClusterZoom = 0;

  /// Maximum zoom at which the markers will cluster
  final int _maxClusterZoom = 19;

  /// [Fluster] instance used to manage the clusters
  late Fluster<MapMarker> _clusterManager;

  /// Current map zoom. Initial zoom will be 2,
  double _currentZoom = 2;

  /// Current map type
  MapType _currentMapType = MapType.normal;

  /// Map loading flag
  bool _isMapLoading = true;

  bool _loading = false;
  bool _centered = true;

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    setState(() {
      _isMapLoading = false;
    });

    _initMarkers();
  }

  void _initMarkers() async {
    final googleOffices = await locations.getGoogleOffices();
    final List<MapMarker> markers = [];
    for (final office in googleOffices.offices) {
      markers.add(
        MapMarker(
          id: office.name,
          position: LatLng(office.lat, office.lng),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
            onTap: () async {
              await showDialog(
                context: context,
                builder: (_) => ImageDialog(src: office.image),
              );
            },
          ),
        ),
      );
    }
    setState(() {
      _markers = markers.map((e) => e.toMarker()).toSet();
    });
    // _clusterManager = await MapHelper.initClusterManager(
    //   markers,
    //   _minClusterZoom,
    //   _maxClusterZoom,
    // );
    // _updateMarkers();
  }

  /// Gets the markers and clusters to be displayed on the map for the current zoom level and
  /// updates state.
  void _updateMarkers([double? updatedZoom]) {
    if (updatedZoom == _currentZoom) return;
    if (updatedZoom != null) _currentZoom = updatedZoom;
    setState(() {
      _loading = true;
    });

    _markers
      ..clear()
      ..addAll(MapHelper.getClusterMarkers(_clusterManager, _currentZoom));

    setState(() {
      _loading = false;
    });
  }

  Future<void> _onCameraMove(CameraPosition position) async {
    // _updateMarkers(position.zoom);
  }

  Future<void> _onMapTypeButtonPressed() async {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  Future<void> _onMarkerButtonPressed() async {
    if (_loading) return;
    setState(() {
      _loading = true;
    });
    if (!_centered) {
      (await _controller.future).animateCamera(
          CameraUpdate.newLatLngZoom(const LatLng(0, 0), _currentZoom));
      setState(() {
        _centered = true;
        _loading = false;
      });
    } else {
      final position = await _determinePosition();
      inspect(position);
      (await _controller.future).animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude), 11));
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('ME'),
            position: LatLng(position.latitude, position.longitude),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow:
                const InfoWindow(title: "My Current Position", snippet: ''),
          ),
        );
        _centered = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: const LatLng(0, 0),
                zoom: _currentZoom,
              ),
              markers: _markers,
              mapType: _currentMapType,
              onCameraMove: _onCameraMove,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
            ),
            // Map loading indicator
            Opacity(
              opacity: _isMapLoading ? 1 : 0,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
        floatingActionButton: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: _onMapTypeButtonPressed,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              backgroundColor: Colors.green,
              child: Icon(
                  _currentMapType == MapType.satellite
                      ? Icons.map
                      : Icons.satellite,
                  size: 36.0),
            ),
            const SizedBox(height: 16.0),
            FloatingActionButton(
              onPressed: _onMarkerButtonPressed,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              backgroundColor: Colors.green,
              child: _loading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Icon(_centered ? Icons.location_pin : Icons.location_off,
                      size: 36.0),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageDialog extends StatelessWidget {
  const ImageDialog({Key? key, required this.src}) : super(key: key);
  final String src;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: Image.network(src).image, fit: BoxFit.cover)),
      ),
    );
  }
}
