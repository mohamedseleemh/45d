import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/room_list/room_list.dart';
import '../presentation/room_interface/room_interface.dart';
import '../presentation/create_room/create_room.dart';
import '../presentation/room_settings/room_settings.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String roomList = '/room-list';
  static const String roomInterface = '/room-interface';
  static const String createRoom = '/create-room';
  static const String roomSettings = '/room-settings';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    roomList: (context) => const RoomList(),
    roomInterface: (context) => const RoomInterface(),
    createRoom: (context) => const CreateRoom(),
    roomSettings: (context) => const RoomSettings(),
    // TODO: Add your other routes here
  };
}
