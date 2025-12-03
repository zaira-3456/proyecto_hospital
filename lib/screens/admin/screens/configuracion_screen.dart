import 'package:flutter/material.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  /// CONTROL DE PESTAÑAS
  int currentTab = 0;

  /// =============================
  ///       GENERAL — FORMULARIO
  /// =============================
  final TextEditingController nombreCtrl =
      TextEditingController(text: "Clinic Salud");
  final TextEditingController telCtrl =
      TextEditingController(text: "+52 747 800 0114");
  final TextEditingController mailCtrl =
      TextEditingController(text: "clinicsalud@hospital.mx");
  final TextEditingController dirCtrl = TextEditingController(
      text: "Av. Miguel Alemán 18,\nCol. Centro CP:39000");

  /// =============================
  ///     ESPECIALIDADES
  /// =============================
  final TextEditingController nuevaEspCtrl = TextEditingController();
  List<String> especialidades = [
    "Cardiología",
    "Medicina General",
    "Pediatría",
    "Ginecología"
  ];

  /// =============================
  ///     SERVICIOS
  /// =============================
  final TextEditingController servCtrl = TextEditingController();
  final TextEditingController catCtrl = TextEditingController();
  final TextEditingController precioCtrl = TextEditingController();
  final TextEditingController duracionCtrl = TextEditingController();

  List<Map<String, dynamic>> servicios = [
    {
      "servicio": "Consulta General",
      "categoria": "Consulta",
      "precio": 500,
      "duracion": "30 min"
    },
    {
      "servicio": "Consulta Especialista",
      "categoria": "Consulta",
      "precio": 800,
      "duracion": "45 min"
    },
    {
      "servicio": "Análisis de Sangre",
      "categoria": "Estudio",
      "precio": 350,
      "duracion": "20 min"
    },
    {
      "servicio": "Electrocardiograma",
      "categoria": "Imagen",
      "precio": 450,
      "duracion": "15 min"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Configuración del Sistema",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 25),

          /// =============================
          ///         PESTAÑAS
          /// =============================
          Row(
            children: [
              _tabButton("General", 0),
              const SizedBox(width: 25),
              _tabButton("Especialidades", 1),
              const SizedBox(width: 25),
              _tabButton("Servicios", 2),
            ],
          ),

          const SizedBox(height: 25),

          /// =============================
          ///  CONTENIDO SEGÚN LA PESTAÑA
          /// =============================
          if (currentTab == 0) _generalTab(),
          if (currentTab == 1) _especialidadesTab(),
          if (currentTab == 2) _serviciosTab(),
        ],
      ),
    );
  }

  /// =====================================================
  ///                    BOTÓN DE PESTAÑA
  /// =====================================================
  Widget _tabButton(String text, int index) {
    final bool active = currentTab == index;

    return InkWell(
      onTap: () => setState(() => currentTab = index),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: active ? Colors.blue : Colors.black87,
          decoration: active ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }

  /// =====================================================
  ///                   TAB GENERAL
  /// =====================================================
  Widget _generalTab() {
    return _whiteCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("Nombre del Hospital"),
          _input(nombreCtrl),
          const SizedBox(height: 20),

          _label("Teléfono"),
          _input(telCtrl),
          const SizedBox(height: 20),

          _label("E-mail"),
          _input(mailCtrl),
          const SizedBox(height: 20),

          _label("Dirección"),
          _input(dirCtrl, maxLines: 3),
          const SizedBox(height: 35),

          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text(
                "Guardar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// =====================================================
  ///               TAB ESPECIALIDADES
  /// =====================================================
  Widget _especialidadesTab() {
    return _whiteCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _input(nuevaEspCtrl, hint: "Agregar nueva especialidad..."),
          const SizedBox(height: 10),

          Center(
            child: ElevatedButton(
              onPressed: () {
                if (nuevaEspCtrl.text.isNotEmpty) {
                  setState(() {
                    especialidades.add(nuevaEspCtrl.text);
                    nuevaEspCtrl.clear();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text(
                "+Agregar",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 25),

          /// LISTA DE ESPECIALIDADES
          ...especialidades.map((e) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_services_outlined, size: 22),
                  const SizedBox(width: 12),
                  Expanded(child: Text(e, style: const TextStyle(fontSize: 16))),
                  InkWell(
                    onTap: () {
                      setState(() {
                        especialidades.remove(e);
                      });
                    },
                    child: const Text(
                      "Eliminar",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// =====================================================
  ///                   TAB SERVICIOS
  /// =====================================================
  Widget _serviciosTab() {
    return _whiteCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _input(servCtrl, hint: "Nuevo Servicio..."),
          const SizedBox(height: 12),

          _input(catCtrl, hint: "Categoría"),
          const SizedBox(height: 12),

          _input(precioCtrl, hint: "Precio"),
          const SizedBox(height: 12),

          _input(duracionCtrl, hint: "Duración..."),
          const SizedBox(height: 20),

          Center(
            child: ElevatedButton(
              onPressed: () {
                if (servCtrl.text.isEmpty ||
                    catCtrl.text.isEmpty ||
                    precioCtrl.text.isEmpty ||
                    duracionCtrl.text.isEmpty) return;

                setState(() {
                  servicios.add({
                    "servicio": servCtrl.text,
                    "categoria": catCtrl.text,
                    "precio": double.tryParse(precioCtrl.text) ?? 0,
                    "duracion": duracionCtrl.text
                  });

                  servCtrl.clear();
                  catCtrl.clear();
                  precioCtrl.clear();
                  duracionCtrl.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 45, vertical: 16),
              ),
              child: const Text("+Agregar"),
            ),
          ),

          const SizedBox(height: 25),

          /// ==========================
          ///          TABLA
          /// ==========================
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
            child: Table(
              border: TableBorder.symmetric(
                inside: BorderSide(color: Colors.black.withOpacity(0.1)),
              ),
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(2),
              },
              children: [
                _headerRow(),
                ...servicios.map((s) => _dataRow(s)),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// =====================================================
  ///             COMPONENTES DE TABLA
  /// =====================================================

  /// 🔵 HEADER ROW
  TableRow _headerRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.blue.shade100),
      children: [
        _cellHeader("Servicio"),
        _cellHeader("Categoría"),
        _cellHeader("Precio"),
        _cellHeader("Duración"),
        _cellHeader("Acción"),
      ],
    );
  }

  /// 🔵 FILAS DE DATOS
  TableRow _dataRow(Map<String, dynamic> s) {
    return TableRow(
      children: [
        _cell(s["servicio"]),
        _cell(s["categoria"]),
        _cell("\$${s["precio"].toString()}"),
        _cell(s["duracion"]),
        Padding(
          padding: const EdgeInsets.all(10),
          child: InkWell(
            onTap: () {
              setState(() {
                servicios.remove(s);
              });
            },
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// 🔵 COMPONENTES VISUALES

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      );

  Widget _whiteCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _input(TextEditingController ctrl, {int maxLines = 1, String? hint}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black26),
        ),
      ),
    );
  }

  /// 🔵 HEADER CELLS — CORREGIDO
  Widget _cellHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  /// 🔵 CELDA NORMAL
  Widget _cell(String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
