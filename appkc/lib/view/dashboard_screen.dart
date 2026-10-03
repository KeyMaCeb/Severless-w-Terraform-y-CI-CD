import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/dashboard_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().cargarParalelo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard (carga paralela)')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
              ? Center(child: Text(vm.error!))
              : RefreshIndicator(
                  onRefresh: vm.cargarParalelo,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        color: Colors.indigo.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            '3 peticiones lanzadas con Future.wait() en ${vm.tiempoMs} ms',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _seccion('Usuarios totales', '${vm.listaCompleta.length} usuarios'),
                      _seccion('Perfil (usuario id 1)', vm.perfil?.nombre ?? '-'),
                      _seccion('Configuración (usuario id 2)', vm.configuracion?.nombre ?? '-'),
                    ],
                  ),
                ),
    );
  }

  Widget _seccion(String titulo, String valor) {
    return Card(
      child: ListTile(
        title: Text(titulo),
        subtitle: Text(valor),
      ),
    );
  }
}