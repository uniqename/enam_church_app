import 'dart:io';
import 'supabase_service.dart';
import '../models/event_photo.dart';

class EventPhotoService {
  static final EventPhotoService _instance = EventPhotoService._internal();
  factory EventPhotoService() => _instance;
  EventPhotoService._internal();

  final _supabase = SupabaseService();

  Future<List<EventPhoto>> getAllPhotos({String? department}) async {
    try {
      if (SupabaseService.isConfigured) {
        var query = _supabase.client
            .from('event_photos')
            .select()
            .eq('is_public', true)
            .order('uploaded_at', ascending: false);

        final data = await query;
        final photos = (data as List<dynamic>)
            .map((e) => EventPhoto.fromJson(e as Map<String, dynamic>))
            .toList();

        if (department != null && department != 'Church') {
          return photos
              .where((p) =>
                  p.department == department || p.department == 'Church')
              .toList();
        }
        return photos;
      }
    } catch (e) {
      print('EventPhotoService error: $e');
    }
    return [];
  }

  Future<List<EventPhoto>> getPhotosByDepartment(String department) async {
    try {
      if (SupabaseService.isConfigured) {
        final data = await _supabase.client
            .from('event_photos')
            .select()
            .eq('department', department)
            .order('uploaded_at', ascending: false);
        return (data as List<dynamic>)
            .map((e) => EventPhoto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('EventPhotoService error: $e');
    }
    return [];
  }

  Future<EventPhoto?> uploadPhoto({
    required File imageFile,
    required String title,
    String? description,
    required String uploadedBy,
    required String uploaderName,
    required String department,
    String? eventName,
    String? eventDate,
  }) async {
    try {
      if (!SupabaseService.isConfigured) throw Exception('Supabase not configured');

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final storagePath = 'event_photos/$fileName';

      await _supabase.client.storage
          .from('church-media')
          .upload(storagePath, imageFile);

      final imageUrl = _supabase.client.storage
          .from('church-media')
          .getPublicUrl(storagePath);

      final photo = EventPhoto.create(
        title: title,
        description: description,
        imageUrl: imageUrl,
        uploadedBy: uploadedBy,
        uploaderName: uploaderName,
        department: department,
        eventName: eventName,
        eventDate: eventDate,
      );

      await _supabase.client.from('event_photos').insert(photo.toJson());
      return photo;
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
  }

  Future<void> deletePhoto(String photoId, String imageUrl) async {
    try {
      if (SupabaseService.isConfigured) {
        // Extract storage path from URL
        final uri = Uri.parse(imageUrl);
        final pathSegments = uri.pathSegments;
        final storageIdx = pathSegments.indexOf('church-media');
        if (storageIdx != -1 && storageIdx < pathSegments.length - 1) {
          final storagePath = pathSegments.sublist(storageIdx + 1).join('/');
          await _supabase.client.storage
              .from('church-media')
              .remove([storagePath]);
        }
        await _supabase.client.from('event_photos').delete().eq('id', photoId);
      }
    } catch (e) {
      print('Delete error: $e');
      rethrow;
    }
  }

  Future<List<String>> getDepartments() async {
    try {
      if (SupabaseService.isConfigured) {
        final data = await _supabase.client
            .from('event_photos')
            .select('department');
        final deps = (data as List<dynamic>)
            .map((e) => e['department'] as String)
            .toSet()
            .toList();
        deps.sort();
        return deps;
      }
    } catch (_) {}
    return ['Church'];
  }
}
