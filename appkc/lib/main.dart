import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repository/auth_repository.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'view/login_screen.dart';
import 'viewmodel/auth_viewmodel.dart';
import 'repository/usuario_repository.dart';
import 'services/usuario_service.dart';
import 'viewmodel/usuario_viewmodel.dart';
import 'viewmodel/dashboard_viewmodel.dart';
import 'repository/upload_repository.dart';
import 'services/upload_service.dart';
import 'viewmodel/upload_viewmodel.dart';

void main() {
  ApiClient.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(AuthRepository(AuthService())),
        ),
        ChangeNotifierProvider(
          create: (_) => UsuarioViewModel(UsuarioRepository(UsuarioService())),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(UsuarioRepository(UsuarioService())),
        ),
        ChangeNotifierProvider(
          create: (_) => UploadViewModel(UploadRepository(UploadService())),
        ),
      ],
      child: MaterialApp(
        title: 'App Usuarios',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const LoginScreen(),
      ),
    );
  }
}