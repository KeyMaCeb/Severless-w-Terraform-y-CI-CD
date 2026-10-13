import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/notification_viewmodel.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<NotificationViewModel>();
    final ok = await vm.enviar(
      _emailCtrl.text.trim(),
      _subjectCtrl.text.trim(),
      _messageCtrl.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Mensaje enviado correctamente.' : 'Error al enviar mensaje.',
        ),
      ),
    );

    if (ok) {
      _emailCtrl.clear();
      _subjectCtrl.clear();
      _messageCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final enviando = context.watch<NotificationViewModel>().enviando;

    return Scaffold(
      appBar: AppBar(title: const Text('Enviar correo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo destino'),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Email inválido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectCtrl,
                decoration: const InputDecoration(labelText: 'Asunto'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageCtrl,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Mensaje'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: enviando ? null : _enviar,
                child: enviando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}