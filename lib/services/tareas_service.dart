import 'dart:convert';

import 'package:http/http.dart' as http;

class TaskService {
  final String baseUrl = 'https://tareas-api-cm2v.onrender.com/tasks';

  // Obtener todas las tareas
  Future<List<Map<String, dynamic>>> getTasks() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> taskList = json.decode(response.body);
      return taskList
          .map((task) => {'id': task['id'], 'task': task['task']})
          .toList();
    } else {
      throw Exception('Error al cargar las tareas');
    }
  }

  // Agregar una nueva tarea
  Future<void> addTask(String task) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'task': task}),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al agregar la tarea');
    }
  }

  // Actualizar una tarea existente
  Future<void> updateTask(int id, String task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'task': task}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la tarea');
    }
  }

  // Eliminar una tarea por ID
  Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la tarea');
    }
  }
}
