import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor de Tareas',
      // Se agrega un tema general para mejorar el diseño visual
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const TodoListScreen(),
    );
  }
}

// Se usa StatefulWidget porque la interfaz cambia al agregar o eliminar tareas
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // ------------------------------
  // VARIABLES DE ESTADO
  // ------------------------------

  // Lista que guarda las tareas
  // Cada tarea contiene: texto, fecha y estado de completado
  final List<Map<String, dynamic>> _tareas = [];

  // Controlador para leer lo que escribe el usuario
  final TextEditingController _tareaController = TextEditingController();

  // Variable para mostrar mensajes de error debajo del campo
  String? _errorTexto;

  // Liberar memoria cuando el widget se destruye
  @override
  void dispose() {
    _tareaController.dispose();
    super.dispose();
  }

  // ------------------------------
  // FUNCION PARA AGREGAR TAREAS
  // ------------------------------
  void _agregarTarea() {
    // Guardamos el texto ingresado eliminando espacios
    String nuevaTarea = _tareaController.text.trim();

    // VALIDACION 1: campo obligatorio
    if (nuevaTarea.isEmpty) {
      setState(() {
        _errorTexto = 'La tarea es obligatoria';
      });
      return;
    }

    // VALIDACION 2: minimo 3 caracteres
    if (nuevaTarea.length < 3) {
      setState(() {
        _errorTexto = 'Debe tener al menos 3 letras';
      });
      return;
    }

    // VALIDACION 3: evitar tareas duplicadas
    bool existe = _tareas.any(
      (t) => t["texto"].toLowerCase() == nuevaTarea.toLowerCase(),
    );
    if (existe) {
      setState(() {
        _errorTexto = 'Esta tarea ya fue ingresada';
      });
      return;
    }

    // Si todo es correcto se agrega la tarea
    setState(() {
      // Limpiamos el error
      _errorTexto = null;

      // Agregamos la tarea con fecha actual y estado "no completado"
      _tareas.add({
        "texto": nuevaTarea,
        "fecha": DateTime.now().toString().substring(0, 10),
        "completada": false,
      });
    });

    // Limpiamos el campo de texto
    _tareaController.clear();
  }

  //------------------------------
  // FUNCION PARA ELIMINAR TAREA
  // ------------------------------
  void _eliminarTarea(int index) {
    setState(() {
      _tareas.removeAt(index);
    });
  }

  // ------------------------------
  // FUNCION PARA MARCAR COMPLETADA
  // ------------------------------
  void _toggleCompletada(int index, bool? value) {
    setState(() {
      _tareas[index]["completada"] = value;
    });
  }

  // ------------------------------
  // INTERFAZ DE USUARIO
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BARRA SUPERIOR
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          children: [
            // ------------------------------
            // CAMPO PARA INGRESAR TAREA
            //-------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo de texto
                Expanded(
                  child: TextField(
                    controller: _tareaController,
                    // Se mejora el diseño del campo de texto
                    decoration: InputDecoration(
                      labelText: 'Nueva tarea',
                      hintText: 'Ej. Comprar leche',
                      // Icono dentro del campo
                      prefixIcon: Icon(Icons.task),
                      // Bordes redondeados
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: _errorTexto,
                    ),

                    // Cuando el usuario empieza a escribir
                    // se limpia el mensaje de error
                    onChanged: (value) {
                      if (_errorTexto != null) {
                        setState(() {
                          _errorTexto = null;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // BOTON AGREGAR
                SizedBox(
                  height: 56,

                  child: ElevatedButton.icon(
                    onPressed: _agregarTarea,

                    icon: const Icon(Icons.add),

                    label: const Text('Agregar'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 40, thickness: 2),

            // ------------------------------
            // LISTA DE TAREAS
            // ------------------------------
            Expanded(
              // Si no hay tareas mostramos mensaje
              child: _tareas.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay tareas. ¡Añade la primera!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  // Si hay tareas mostramos la lista
                  : ListView.builder(
                      itemCount: _tareas.length,

                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),

                          child: ListTile(
                            // CHECKBOX PARA MARCAR COMPLETADA
                            leading: Checkbox(
                              value: _tareas[index]["completada"],
                              onChanged: (value) {
                                _toggleCompletada(index, value);
                              },
                            ),

                            // TEXTO DE LA TAREA
                            title: Text(
                              _tareas[index]["texto"],

                              style: TextStyle(
                                fontWeight: FontWeight.bold,

                                // Si esta completada se tacha
                                decoration: _tareas[index]["completada"]
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),

                            // FECHA DE LA TAREA
                            subtitle: Text("Fecha: ${_tareas[index]["fecha"]}"),

                            // BOTON PARA ELIMINAR
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _eliminarTarea(index);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
