import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/models/user_model.dart';
import '../../shared/models/room_model.dart';
import '../../shared/models/chat_message_model.dart';
import '../../shared/models/room_participant_model.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/rooms/data/rooms_repository.dart';
import '../../features/chat/data/chat_repository.dart';
import '../../features/profile/data/profile_repository.dart';
import '../utils/app_logger.dart';
import '../utils/error_handler.dart';
import '../utils/storage_helper.dart';

/// موفر الحالة المحسن للتطبيق - يدير جميع حالات التطبيق بشكل مركزي
class EnhancedAppStateProvider extends ChangeNotifier {
  static EnhancedAppStateProvider? _instance;
  static EnhancedAppStateProvider get instance => _instance ??= EnhancedAppStateProvider._();
  
  EnhancedAppStateProvider._();

  // المستودعات
  final AuthRepository _authRepository = AuthRepository();
  final RoomsRepository _roomsRepository = RoomsRepository();
  final ChatRepository _chatRepository = ChatRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  // حالة المصادقة
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _authError;

  // حالة الغرف
  List<RoomModel> _rooms = [];
  RoomModel? _currentRoom;
  List<RoomParticipantModel> _currentRoomParticipants = [];
  List<ChatMessageModel> _currentRoomMessages = [];
  bool _isInRoom = false;
  String? _roomError;

  // حالة المحادثة
  bool _isTyping = false;
  List<String> _typingUsers = [];
  RealtimeChannel? _messagesSubscription;
  RealtimeChannel? _roomSubscription;

  // حالة واجهة المستخدم
  bool _isDarkMode = false;
  String _selectedLanguage = 'ar';
  Map<String, dynamic> _userPreferences = {};

  // حالة الاتصال
  String _connectionStatus = 'disconnected';
  String _connectionQuality = 'unknown';

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get authError => _authError;
  
  List<RoomModel> get rooms => _rooms;
  RoomModel? get currentRoom => _currentRoom;
  List<RoomParticipantModel> get currentRoomParticipants => _currentRoomParticipants;
  List<ChatMessageModel> get currentRoomMessages => _currentRoomMessages;
  bool get isInRoom => _isInRoom;
  String? get roomError => _roomError;
  
  bool get isTyping => _isTyping;
  List<String> get typingUsers => _typingUsers;
  
  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;
  Map<String, dynamic> get userPreferences => _userPreferences;
  
  String get connectionStatus => _connectionStatus;
  String get connectionQuality => _connectionQuality;

  /// تهيئة التطبيق
  Future<void> initialize() async {
    try {
      AppLogger.startOperation('تهيئة التطبيق');
      
      // تهيئة التخزين المحلي
      await StorageHelper.instance.initialize();
      
      // استرجاع التفضيلات المحفوظة
      await _loadUserPreferences();
      
      // التحقق من حالة المصادقة
      await _checkAuthenticationStatus();
      
      // تحميل البيانات الأساسية إذا كان المستخدم مصادق
      if (_isAuthenticated) {
        await _loadInitialData();
      }
      
      // إعداد مراقبة تغييرات المصادقة
      _setupAuthStateListener();
      
      AppLogger.endOperation('تهيئة التطبيق');
    } catch (e) {
      AppLogger.failOperation('تهيئة التطبيق', e);
      rethrow;
    }
  }

  /// تحميل التفضيلات المحفوظة
  Future<void> _loadUserPreferences() async {
    try {
      _userPreferences = StorageHelper.instance.getUserPreferences();
      _isDarkMode = _userPreferences['theme_mode'] == 'dark';
      _selectedLanguage = _userPreferences['language'] ?? 'ar';
      
      AppLogger.i('تم تحميل تفضيلات المستخدم');
    } catch (e) {
      AppLogger.e('فشل في تحميل التفضيلات', error: e);
    }
  }

  /// التحقق من حالة المصادقة
  Future<void> _checkAuthenticationStatus() async {
    try {
      final user = _authRepository.getCurrentUser();
      if (user != null) {
        await _loadUserProfile(user.id);
        _isAuthenticated = true;
        AppLogger.auth('المستخدم مصادق مسبقاً');
      } else {
        _isAuthenticated = false;
        AppLogger.auth('المستخدم غير مصادق');
      }
    } catch (e) {
      AppLogger.auth('خطأ في التحقق من المصادقة', error: e);
      _isAuthenticated = false;
    }
  }

  /// تحميل البيانات الأولية
  Future<void> _loadInitialData() async {
    try {
      await Future.wait([
        loadRooms(),
        _loadUserPreferencesFromDatabase(),
      ]);
    } catch (e) {
      AppLogger.e('فشل في تحميل البيانات الأولية', error: e);
    }
  }

  /// إعداد مراقب تغييرات المصادقة
  void _setupAuthStateListener() {
    _authRepository.authStateChanges.listen((AuthState state) {
      if (state.event == AuthChangeEvent.signedIn) {
        _handleUserSignedIn(state.session?.user);
      } else if (state.event == AuthChangeEvent.signedOut) {
        _handleUserSignedOut();
      }
    });
  }

  /// معالجة تسجيل دخول المستخدم
  Future<void> _handleUserSignedIn(User? user) async {
    if (user != null) {
      try {
        await _loadUserProfile(user.id);
        _isAuthenticated = true;
        await _loadInitialData();
        AppLogger.auth('تم تسجيل دخول المستخدم بنجاح');
        notifyListeners();
      } catch (e) {
        AppLogger.auth('خطأ في معالجة تسجيل الدخول', error: e);
      }
    }
  }

  /// معالجة تسجيل خروج المستخدم
  void _handleUserSignedOut() {
    _clearUserData();
    AppLogger.auth('تم تسجيل خروج المستخدم');
    notifyListeners();
  }

  /// تحميل ملف المستخدم الشخصي
  Future<void> _loadUserProfile(String userId) async {
    try {
      _currentUser = await _profileRepository.getUserProfile(userId);
      
      // تحديث حالة الاتصال
      await _profileRepository.updateOnlineStatus(
        userId: userId,
        isOnline: true,
      );
      
      AppLogger.auth('تم تحميل الملف الشخصي للمستخدم');
    } catch (e) {
      AppLogger.auth('فشل في تحميل الملف الشخصي', error: e);
      rethrow;
    }
  }

  /// تحميل تفضيلات المستخدم من قاعدة البيانات
  Future<void> _loadUserPreferencesFromDatabase() async {
    if (_currentUser == null) return;

    try {
      final preferences = await _profileRepository.getUserPreferences(_currentUser!.id);
      _userPreferences = preferences;
      _isDarkMode = preferences['theme_mode'] == 'dark';
      _selectedLanguage = preferences['language'] ?? 'ar';
      
      // حفظ التفضيلات محلياً
      await StorageHelper.instance.saveUserPreferences(preferences);
      
      AppLogger.i('تم تحميل تفضيلات المستخدم من قاعدة البيانات');
    } catch (e) {
      AppLogger.e('فشل في تحميل التفضيلات من قاعدة البيانات', error: e);
    }
  }

  /// تسجيل الدخول
  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    _authError = null;
    
    try {
      AppLogger.auth('محاولة تسجيل دخول للمستخدم: $email');
      
      _currentUser = await _authRepository.signIn(
        email: email,
        password: password,
      );
      
      _isAuthenticated = true;
      
      // حفظ بيانات الجلسة
      await StorageHelper.instance.saveSessionData(
        userId: _currentUser!.id,
        email: _currentUser!.email,
        fullName: _currentUser!.fullName,
        avatarUrl: _currentUser!.avatarUrl,
      );
      
      await _loadInitialData();
      
      AppLogger.auth('تم تسجيل الدخول بنجاح');
    } catch (e) {
      _authError = ErrorHandler.handleError(e);
      AppLogger.auth('فشل تسجيل الدخول', error: e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// تسجيل حساب جديد
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading(true);
    _authError = null;
    
    try {
      AppLogger.auth('محاولة إنشاء حساب جديد للمستخدم: $email');
      
      _currentUser = await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      
      _isAuthenticated = true;
      
      // حفظ بيانات الجلسة
      await StorageHelper.instance.saveSessionData(
        userId: _currentUser!.id,
        email: _currentUser!.email,
        fullName: _currentUser!.fullName,
        avatarUrl: _currentUser!.avatarUrl,
      );
      
      await _loadInitialData();
      
      AppLogger.auth('تم إنشاء الحساب بنجاح');
    } catch (e) {
      _authError = ErrorHandler.handleError(e);
      AppLogger.auth('فشل إنشاء الحساب', error: e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      AppLogger.auth('محاولة تسجيل خروج المستخدم');
      
      // تحديث حالة الاتصال قبل الخروج
      if (_currentUser != null) {
        await _profileRepository.updateOnlineStatus(
          userId: _currentUser!.id,
          isOnline: false,
        );
      }
      
      // مغادرة الغرفة الحالية إن وجدت
      if (_isInRoom && _currentRoom != null) {
        await leaveRoom();
      }
      
      // إلغاء الاشتراكات
      await _unsubscribeFromAll();
      
      await _authRepository.signOut();
      _clearUserData();
      
      // مسح بيانات الجلسة
      await StorageHelper.instance.clearSessionData();
      
      AppLogger.auth('تم تسجيل الخروج بنجاح');
    } catch (e) {
      AppLogger.auth('فشل تسجيل الخروج', error: e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// تحميل الغرف
  Future<void> loadRooms({
    String? searchQuery,
    String? roomType,
    String? privacy,
  }) async {
    try {
      AppLogger.room('تحميل الغرف');
      
      _rooms = await _roomsRepository.getRooms(
        searchQuery: searchQuery,
        roomType: roomType,
        privacy: privacy,
      );
      
      AppLogger.room('تم تحميل ${_rooms.length} غرفة');
      notifyListeners();
    } catch (e) {
      _roomError = ErrorHandler.handleError(e);
      AppLogger.room('فشل في تحميل الغرف', error: e);
      rethrow;
    }
  }

  /// إنشاء غرفة جديدة
  Future<RoomModel> createRoom({
    required String name,
    required String description,
    required String type,
    required String privacy,
    required int participantLimit,
    String? imageUrl,
    Map<String, dynamic>? settings,
  }) async {
    _setLoading(true);
    
    try {
      AppLogger.room('إنشاء غرفة جديدة: $name');
      
      final newRoom = await _roomsRepository.createRoom(
        name: name,
        description: description,
        type: type,
        privacy: privacy,
        participantLimit: participantLimit,
        imageUrl: imageUrl,
        settings: settings,
      );
      
      _rooms.insert(0, newRoom);
      
      // إضافة للغرف الحديثة
      await StorageHelper.instance.addRecentRoom(newRoom.id);
      
      // تحديث إحصائيات الاستخدام
      await StorageHelper.instance.incrementRoomsJoined();
      
      AppLogger.room('تم إنشاء الغرفة بنجاح: ${newRoom.id}');
      notifyListeners();
      return newRoom;
    } catch (e) {
      AppLogger.room('فشل في إنشاء الغرفة', error: e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// الانضمام لغرفة
  Future<void> joinRoom(String roomId) async {
    try {
      AppLogger.room('محاولة الانضمام للغرفة: $roomId');
      
      await _roomsRepository.joinRoom(roomId);
      
      // العثور على الغرفة في القائمة
      final room = _rooms.firstWhere((r) => r.id == roomId);
      _currentRoom = room;
      _isInRoom = true;
      
      // تحميل المشاركين والرسائل
      await Future.wait([
        _loadRoomParticipants(roomId),
        _loadRoomMessages(roomId),
      ]);
      
      // الاشتراك في التحديثات
      _subscribeToRoomUpdates(roomId);
      
      // إضافة للغرف الحديثة
      await StorageHelper.instance.addRecentRoom(roomId);
      
      AppLogger.room('تم الانضمام للغرفة بنجاح');
      notifyListeners();
    } catch (e) {
      AppLogger.room('فشل في الانضمام للغرفة', error: e);
      rethrow;
    }
  }

  /// مغادرة الغرفة
  Future<void> leaveRoom() async {
    if (_currentRoom == null) return;

    try {
      AppLogger.room('مغادرة الغرفة: ${_currentRoom!.id}');
      
      await _roomsRepository.leaveRoom(_currentRoom!.id);
      
      // إلغاء الاشتراكات
      await _unsubscribeFromRoom();
      
      _currentRoom = null;
      _isInRoom = false;
      _currentRoomParticipants.clear();
      _currentRoomMessages.clear();
      
      AppLogger.room('تم مغادرة الغرفة بنجاح');
      notifyListeners();
    } catch (e) {
      AppLogger.room('فشل في مغادرة الغرفة', error: e);
      rethrow;
    }
  }

  /// تحميل مشاركي الغرفة
  Future<void> _loadRoomParticipants(String roomId) async {
    try {
      _currentRoomParticipants = await _roomsRepository.getRoomParticipants(roomId);
      AppLogger.room('تم تحميل ${_currentRoomParticipants.length} مشارك');
    } catch (e) {
      AppLogger.room('فشل في تحميل المشاركين', error: e);
    }
  }

  /// تحميل رسائل الغرفة
  Future<void> _loadRoomMessages(String roomId) async {
    try {
      _currentRoomMessages = await _chatRepository.getRoomMessages(roomId: roomId);
      AppLogger.chat('تم تحميل ${_currentRoomMessages.length} رسالة');
    } catch (e) {
      AppLogger.chat('فشل في تحميل الرسائل', error: e);
    }
  }

  /// إرسال رسالة
  Future<void> sendMessage(String content) async {
    if (_currentRoom == null || _currentUser == null) return;

    try {
      AppLogger.chat('إرسال رسالة في الغرفة: ${_currentRoom!.id}');
      
      final message = await _chatRepository.sendTextMessage(
        roomId: _currentRoom!.id,
        content: content,
      );
      
      _currentRoomMessages.add(message);
      
      // تحديث إحصائيات الاستخدام
      await StorageHelper.instance.incrementMessagesSent();
      
      AppLogger.chat('تم إرسال الرسالة بنجاح');
      notifyListeners();
    } catch (e) {
      AppLogger.chat('فشل في إرسال الرسالة', error: e);
      rethrow;
    }
  }

  /// الاشتراك في تحديثات الغرفة
  void _subscribeToRoomUpdates(String roomId) {
    try {
      // الاشتراك في الرسائل الجديدة
      _messagesSubscription = _chatRepository.subscribeToRoomMessages(
        roomId,
        (ChatMessageModel message) {
          _currentRoomMessages.add(message);
          AppLogger.chat('رسالة جديدة من ${message.senderName}');
          notifyListeners();
        },
      );

      // الاشتراك في تحديثات المشاركين
      _roomSubscription = _roomsRepository.subscribeToRoom(
        roomId,
        (Map<String, dynamic> update) {
          _handleParticipantUpdate(update);
        },
      );

      AppLogger.room('تم الاشتراك في تحديثات الغرفة');
    } catch (e) {
      AppLogger.room('فشل في الاشتراك في التحديثات', error: e);
    }
  }

  /// معالجة تحديثات المشاركين
  void _handleParticipantUpdate(Map<String, dynamic> update) {
    try {
      // إعادة تحميل قائمة المشاركين
      if (_currentRoom != null) {
        _loadRoomParticipants(_currentRoom!.id);
      }
    } catch (e) {
      AppLogger.room('فشل في معالجة تحديث المشاركين', error: e);
    }
  }

  /// إلغاء الاشتراك من الغرفة
  Future<void> _unsubscribeFromRoom() async {
    try {
      await _messagesSubscription?.unsubscribe();
      await _roomSubscription?.unsubscribe();
      _messagesSubscription = null;
      _roomSubscription = null;
      
      AppLogger.room('تم إلغاء الاشتراك من تحديثات الغرفة');
    } catch (e) {
      AppLogger.room('فشل في إلغاء الاشتراك', error: e);
    }
  }

  /// إلغاء جميع الاشتراكات
  Future<void> _unsubscribeFromAll() async {
    await _unsubscribeFromRoom();
  }

  /// تحديث التفضيلات
  Future<void> updatePreferences({
    String? themeMode,
    String? language,
    bool? notificationsEnabled,
    bool? autoJoinAudio,
    bool? autoJoinVideo,
    String? preferredQuality,
  }) async {
    if (_currentUser == null) return;

    try {
      AppLogger.i('تحديث تفضيلات المستخدم');
      
      final updatedPreferences = await _profileRepository.updateUserPreferences(
        userId: _currentUser!.id,
        themeMode: themeMode,
        language: language,
        notificationsEnabled: notificationsEnabled,
        autoJoinAudio: autoJoinAudio,
        autoJoinVideo: autoJoinVideo,
        preferredQuality: preferredQuality,
      );
      
      _userPreferences = updatedPreferences;
      
      // تحديث الحالة المحلية
      if (themeMode != null) _isDarkMode = themeMode == 'dark';
      if (language != null) _selectedLanguage = language;
      
      // حفظ التفضيلات محلياً
      await StorageHelper.instance.saveUserPreferences(updatedPreferences);
      
      AppLogger.i('تم تحديث التفضيلات بنجاح');
      notifyListeners();
    } catch (e) {
      AppLogger.e('فشل في تحديث التفضيلات', error: e);
      rethrow;
    }
  }

  /// تبديل الوضع المظلم
  Future<void> toggleTheme() async {
    final newThemeMode = _isDarkMode ? 'light' : 'dark';
    await updatePreferences(themeMode: newThemeMode);
  }

  /// تغيير اللغة
  Future<void> setLanguage(String language) async {
    await updatePreferences(language: language);
  }

  /// تحديث حالة الاتصال
  void updateConnectionStatus(String status, String quality) {
    _connectionStatus = status;
    _connectionQuality = quality;
    
    AppLogger.network('تحديث حالة الاتصال: $status ($quality)');
    notifyListeners();
  }

  /// تعيين حالة التحميل
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// مسح بيانات المستخدم
  void _clearUserData() {
    _currentUser = null;
    _isAuthenticated = false;
    _authError = null;
    _rooms.clear();
    _currentRoom = null;
    _currentRoomParticipants.clear();
    _currentRoomMessages.clear();
    _isInRoom = false;
    _roomError = null;
    _isTyping = false;
    _typingUsers.clear();
    
    // إلغاء الاشتراكات
    _unsubscribeFromAll();
  }

  /// الحصول على الغرف المفضلة
  List<RoomModel> get favoriteRooms {
    final favoriteIds = StorageHelper.instance.getFavoriteRooms();
    return _rooms.where((room) => favoriteIds.contains(room.id)).toList();
  }

  /// الحصول على الغرف الحديثة
  List<RoomModel> get recentRooms {
    final recentIds = StorageHelper.instance.getRecentRooms();
    final recentRooms = <RoomModel>[];
    
    for (final id in recentIds) {
      try {
        final room = _rooms.firstWhere((r) => r.id == id);
        recentRooms.add(room);
      } catch (e) {
        // تجاهل الغرف غير الموجودة
      }
    }
    
    return recentRooms;
  }

  /// تبديل حالة المفضلة للغرفة
  Future<void> toggleRoomFavorite(String roomId) async {
    try {
      await StorageHelper.instance.toggleFavoriteRoom(roomId);
      AppLogger.room('تم تبديل حالة المفضلة للغرفة: $roomId');
      notifyListeners();
    } catch (e) {
      AppLogger.room('فشل في تبديل حالة المفضلة', error: e);
    }
  }

  /// التحقق من كون الغرفة مفضلة
  bool isRoomFavorite(String roomId) {
    return StorageHelper.instance.isRoomFavorite(roomId);
  }

  /// الحصول على إحصائيات الاستخدام
  Map<String, dynamic> get usageStats {
    return StorageHelper.instance.getUsageStats();
  }

  @override
  void dispose() {
    _unsubscribeFromAll();
    super.dispose();
  }
}