import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/usuario.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../viewmodel/usuario_viewmodel.dart';
import 'login_screen.dart';
import 'usuario_form_screen.dart';
import 'dashboard_screen.dart';
import '../services/api_client.dart';
import 'notification_screen.dart';

class UsuariosListScreen extends StatefulWidget {
  const UsuariosListScreen({super.key});

  @override
  State<UsuariosListScreen> createState() => _UsuariosListScreenState();
}

class _UsuariosListScreenState extends State<UsuariosListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsuarioViewModel>().cargar();
    });
  }

  String? _urlFoto(String? fotoUrl, int version) {
  if (fotoUrl == null || fotoUrl.isEmpty) return null;

  final uri = Uri.parse(fotoUrl);
  final base = uri.hasScheme
      ? uri
      : Uri.parse(ApiClient.dio.options.baseUrl).resolve(fotoUrl);

  return base.replace(queryParameters: {
    ...base.queryParameters,
    'v': '$version',
  }).toString();
}

  Future<void> _cerrarSesion() async {
    await context.read<AuthViewModel>().logout();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  Future<void> _confirmarEliminar(Usuario u) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Seguro que quieres eliminar a ${u.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    final vm = context.read<UsuarioViewModel>();
    final ok = await vm.eliminar(u.id!);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'No se pudo eliminar')),
      );
    }
  }

  void _abrirFormulario([Usuario? usuario]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UsuarioFormScreen(usuario: usuario)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UsuarioViewModel>();

    Widget cuerpo;
    if (vm.loading && vm.usuarios.isEmpty) {
      cuerpo = const Center(child: CircularProgressIndicator());
    } else if (vm.error != null && vm.usuarios.isEmpty) {
      cuerpo = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.error!),
            const SizedBox(height: 12),
            FilledButton(onPressed: vm.cargar, child: const Text('Reintentar')),
          ],
        ),
      );
    } else if (vm.usuarios.isEmpty) {
      cuerpo = const Center(child: Text('No hay usuarios todavía'));
    } else {
      cuerpo = RefreshIndicator(
        onRefresh: vm.cargar,
        child: ListView.builder(
          itemCount: vm.usuarios.length,
          itemBuilder: (_, i) {
            final u = vm.usuarios[i];
            final foto = _urlFoto(u.fotoUrl, vm.fotoVersion);

            return ListTile(
              leading: CircleAvatar(
                key: ValueKey(foto),
                backgroundImage: foto != null ? NetworkImage(foto) : null,
                child: foto == null
                    ? Text(u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : '?')
                    : null,
              ),
              title: Text(u.nombre),
              subtitle: Text(u.email),
              onTap: () => _abrirFormulario(u),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmarEliminar(u),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        
      actions: [
        IconButton(
          icon: const Icon(Icons.mail_outline),
          tooltip: 'Enviar correo',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationScreen()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.dashboard_outlined),
          tooltip: 'Dashboard',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesión',
          onPressed: _cerrarSesion,
        ),
      ],
      ),
      body: cuerpo,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}