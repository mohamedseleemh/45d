import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/quick_actions_modal.dart';
import './widgets/room_card_widget.dart';
import './widgets/search_bar_widget.dart';

class RoomList extends StatefulWidget {
  const RoomList({Key? key}) : super(key: key);

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  String _searchQuery = '';
  bool _isRefreshing = false;
  DateTime _lastUpdated = DateTime.now();

  // Mock data for rooms
  final List<Map<String, dynamic>> _allRooms = [
    {
      "id": 1,
      "name": "غرفة الأصدقاء المسائية",
      "type": "voice",
      "participantCount": 8,
      "maxParticipants": 15,
      "isActive": true,
      "isBookmarked": false,
      "ownerName": "أحمد محمد",
      "ownerAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "isPrivate": false,
      "createdAt": "2025-09-01T15:30:00Z",
    },
    {
      "id": 2,
      "name": "مناقشة التقنية والبرمجة",
      "type": "video",
      "participantCount": 12,
      "maxParticipants": 20,
      "isActive": true,
      "isBookmarked": true,
      "ownerName": "سارة أحمد",
      "ownerAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "isPrivate": false,
      "createdAt": "2025-09-01T14:15:00Z",
    },
    {
      "id": 3,
      "name": "Tech Discussion Room",
      "type": "voice",
      "participantCount": 5,
      "maxParticipants": 10,
      "isActive": false,
      "isBookmarked": false,
      "ownerName": "محمد علي",
      "ownerAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "isPrivate": true,
      "createdAt": "2025-09-01T13:45:00Z",
    },
    {
      "id": 4,
      "name": "غرفة الدردشة العامة",
      "type": "video",
      "participantCount": 3,
      "maxParticipants": 25,
      "isActive": true,
      "isBookmarked": false,
      "ownerName": "فاطمة حسن",
      "ownerAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "isPrivate": false,
      "createdAt": "2025-09-01T16:20:00Z",
    },
    {
      "id": 5,
      "name": "Gaming Voice Chat",
      "type": "voice",
      "participantCount": 6,
      "maxParticipants": 12,
      "isActive": true,
      "isBookmarked": true,
      "ownerName": "عمر خالد",
      "ownerAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "isPrivate": false,
      "createdAt": "2025-09-01T17:00:00Z",
    },
  ];

  List<Map<String, dynamic>> _filteredRooms = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredRooms = List.from(_allRooms);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredRooms = _allRooms.where((room) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          (room['name'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (room['ownerName'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      // Type filter
      final matchesFilter = _selectedFilter == 'all' ||
          (_selectedFilter == 'voice' && room['type'] == 'voice') ||
          (_selectedFilter == 'video' && room['type'] == 'video') ||
          (_selectedFilter == 'my_rooms' &&
              room['ownerName'] == 'أحمد محمد'); // Mock current user

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _lastUpdated = DateTime.now();
    });
  }

  void _joinRoom(Map<String, dynamic> room) {
    if (room['isPrivate'] == true) {
      _showRoomPreview(room);
    } else {
      Navigator.pushNamed(context, '/room-interface');
    }
  }

  void _showRoomPreview(Map<String, dynamic> room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'غرفة خاصة',
          style: AppTheme.lightTheme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'lock',
              color: AppTheme.lightTheme.colorScheme.tertiary,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'هذه غرفة خاصة تتطلب دعوة من المالك للانضمام',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Request invitation logic here
            },
            child: Text('طلب دعوة'),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(Map<String, dynamic> room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsModal(
        roomData: room,
        onJoin: () => _joinRoom(room),
        onBookmark: () => _toggleBookmark(room),
        onReport: () => _reportRoom(room),
      ),
    );
  }

  void _toggleBookmark(Map<String, dynamic> room) {
    setState(() {
      final index = _allRooms.indexWhere((r) => r['id'] == room['id']);
      if (index != -1) {
        _allRooms[index]['isBookmarked'] =
            !(_allRooms[index]['isBookmarked'] as bool);
        _applyFilters();
      }
    });
  }

  void _reportRoom(Map<String, dynamic> room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إبلاغ عن الغرفة'),
        content: Text('هل تريد الإبلاغ عن هذه الغرفة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Report logic here
            },
            child: Text('إبلاغ'),
          ),
        ],
      ),
    );
  }

  void _createRoom() {
    Navigator.pushNamed(context, '/create-room');
  }

  void _navigateToProfile() {
    // Profile navigation logic
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/room-settings');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header with greeting and tabs
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مرحباً بك',
                                style: AppTheme
                                    .lightTheme.textTheme.headlineSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'اختر غرفة للانضمام أو أنشئ غرفة جديدة',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.primaryColor
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'waving_hand',
                              color: AppTheme.lightTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    // Tab bar
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'chat_bubble',
                                color: AppTheme.lightTheme.primaryColor,
                                size: 20,
                              ),
                              SizedBox(width: 1.w),
                              Text('الغرف'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'person',
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              SizedBox(width: 1.w),
                              Text('الملف الشخصي'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'settings',
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              SizedBox(width: 1.w),
                              Text('الإعدادات'),
                            ],
                          ),
                        ),
                      ],
                      onTap: (index) {
                        if (index == 1) _navigateToProfile();
                        if (index == 2) _navigateToSettings();
                      },
                    ),
                  ],
                ),
              ),
              // Search bar
              SearchBarWidget(
                controller: _searchController,
                onChanged: (value) {}, // Handled by listener
                onFilterTap: () {
                  // Show filter options
                },
              ),
              // Filter chips
              FilterChipsWidget(
                selectedFilter: _selectedFilter,
                onFilterChanged: _onFilterChanged,
              ),
              // Last updated info
              if (!_isRefreshing)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'آخر تحديث: ${_lastUpdated.hour.toString().padLeft(2, '0')}:${_lastUpdated.minute.toString().padLeft(2, '0')}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      if (_filteredRooms.isNotEmpty)
                        Text(
                          '${_filteredRooms.length} غرفة متاحة',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              // Room list
              Expanded(
                child: _filteredRooms.isEmpty
                    ? EmptyStateWidget(onCreateRoom: _createRoom)
                    : RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppTheme.lightTheme.primaryColor,
                        child: ListView.builder(
                          padding: EdgeInsets.only(bottom: 10.h),
                          itemCount: _filteredRooms.length,
                          itemBuilder: (context, index) {
                            final room = _filteredRooms[index];
                            return RoomCardWidget(
                              roomData: room,
                              onTap: () => _joinRoom(room),
                              onLongPress: () => _showQuickActions(room),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
        // Floating action button
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createRoom,
          icon: CustomIconWidget(
            iconName: 'add',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 24,
          ),
          label: Text(
            'إنشاء غرفة',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
