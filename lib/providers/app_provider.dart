import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import '../models/company.dart';
import '../models/time_record.dart';
import '../models/project.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  late SharedPreferences _storage;
  List<Company> _companies = [];
  List<Project> _projects = [];
  List<TimeRecord> _timeRecords = [];
  Company? _selectedCompany;
  Project? _selectedProject;
  bool _isLoading = false;

  List<Company> get companies => _companies;
  List<Project> get projects => _projects;
  List<TimeRecord> get timeRecords => _timeRecords;
  Company? get selectedCompany => _selectedCompany;
  Project? get selectedProject => _selectedProject;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _storage = await SharedPreferences.getInstance();
    await _notificationService.initialize();
    await _loadCompanies();
    await _loadProjects();
    await _loadTimeRecords();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadCompanies() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/companies.json');

      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        _companies = jsonList.map((json) => Company.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao carregar empresas: $e');
    }
  }

  Future<void> _saveCompanies() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/companies.json');
      final jsonList = _companies.map((company) => company.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      debugPrint('Erro ao salvar empresas: $e');
    }
  }

  Future<void> _loadProjects() async {
    final prefs = await _storage;
    final projectsJson = prefs.getString('projects');
    if (projectsJson != null) {
      final List<dynamic> decoded = json.decode(projectsJson);
      _projects = decoded.map((json) => Project.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveProjects() async {
    final prefs = await _storage;
    final encoded = json.encode(_projects.map((p) => p.toJson()).toList());
    await prefs.setString('projects', encoded);
  }

  Future<void> _loadTimeRecords() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/time_records.json');

      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        _timeRecords =
            jsonList.map((json) => TimeRecord.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao carregar registros: $e');
    }
  }

  Future<void> _saveTimeRecords() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/time_records.json');
      final jsonList = _timeRecords.map((record) => record.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      debugPrint('Erro ao salvar registros: $e');
    }
  }

  void setSelectedCompany(Company? company) {
    _selectedCompany = company;
    notifyListeners();
  }

  void setSelectedProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }

  Future<void> addCompany(String name) async {
    final company = Company(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    _companies.add(company);
    await _saveCompanies();
    notifyListeners();
  }

  Future<void> updateCompany(String id, String name) async {
    final index = _companies.indexWhere((company) => company.id == id);
    if (index != -1) {
      _companies[index] = Company(id: id, name: name);
      await _saveCompanies();
      notifyListeners();
    }
  }

  Future<void> deleteCompany(String id) async {
    _companies.removeWhere((company) => company.id == id);
    await _saveCompanies();
    notifyListeners();
  }

  bool shouldBeEntry() {
    if (_selectedCompany == null) return true;

    final companyRecords = _timeRecords
        .where((record) => record.companyId == _selectedCompany!.id)
        .toList();

    if (companyRecords.isEmpty) return true;

    return companyRecords.last.type == 'saida';
  }

  Future<void> addProject(String name, String companyId) async {
    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      companyId: companyId,
    );
    _projects.add(project);
    await _saveProjects();
    notifyListeners();
  }

  Future<void> deleteProject(Project project) async {
    _projects.removeWhere((p) => p.id == project.id);
    await _saveProjects();
    notifyListeners();
  }

  List<Project> getProjectsByCompany(String companyId) {
    return _projects.where((p) => p.companyId == companyId).toList();
  }

  Future<void> markTime() async {
    if (_selectedCompany == null) {
      _notificationService.showErrorNotification(
        'Empresa não selecionada',
        'Selecione uma empresa antes de registrar o ponto.',
      );
      return;
    }

    if (_selectedProject == null) {
      _notificationService.showErrorNotification(
        'Projeto não selecionado',
        'Selecione um projeto antes de registrar o ponto.',
      );
      return;
    }

    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        _notificationService.showErrorNotification(
          'Localização não disponível',
          'Verifique se o GPS está ativado e tente novamente.',
        );
        return;
      }

      final record = TimeRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        companyId: _selectedCompany!.id,
        companyName: _selectedCompany!.name,
        projectId: _selectedProject!.id,
        projectName: _selectedProject!.name,
        type: shouldBeEntry() ? 'entrada' : 'saida',
        timestamp: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _timeRecords.add(record);
      await _saveTimeRecords();

      final formattedDate = DateFormat('dd/MM/yyyy').format(record.timestamp);
      final formattedTime = DateFormat('HH:mm:ss').format(record.timestamp);

      _notificationService.showSuccessNotification(
        'Ponto Registrado com Sucesso!',
        '${record.type.toUpperCase()}\n${record.companyName}\n${record.projectName}\n$formattedDate\n$formattedTime',
      );

      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sucesso!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${record.type.toUpperCase()}\n${record.companyName}\n${record.projectName}\n$formattedDate\n$formattedTime',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao registrar ponto: $e');
      _notificationService.showErrorNotification(
        'Erro ao registrar ponto',
        'Tente novamente mais tarde.',
      );
    }
  }

  Future<void> deleteTimeRecord(TimeRecord record) async {
    _timeRecords.removeWhere((r) => r.id == record.id);
    await _saveTimeRecords();
    notifyListeners();
  }

  Future<Position?> getCurrentLocation() async {
    try {
      return await _locationService.getCurrentLocation();
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
      return null;
    }
  }

  Future<void> addRetroactiveRecord(
    Company company,
    Project project,
    String type,
    DateTime timestamp,
    double latitude,
    double longitude,
  ) async {
    try {
      final record = TimeRecord(
        id: timestamp.millisecondsSinceEpoch.toString(),
        companyId: company.id,
        companyName: company.name,
        projectId: project.id,
        projectName: project.name,
        type: type,
        timestamp: timestamp,
        latitude: latitude,
        longitude: longitude,
      );

      _timeRecords.add(record);
      await _saveTimeRecords();

      final formattedDate = DateFormat('dd/MM/yyyy').format(record.timestamp);
      final formattedTime = DateFormat('HH:mm:ss').format(record.timestamp);

      _notificationService.showSuccessNotification(
        'Registro Retroativo Adicionado!',
        '${type.toUpperCase()}\n${company.name}\n${project.name}\n$formattedDate\n$formattedTime',
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar registro retroativo: $e');
      rethrow;
    }
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
