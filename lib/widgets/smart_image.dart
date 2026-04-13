import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SmartImage extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const SmartImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildPlaceholder();
    }

    Widget imageWidget;

    final targetCacheWidth = width != null && width!.isFinite
        ? (width! * 2).round()
        : null;
    final targetCacheHeight = height != null && height!.isFinite
        ? (height! * 2).round()
        : null;

    if (imagePath!.startsWith('http')) {
      // Remote image
      imageWidget = CachedNetworkImage(
        imageUrl: imagePath!,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: targetCacheWidth,
        memCacheHeight: targetCacheHeight,
        placeholder: (context, url) => _buildPlaceholder(loading: true),
        errorWidget: (context, url, error) => _buildPlaceholder(error: true),
      );
    } else if (imagePath!.startsWith('assets/')) {
      // Asset image
      imageWidget = Image.asset(
        imagePath!,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: targetCacheWidth,
        cacheHeight: targetCacheHeight,
        filterQuality: FilterQuality.low,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(error: true),
      );
    } else {
      // Local file path
      imageWidget = Image.file(
        File(imagePath!),
        width: width,
        height: height,
        fit: fit,
        cacheWidth: targetCacheWidth,
        cacheHeight: targetCacheHeight,
        filterQuality: FilterQuality.low,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(error: true),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imageWidget,
    );
  }

  Widget _buildPlaceholder({bool loading = false, bool error = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                error ? Icons.broken_image : Icons.image,
                color: Colors.grey[400],
                size: (width != null && width!.isFinite ? width! : 40) * 0.5,
              ),
      ),
    );
  }
}
