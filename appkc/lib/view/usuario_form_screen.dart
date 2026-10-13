import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/usuario.dart';
import '../services/api_client.dart';
import '../viewmodel/upload_viewmodel.dart';
import '../viewmodel/usuario_viewmodel.dart';

class UsuarioFormScreen extends StatefulWidget {
  final Usuario? usuario;

  const UsuarioFormScreen({super.key, this.usuario});

  @override
  State<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends State<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _emailCtrl;
  final _passCtrl = TextEditingController();

  File? _archivoSeleccionado;

  bool get _esEdicion => widget.usuario != null;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.usuario?.nombre ?? '');
    _emailCtrl = TextEditingController(text: widget.usuario?.email ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<UploadViewModel>().reset();
  });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirImagen() async {
  try {
    final picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,   // <-- antes decía ImageSource.camera
      imageQuality: 80,
    );
    debugPrint('IMAGEN SELECCIONADA: ${imagen?.path}');
    if (imagen != null) {
      setState(() => _archivoSeleccionado = File(imagen.path));
    }
  } catch (e, st) {
    debugPrint('ERROR AL ELEGIR IMAGEN: $e');
    debugPrint('$st');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

  Future<void> _subirImagen() async {
  debugPrint('SUBIR: archivo=${_archivoSeleccionado?.path} id=${widget.usuario?.id}');
  if (_archivoSeleccionado == null || widget.usuario?.id == null) {
    debugPrint('SUBIR: cancelado, falta archivo o id');
    return;
  }

  final uploadVm = context.read<UploadViewModel>();
  final ok = await uploadVm.subir(_archivoSeleccionado!, widget.usuario!.id!);
  debugPrint('SUBIR: ok=$ok url=${uploadVm.urlSubida} error=${uploadVm.error}');

  if (!mounted) return;
  if (ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imagen subida correctamente')),
    );
    final usuarioVm = context.read<UsuarioViewModel>();
    await usuarioVm.recargarTrasSubida();
    if (!mounted) return;
    setState(() => _archivoSeleccionado = null);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(uploadVm.error ?? 'Error al subir')),
    );
  }
}

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<UsuarioViewModel>();
    final nombre = _nombreCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    final ok = _esEdicion
        ? await vm.actualizar(widget.usuario!.id!, nombre, email, password: pass)
        : await vm.crear(nombre, email, pass);

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'No se pudo guardar')),
      );
    }
  }

  Usuario? _usuarioActual(UsuarioViewModel vm) {
    final id = widget.usuario?.id;
    if (id == null) return widget.usuario;
    return vm.usuarios.firstWhere(
      (u) => u.id == id,
      orElse: () => widget.usuario!,
    );
  }

    Widget _previewFoto(Usuario? usuario, int version) {
    if (_archivoSeleccionado != null) {
      return Image.file(
        _archivoSeleccionado!,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    final fotoUrl = context.read<UploadViewModel>().urlSubida ?? usuario?.fotoUrl;

    if (fotoUrl != null && fotoUrl.isNotEmpty) {
      final uri = Uri.parse(fotoUrl);
      final base = uri.hasScheme
          ? uri
          : Uri.parse(ApiClient.dio.options.baseUrl).resolve(fotoUrl);

      // ?v=... fuerza a Flutter a descargar la imagen nueva
      final url = base.replace(queryParameters: {
        ...base.queryParameters,
        'v': '$version',
      }).toString();

      debugPrint('FOTO URL FINAL: $url');

      return Image.network(
        url,
        key: ValueKey(url),
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              ),
        errorBuilder: (context, error, stackTrace) => const SizedBox(
          height: 150,
          child: Center(child: Icon(Icons.broken_image, size: 50)),
        ),
      );
    }

    return Container(
      height: 150,
      color: Colors.grey.shade200,
      child: const Icon(Icons.person, size: 60, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuarioVm = context.watch<UsuarioViewModel>();   // <-- watch al VM
    final loading = usuarioVm.loading;
    final uploadVm = context.watch<UploadViewModel>();
    final usuario = _usuarioActual(usuarioVm);

    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar usuario' : 'Nuevo usuario')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _previewFoto(usuario, usuarioVm.fotoVersion),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _elegirImagen,
                icon: const Icon(Icons.image_outlined),
                label: const Text('Elegir imagen'),
              ),
              if (_archivoSeleccionado != null && _esEdicion) ...[
                const SizedBox(height: 8),
                if (uploadVm.subiendo)
                  Column(
                    children: [
                      LinearProgressIndicator(value: uploadVm.progreso),
                      const SizedBox(height: 4),
                      Text('${(uploadVm.progreso * 100).toStringAsFixed(0)}%'),
                    ],
                  )
                else
                  FilledButton.icon(
                    onPressed: _subirImagen,
                    icon: const Icon(Icons.upload),
                    label: const Text('Subir imagen'),
                  ),
              ],
              if (_archivoSeleccionado != null && !_esEdicion)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Guarda el usuario primero para poder subir la imagen',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
              const Divider(height: 32),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Email inválido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _esEdicion ? 'Contraseña (opcional)' : 'Contraseña',
                ),
                validator: (v) {
                  if (_esEdicion) return null;
                  return (v == null || v.length < 4) ? 'Mínimo 4 caracteres' : null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: loading ? null : _guardar,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_esEdicion ? 'Guardar cambios' : 'Crear usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}