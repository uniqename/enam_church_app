import '../models/banner_slide.dart';
import 'supabase_service.dart';
import 'package:uuid/uuid.dart';

class BannerService {
  static final BannerService _instance = BannerService._internal();
  factory BannerService() => _instance;
  BannerService._internal();

  final _supabase = SupabaseService();
  final _uuid = const Uuid();

  Future<List<BannerSlideModel>> getActiveBanners() async {
    try {
      final data = await _supabase.query(
        'banners',
        column: 'is_active',
        value: true,
        orderBy: 'sort_order',
        ascending: true,
      );
      return data.map((j) => BannerSlideModel.fromSupabase(j)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<BannerSlideModel>> getAllBanners() async {
    try {
      final data = await _supabase.query(
        'banners',
        orderBy: 'sort_order',
        ascending: true,
      );
      return data.map((j) => BannerSlideModel.fromSupabase(j)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addBanner(BannerSlideModel banner) async {
    final data = banner.toSupabase();
    data['id'] = _uuid.v4();
    await _supabase.insert('banners', data);
  }

  Future<void> updateBanner(BannerSlideModel banner) async {
    await _supabase.update('banners', banner.id, banner.toSupabase());
  }

  Future<void> deleteBanner(String id) async {
    await _supabase.delete('banners', id);
  }
}
