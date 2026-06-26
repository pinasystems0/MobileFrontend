import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._(); // prevent instantiation

  static SupabaseClient? _client;

  /// Safe lazy singleton access
  static SupabaseClient get client {
    _client ??= Supabase.instance.client;
    return _client!;
  }
}