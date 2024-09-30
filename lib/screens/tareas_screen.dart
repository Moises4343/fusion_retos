import 'package:flutter/material.dart';

import '../services/tareas_service.dart'; // Importa el servicio de tareas

class TareasScreen extends StatefulWidget {
  @override
  _TareasScreenState createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  final TaskService taskService = TaskService(); // Instancia del servicio
  List<Map<String, dynamic>> tasks = []; // Lista de tareas con ID y contenido
  String newTask = '';
  int?
      selectedTaskId; // Almacena el ID de la tarea seleccionada para actualizar
  final TextEditingController _taskController =
      TextEditingController(); // Controlador del campo de texto

  @override
  void initState() {
    super.initState();
    _fetchTasks(); // Cargar las tareas al iniciar la vista
  }

  // Obtener todas las tareas de la API
  Future<void> _fetchTasks() async {
    try {
      final taskList = await taskService.getTasks();
      setState(() {
        tasks = taskList; // Cargar la lista de tareas con IDs
      });
    } catch (e) {
      print('Error al cargar las tareas: $e');
    }
  }

  // Agregar una nueva tarea
  Future<void> _addTask(String task) async {
    try {
      await taskService.addTask(task);
      _fetchTasks(); // Refrescar la lista de tareas después de agregar
      _taskController.clear(); // Limpiar el campo de entrada
    } catch (e) {
      print('Error al agregar la tarea: $e');
    }
  }

  // Actualizar una tarea existente
  Future<void> _updateTask(int taskId, String task) async {
    try {
      await taskService.updateTask(
          taskId, task); // Llama al servicio para actualizar
      _fetchTasks(); // Refrescar la lista de tareas después de actualizar
      setState(() {
        selectedTaskId = null; // Limpiar la selección después de actualizar
        _taskController.clear(); // Limpiar el campo de entrada
      });
    } catch (e) {
      print('Error al actualizar la tarea: $e');
    }
  }

  // Eliminar una tarea
  Future<void> _deleteTask(int taskId) async {
    try {
      await taskService
          .deleteTask(taskId); // Eliminar la tarea usando su ID real
      _fetchTasks(); // Refrescar la lista de tareas después de eliminar
    } catch (e) {
      print('Error al eliminar la tarea: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskController, // Usar el controlador creado
              decoration: const InputDecoration(
                labelText: 'Agregar/Actualizar tarea',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  newTask = value; // Actualiza el valor de la tarea
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (newTask.isNotEmpty) {
                  if (selectedTaskId == null) {
                    _addTask(newTask); // Agregar nueva tarea
                  } else {
                    _updateTask(
                        selectedTaskId!, newTask); // Actualizar tarea existente
                  }
                }
              },
              child: Text(selectedTaskId == null
                  ? 'Agregar Tarea'
                  : 'Actualizar Tarea'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index]; // Tarea actual con ID y contenido
                  return Container(
                    decoration: BoxDecoration(
                      color: index % 2 == 0
                          ? Colors.grey[300] // Color gris claro alternado
                          : Colors.white, // Alternancia de colores
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                          task['task']), // Mostrar el contenido de la tarea
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                                Icons.edit), // Ícono de lápiz para editar
                            onPressed: () {
                              setState(() {
                                newTask = task[
                                    'task']; // Llenar el campo de texto con la tarea seleccionada
                                selectedTaskId = task[
                                    'id']; // Guardar el ID de la tarea seleccionada
                                _taskController.text =
                                    newTask; // Establecer el texto del controlador
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                                Icons.delete), // Ícono de basura para eliminar
                            onPressed: () {
                              _deleteTask(task[
                                  'id']); // Llamar a la función de eliminar tarea
                            },
                          ),
                        ],
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
