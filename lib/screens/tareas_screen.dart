import 'package:flutter/material.dart';

import '../services/tareas_service.dart';

class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});

  @override
  _TareasScreenState createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  final TaskService taskService = TaskService();
  List<Map<String, dynamic>> tasks = [];
  String newTask = '';
  int? selectedTaskId;
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  // Obtener todas las tareas de la API
  Future<void> _fetchTasks() async {
    try {
      final taskList = await taskService.getTasks();
      setState(() {
        tasks = taskList;
      });
    } catch (e) {
      print('Error al cargar las tareas: $e');
    }
  }

  // Agregar una nueva tarea
  Future<void> _addTask(String task) async {
    try {
      await taskService.addTask(task);
      _fetchTasks();
      _taskController.clear();
    } catch (e) {
      print('Error al agregar la tarea: $e');
    }
  }

  // Actualizar una tarea existente
  Future<void> _updateTask(int taskId, String task) async {
    try {
      await taskService.updateTask(taskId, task);
      _fetchTasks();
      setState(() {
        selectedTaskId = null;
        _taskController.clear();
      });
    } catch (e) {
      print('Error al actualizar la tarea: $e');
    }
  }

  // Eliminar una tarea
  Future<void> _deleteTask(int taskId) async {
    try {
      await taskService.deleteTask(taskId);
      _fetchTasks();
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
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Agregar/Actualizar tarea',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  newTask = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (newTask.isNotEmpty) {
                  if (selectedTaskId == null) {
                    _addTask(newTask);
                  } else {
                    _updateTask(selectedTaskId!, newTask);
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
                  final task = tasks[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: index % 2 == 0 ? Colors.grey[300] : Colors.white,
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
                      title: Text(task['task']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                newTask = task['task'];
                                selectedTaskId = task['id'];
                                _taskController.text = newTask;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteTask(task['id']);
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
