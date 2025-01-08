import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

void main() {
  // Limitar la orientación a portrait (vertical)
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,  // Solo vertical hacia arriba
    DeviceOrientation.portraitDown,  // Solo vertical hacia abajo (si es necesario)
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grid Productos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


// Pantalla de Splash
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const GridProductos()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Aquí puedes poner el logo de tu aplicación
            Image.asset('assets/logo.jpg'),
          ],
        ),
      ),
    );
  }
}

class GridProductos extends StatefulWidget {
  const GridProductos({super.key});

  @override
  _GridProductosState createState() => _GridProductosState();
}

class _GridProductosState extends State<GridProductos> {
  // Precios de cada producto
  List<double> precios = [12.0, 20.0, 18.0, 10.0];

  List<String> productos = ["Gorditas", "Molletes", "Refrescos", "Aguas"];

  // Cantidades seleccionadas de cada producto
  List<int> cantidades = [0, 0, 0, 0];

  // Estado para ocultar o mostrar el contenido de la grid
  bool mostrarGrid = true;

  // Cantidad total a pagar
  double totalPagar = 0.0;

  // Imágenes de los productos
  List<String> imagenes = ['gorditas.png', 'molletes.png', 'refrescos.png', 'aguas.png'];

  int _selectedIndex = 0;

  bool _montoAdicional = false;

  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController cantidadAdicionalController = TextEditingController();

  final TextEditingController gorditasController = TextEditingController();
  final TextEditingController molletesController = TextEditingController();
  final TextEditingController refrescosController = TextEditingController();
  final TextEditingController aguaController = TextEditingController();

   @override
  void initState() {
    super.initState();
    createSetup(); // Llama a createSetup para inicializar el archivo
    leerMenu();    // Llama a leerMenu para leer los valores del archivo
     cantidadAdicionalController.addListener(_updateTotal);
  }

  @override
  void dispose() {
    cantidadAdicionalController.removeListener(_updateTotal);
    cantidadAdicionalController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    setState(() {}); // Esto hará que el widget se vuelva a dibujar con el nuevo valor
  }

  void calcularTotal() {
    totalPagar = 0.0;
    for (int i = 0; i < cantidades.length; i++) {
      totalPagar += cantidades[i] * precios[i];
    }
  }

  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> guardarPago(double cantidad) async {
    try {
      final path = await getFilePath();
      final file = File('$path/logs.json');

      // Cargar el contenido actual del archivo JSON
      Map<String, dynamic> jsonData = {};
      if (await file.exists()) {
        String content = await file.readAsString();
        jsonData = jsonDecode(content);
      } else {
        // Si el archivo no existe, inicializamos la estructura
        jsonData = {'ventas': []};
      }

      // Obtener la fecha actual y formatearla correctamente
      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      // Crear una nueva venta
      Map<String, dynamic> nuevaVenta = {
        'fecha': formattedDate,
        'total': cantidad.toStringAsFixed(2),
      };

      // Añadir la nueva venta a la lista de ventas
      jsonData['ventas'].add(nuevaVenta);

      // Guardar nuevamente el archivo JSON actualizado
      await file.writeAsString(jsonEncode(jsonData), mode: FileMode.write);
      // print('Pago guardado en $path');
      // print(jsonData);
      // print('Pago guardado en $path');
    } catch (e) {
      // print('Error al guardar el pago: $e');
    }
  }
  Future<void> createFile() async {
    try {
      final path = await getFilePath();
      final file = File('$path/logs.json');

      // Verificar si el archivo ya existe
      if (await file.exists()) {
        // print('El archivo ya existe en: $path/logs.json');
      } else {
        // Inicializar la estructura y escribir datos en el archivo si no existe
        Map<String, dynamic> jsonData = {'ventas': []};
        await file.writeAsString(jsonEncode(jsonData));
        // print('Archivo creado y datos guardados');
      }
    } catch (e) {
      // print('Error al crear el archivo: $e');
    }
  }

  Future<List<dynamic>> readLogs() async {
    try {
      final path = await getFilePath();
      final file = File('$path/logs.json');

      if (await file.exists()) {
        String content = await file.readAsString();
        Map<String, dynamic> jsonData = jsonDecode(content);
        // print(jsonData['ventas']);
        return jsonData['ventas'];
      } else {
        // print('El archivo no existe.');
        return [];
      }
    } catch (e) {
      // print('Error al leer el archivo: $e');
      return [];
    }
  }

  Future<void> createSetup() async {
    try {
      final path = await getFilePath();
      final file = File('$path/menu.json');

      // Verificar si el archivo ya existe
      if (await file.exists()) {
        // print('El archivo ya existe en: $path/menu.json');
      } else {
        // Inicializar la estructura y escribir datos en el archivo si no existe
        Map<String, dynamic> jsonData = {
          'menu': {
            'gorditas': 12,
            'molletes': 20,
            'refrescos': 18,
            'agua': 10,
          }
        };
        await file.writeAsString(jsonEncode(jsonData));
        // print('Archivo creado y datos guardados');
      }
    } catch (e) {
      // print('Error al crear el archivo: $e');
    }
  }

  Future<void> leerMenu() async {
    try {
      final path = await getFilePath();
      final file = File('$path/menu.json');

      if (await file.exists()) {
        // Leer el archivo JSON
        String content = await file.readAsString();
        Map<String, dynamic> jsonData = jsonDecode(content);

        gorditasController.text = jsonData['menu']['gorditas'].toString();
        molletesController.text = jsonData['menu']['molletes'].toString();
        refrescosController.text = jsonData['menu']['refrescos'].toString();
        aguaController.text = jsonData['menu']['agua'].toString();

        // Extraer los precios del menú y asignarlos a la lista
        setState(() {
          precios = [
            jsonData['menu']['gorditas'].toDouble(),
            jsonData['menu']['molletes'].toDouble(),
            jsonData['menu']['refrescos'].toDouble(),
            jsonData['menu']['agua'].toDouble(),
          ];
        });
      } else {
        gorditasController.text = "12";
        molletesController.text = "20";
        refrescosController.text = "18";
        aguaController.text = "10";
      }
    _selectedIndex = 0;
    } catch (e) {
      // print('Error al leer el archivo: $e');
    }
  }

    Future<void> guardarPrecios() async {
  // Validar que los precios no sean 0 y que no estén vacíos
  if (gorditasController.text.isEmpty || 
      molletesController.text.isEmpty || 
      refrescosController.text.isEmpty || 
      aguaController.text.isEmpty ||
      double.tryParse(gorditasController.text) == 0 ||
      double.tryParse(molletesController.text) == 0 ||
      double.tryParse(refrescosController.text) == 0 ||
      double.tryParse(aguaController.text) == 0) {
    // Mostrar un modal si alguna validación falla
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Por favor, ingrese un valor mayor a 0 en todos los campos.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el modal
              },
              child: const  Text('Aceptar'),
            ),
          ],
        );
      },
    );
    return; // Salir de la función si la validación falla
  }

  try {
    final path = await getFilePath();
    final file = File('$path/menu.json');

    // Actualizar los precios con los valores de los TextFields
    Map<String, dynamic> jsonData = {
      'menu': {
        'gorditas': double.parse(gorditasController.text),
        'molletes': double.parse(molletesController.text),
        'refrescos': double.parse(refrescosController.text),
        'agua': double.parse(aguaController.text),
      }
    };

    await file.writeAsString(jsonEncode(jsonData));
    leerMenu(); // Refrescar los datos después de guardar
  } catch (e) {
    // print('Error al guardar los precios: $e');
  }
}


  Future<void> resetPrecios() async {
    setState(() {
      precios = [12.0, 20.0, 18.0, 10.0]; // Restablecer valores por defecto

      // Actualizar los TextFields
      gorditasController.text = precios[0].toString();
      molletesController.text = precios[1].toString();
      refrescosController.text = precios[2].toString();
      aguaController.text = precios[3].toString();
    });
    guardarPrecios(); // Guardar los valores por defecto en el archivo
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0
            ? 'Menu de Productos'
            : _selectedIndex == 1
                ? 'Registros de Ventas'
                : 'Configuración'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Ayuda'),
                  content: Text(_selectedIndex == 0
                      ? 'Selecciona la cantidad de cada producto que deseas comprar. Presiona el botón "Limpiar selección" para reiniciar la selección. Presiona el botón "Pagar" para realizar el pago.'
                      : _selectedIndex == 1
                          ? 'Aquí se muestran los registros de ventas realizadas.'
                          : 'Aquí podras cambiar el precio de los productos. Presiona el botón "Guardar" para guardar los cambios y "Restablecer" para volver a los precios por defecto.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? (mostrarGrid ? buildGrid() : buildResumenPago())
          : _selectedIndex == 1
              ? buildRegistros()
              : buildConfiguracion(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Compra',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_sharp),
            label: 'Registros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
        selectedItemColor: Colors.blue,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget buildGrid() {
    return Stack(
      children: [
        // El GridView se coloca como el fondo
        Column(
          children: [
            // Usamos Flexible para que el GridView se adapte al tamaño disponible
            Flexible(
              child: GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return buildProductoCard(index);
                },
              ),
            ),
          ],
        ),
        // Los botones flotan sobre el GridView, usando Positioned
        Positioned(
          bottom: 20, // Alineación inferior
          left: 0,
          right: 0, // Centra los botones horizontalmente
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    cantidades = [0, 0, 0, 0];
                  });
                },
                child: const Text('Limpiar selección'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    calcularTotal();
                    if (totalPagar != 0.0) {
                      mostrarGrid = false;
                    } else {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('No hay productos seleccionados'),
                          content: const Text(
                              'Por favor, selecciona al menos un producto.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  });
                },
                child: const Text('Pagar'),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget buildRegistros() {
    DateTime selectedDay = DateTime.now();
    Map<DateTime, List<dynamic>> registrosPorFecha = {};

    return FutureBuilder<List<dynamic>>(
      future: readLogs(), // Llama a la función que lee el archivo JSON
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Muestra un indicador de carga
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'No hay registros.',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(height: 20),
                    Icon(
                      Icons.remove_shopping_cart,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          // Organiza los registros por fecha (sin horas)
          for (var registro in snapshot.data!) {
            // Verifica que la fecha se esté cargando correctamente
            // print('Registro: ${registro['fecha']} - Total: ${registro['total']}');

            // Intenta parsear la fecha
            DateTime fechaCompleta;
            try {
              fechaCompleta = DateTime.parse(registro['fecha']);
            } catch (e) {
              // print('Error al parsear la fecha: $e');
              continue; // Si hay error en el parseo, ignoramos el registro
            }

            // Crear una fecha solo con año, mes y día para agrupar las ventas
            DateTime fechaSolo = DateTime.utc(fechaCompleta.year, fechaCompleta.month, fechaCompleta.day);

            if (!registrosPorFecha.containsKey(fechaSolo)) {
              registrosPorFecha[fechaSolo] = [];
            }
            registrosPorFecha[fechaSolo]?.add(registro);
          }

          // print('Registros por fecha: $registrosPorFecha'); // Para verificar la estructura

          return Column(
            children: [
              TableCalendar(
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: selectedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  selectedDay = selectedDay;
                  showVentasDialog(context, registrosPorFecha[selectedDay] ?? []);
                },
                calendarFormat: CalendarFormat.month,
                eventLoader: (day) {
                  return registrosPorFecha[day] ?? [];
                },
              ),
            ],
          );
        }
      },
    );
  }

  // Función para mostrar las ventas del día seleccionado en un AlertDialog
  void showVentasDialog(BuildContext context, List<dynamic> ventas) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ventas del día: ${ventas.length}'),
          content: ventas.isEmpty
              ? const Text('No hay ventas para este día.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: ventas.map((venta) {
                    return ListTile(
                      title: Text('Fecha: ${venta['fecha']}'),
                      subtitle: Text('Total: \$${venta['total']}'),
                    );
                  }).toList(),
                ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
    // Función para inicializar los valores de los precios

  Widget buildConfiguracion() {
    // Asegúrate de llamar a inicializarControladores() en el método initState() de tu StatefulWidget
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: gorditasController,
            decoration: const InputDecoration(labelText: 'Precio Gorditas'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: molletesController,
            decoration: const InputDecoration(labelText: 'Precio Molletes'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: refrescosController,
            decoration: const InputDecoration(labelText: 'Precio Refrescos'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: aguaController,
            decoration: const InputDecoration(labelText: 'Precio Agua'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: guardarPrecios,
                child: const Text('Guardar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: resetPrecios,
                child: const Text('Restablecer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildProductoCard(int index) {
    return Card(
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset('assets/${imagenes[index]}'),
          ),
          Text(productos[index], style: const TextStyle(fontSize: 18)),
          Text('Precio: \$${precios[index]}',
              style: const TextStyle(fontSize: 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (cantidades[index] > 0) {
                      cantidades[index]--;
                    }
                  });
                },
                icon: const Icon(Icons.remove),
              ),
              Text('${cantidades[index]}'),
              IconButton(
                onPressed: () {
                  setState(() {
                    cantidades[index]++;
                  });
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildResumenPago() {
    double propinaSugerida = totalPagar * 0.10;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Renglón "Total a pagar" con la cantidad
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total a pagar:', style: TextStyle(fontSize: 20)),
              Text('\$${(totalPagar + (_montoAdicional ? double.tryParse(cantidadAdicionalController.text) ?? 0.0 : 0.0)).toStringAsFixed(2)}', style: const TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 20),

          // Campo de texto para ingresar la cantidad con la que se pagará
          TextField(
            controller: cantidadController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cantidad con la que pagará',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Checkbox "Monto adicional"
          Row(
            children: [
              Checkbox(
                value: _montoAdicional,
                onChanged: (bool? newValue) {
                  setState(() {
                    _montoAdicional = newValue!;
                  });
                },
                activeColor: Colors.blue,
              ),
              const Text("Monto adicional a pagar (Opcional)"),
            ],
          ),

          // Mostrar el campo "Monto adicional" si el checkbox está activado
          if (_montoAdicional) ...[
            const SizedBox(height: 20),
            TextField(
              controller: cantidadAdicionalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto adicional a pagar (Opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Mostrar la propina sugerida del 10%
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Propina sugerida (10%):', style: TextStyle(fontSize: 20)),
              Text('\$${propinaSugerida.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20)),
            ],
          ),

          // const SizedBox(height: 20),

          // Renglón con el total a pagar, incluyendo el adicional y la propina sugerida
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     const Text('Total a pagar', style: TextStyle(fontSize: 20)),
          //     Text(
          //       '\$${(totalPagar + (_montoAdicional ? (double.tryParse(cantidadAdicionalController.text) ?? 0.0) : 0.0)).toStringAsFixed(2)}',
          //       style: const TextStyle(fontSize: 20),
          //     ),
          //   ],
          // ),

          // const SizedBox(height: 20),

          // Renglón "Se paga con" para la cantidad con la que se va a pagar
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     const Text('Se paga con:', style: TextStyle(fontSize: 20)),
          //     Text(
          //       '\$${cantidadController.text.isNotEmpty ? cantidadController.text : "0.00"}',
          //       style: const TextStyle(fontSize: 20),
          //     ),
          //   ],
          // ),

          const SizedBox(height: 20),

          // Botón para confirmar pago
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: () {
              double cantidadAdicional = cantidadAdicionalController.text != ""
                  ? double.tryParse(cantidadAdicionalController.text) ?? 0.0
                  : 0.0;
              double cantidadIngresada =
                  double.tryParse(cantidadController.text) ?? 0.0;
              double totalConPropina = totalPagar + cantidadAdicional;

              if (cantidadIngresada >= totalConPropina) {
                double cambio =
                    cantidadIngresada - totalConPropina; // Calcular el cambio
                guardarPago(totalPagar); // Guardar el pago en el archivo

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pago realizado'),
                    content: Text(
                        '¡Pago exitoso! Tu cambio es: \$${cambio.toStringAsFixed(2)}'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            cantidades = [0, 0, 0, 0];
                            mostrarGrid = true;
                            cantidadController.clear();
                            cantidadAdicionalController.clear();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Aceptar'),
                      ),
                    ],
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pago insuficiente'),
                    content: const Text(
                        'La cantidad ingresada es menor al total. Por favor, ingresa una cantidad válida.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Aceptar'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Confirmar Pago'),
          ),

          const SizedBox(height: 10),

          // Botón para cancelar
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: () {
              setState(() {
                // cantidades = [0, 0, 0, 0];
                mostrarGrid = true;
                cantidadController.clear();
                cantidadAdicionalController.clear();
              });
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }
}