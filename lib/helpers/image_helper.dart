import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ImageHelper {
  /// If there is a cached file and it's not old returns the cached marker image file
  /// else it will download the image and save it on the temp dir and return that file.
  ///
  /// This mechanism is possible using the [DefaultCacheManager] package and is useful
  /// to improve load times on the next map loads, the first time will always take more
  /// time to download the file and set the marker image.
  static Future<BitmapDescriptor> getMarkerImageFromUrl(String url) async {
    final File markerImageFile = await DefaultCacheManager().getSingleFile(url);

    Uint8List markerImageBytes = await markerImageFile.readAsBytes();

    return BitmapDescriptor.fromBytes(markerImageBytes);
  }

  static Future<BitmapDescriptor> getMarkerAFromAssets() {
    return BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, 'images/marker_a.png');
  }

  static Future<BitmapDescriptor> getMarkerClusterFromAssets() {
    return BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, 'images/marker_cluster.png');
  }

  static Future<Uint8List> getBytesImageFromUrl(String url) async {
    final File markerImageFile = await DefaultCacheManager().getSingleFile(url);

    Uint8List markerImageBytes = await markerImageFile.readAsBytes();

    return markerImageBytes;
  }
}
