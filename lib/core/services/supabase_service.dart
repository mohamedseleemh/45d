import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();
  
  late final SupabaseClient _client;
  
  SupabaseClient get client => _client;
  
  Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL'),
        anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
        debug: kDebugMode,
      );
      
      _client = Supabase.instance.client;
      
      if (kDebugMode) {
        print('✅ Supabase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Supabase initialization failed: $e');
      }
      rethrow;
    }
  }
  
  // Authentication methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign up failed: $e');
      }
      rethrow;
    }
  }
  
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign in failed: $e');
      }
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign out failed: $e');
      }
      rethrow;
    }
  }
  
  User? get currentUser => _client.auth.currentUser;
  
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  // Room management methods
  Future<List<Map<String, dynamic>>> getRooms() async {
    try {
      final response = await _client
          .from('rooms')
          .select('*, profiles!rooms_owner_id_fkey(*)')
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get rooms failed: $e');
      }
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> createRoom({
    required String name,
    required String description,
    required String type,
    required String privacy,
    required int participantLimit,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      final response = await _client.from('rooms').insert({
        'name': name,
        'description': description,
        'type': type,
        'privacy': privacy,
        'participant_limit': participantLimit,
        'owner_id': user.id,
        'settings': settings ?? {},
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Create room failed: $e');
      }
      rethrow;
    }
  }
  
  Future<void> joinRoom(String roomId) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      await _client.from('room_participants').insert({
        'room_id': roomId,
        'user_id': user.id,
        'joined_at': DateTime.now().toIso8601String(),
        'is_active': true,
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Join room failed: $e');
      }
      rethrow;
    }
  }
  
  Future<void> leaveRoom(String roomId) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      await _client
          .from('room_participants')
          .update({'is_active': false, 'left_at': DateTime.now().toIso8601String()})
          .eq('room_id', roomId)
          .eq('user_id', user.id);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Leave room failed: $e');
      }
      rethrow;
    }
  }
  
  // Real-time subscriptions
  RealtimeChannel subscribeToRoom(String roomId, Function(Map<String, dynamic>) onUpdate) {
    return _client
        .channel('room_$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'room_participants',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();
  }
}