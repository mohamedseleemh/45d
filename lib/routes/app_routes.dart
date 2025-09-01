import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/room_list/room_list.dart';
import '../presentation/room_interface/room_interface.dart';
import '../presentation/create_room/create_room.dart';
import '../presentation/room_settings/room_settings.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/register_screen.dart';
import '../presentation/auth/forgot_password_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String roomList = '/room-list';
  static const String roomInterface = '/room-interface';
  static const String createRoom = '/create-room';
  static const String roomSettings = '/room-settings';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    roomList: (context) => const RoomList(),
    roomInterface: (context) => const RoomInterface(),
    createRoom: (context) => const CreateRoom(),
    roomSettings: (context) => const RoomSettings(),
    // TODO: Add your other routes here
  };
}
