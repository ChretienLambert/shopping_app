import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'logging_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _supabase = Supabase.instance.client;

  /// Saves an image from a temporary path to a persistent local directory.
  Future<String> saveLocalImage(String tempPath, String category) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(appDir.path, 'images', category));
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(tempPath)}';
      final persistentPath = p.join(imagesDir.path, fileName);
      
      final file = File(tempPath);
      await file.copy(persistentPath);
      
      logger.info('Saved local image to $persistentPath');
      return persistentPath;
    } catch (e) {
      logger.error('Failed to save local image', e);
      rethrow;
    }
  }

  /// Uploads a local file to Supabase Storage.
  Future<String?> uploadToSupabase(String localPath, String bucket) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) return null;

      final fileName = p.basename(localPath);
      final pathInBucket = '${DateTime.now().year}/${DateTime.now().month}/$fileName';

      await _supabase.storage.from(bucket).upload(
        pathInBucket,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final url = _supabase.storage.from(bucket).getPublicUrl(pathInBucket);
      logger.info('Uploaded image to Supabase: $url');
      return url;
    } catch (e) {
      logger.warning('Failed to upload to Supabase (might be offline): $e');
      return null;
    }
  }

  /// Returns a valid image path/URL. Prefers remote URL if online, falls back to local path.
  String resolveImagePath(String? remoteUrl, String? localPath) {
    if (remoteUrl != null && remoteUrl.isNotEmpty) return remoteUrl;
    return localPath ?? '';
  }
}

final storageService = StorageService();
