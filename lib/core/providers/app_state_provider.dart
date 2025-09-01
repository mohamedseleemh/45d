import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../models/room_model.dart';
import '../models/chat_message_model.dart';
import '../services/supabase_service.dart';

class AppStateProvider extends ChangeNotifier {
  static AppStateProvider? _instance;
  static AppStateProvider get instance => _instance ??= AppStateProvider._();
  
  AppStateProvider._();

  // Authentication state
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  // Room state
  List<RoomModel> _rooms = [];
  RoomModel? _currentRoom;
  List<ChatMessageModel> _currentRoomMessages = [];
  bool _isInRoom = false;

  // UI state
  bool _isDarkMode = false;
  String _selectedLanguage = 'ar';

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  List<RoomModel> get rooms => _rooms;
  RoomModel? get currentRoom => _currentRoom;
  List<ChatMessageModel> get currentRoomMessages => _currentRoomMessages;
  bool get isInRoom => _isInRoom;
  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;

  // Authentication methods
  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      final response = await SupabaseService.instance.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign in error: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading(true);
    try {
      final response = await SupabaseService.instance.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign up error: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await SupabaseService.instance.signOut();
      _clearUserData();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign out error: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await SupabaseService.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      _currentUser = UserModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Load user profile error: $e');
      }
    }
  }

  // Room management methods
  Future<void> loadRooms() async {
    _setLoading(true);
    try {
      final roomsData = await SupabaseService.instance.getRooms();
      _rooms = roomsData.map((data) => RoomModel.fromJson(data)).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Load rooms error: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<RoomModel> createRoom({
    required String name,
    required String description,
    required String type,
    required String privacy,
    required int participantLimit,
    Map<String, dynamic>? settings,
  }) async {
    _setLoading(true);
    try {
      final roomData = await SupabaseService.instance.createRoom(
        name: name,
        description: description,
        type: type,
        privacy: privacy,
        participantLimit: participantLimit,
        settings: settings,
      );

      final newRoom = RoomModel.fromJson(roomData);
      _rooms.insert(0, newRoom);
      notifyListeners();
      return newRoom;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Create room error: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> joinRoom(String roomId) async {
    try {
      await SupabaseService.instance.joinRoom(roomId);
      
      final room = _rooms.firstWhere((r) => r.id == roomId);
      _currentRoom = room;
      _isInRoom = true;
      
      // Load room messages
      await _loadRoomMessages(roomId);
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Join room error: $e');
      }
      rethrow;
    }
  }

  Future<void> leaveRoom() async {
    if (_currentRoom == null) return;

    try {
      await SupabaseService.instance.leaveRoom(_currentRoom!.id);
      _currentRoom = null;
      _isInRoom = false;
      _currentRoomMessages.clear();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Leave room error: $e');
      }
      rethrow;
    }
  }

  Future<void> _loadRoomMessages(String roomId) async {
    try {
      final response = await SupabaseService.instance.client
          .from('chat_messages')
          .select('*, profiles!chat_messages_sender_id_fkey(*)')
          .eq('room_id', roomId)
          .eq('is_deleted', false)
          .order('created_at', ascending: true)
          .limit(100);

      _currentRoomMessages = (response as List)
          .map((data) => ChatMessageModel.fromJson(data))
          .toList();
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Load room messages error: $e');
      }
    }
  }

  Future<void> sendMessage(String content) async {
    if (_currentRoom == null || _currentUser == null) return;

    try {
      final response = await SupabaseService.instance.client
          .from('chat_messages')
          .insert({
            'room_id': _currentRoom!.id,
            'sender_id': _currentUser!.id,
            'content': content,
            'message_type': 'text',
          })
          .select('*, profiles!chat_messages_sender_id_fkey(*)')
          .single();

      final newMessage = ChatMessageModel.fromJson(response);
      _currentRoomMessages.add(newMessage);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Send message error: $e');
      }
      rethrow;
    }
  }

  // UI state methods
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearUserData() {
    _currentUser = null;
    _isAuthenticated = false;
    _rooms.clear();
    _currentRoom = null;
    _currentRoomMessages.clear();
    _isInRoom = false;
    notifyListeners();
  }

  // Initialize app state
  Future<void> initialize() async {
    try {
      final user = SupabaseService.instance.currentUser;
      if (user != null) {
        await _loadUserProfile(user.id);
        _isAuthenticated = true;
        await loadRooms();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Initialize app state error: $e');
      }
    }
  }
}