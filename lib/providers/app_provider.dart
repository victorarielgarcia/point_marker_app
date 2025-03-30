import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import '../models/company.dart';
import '../models/time_record.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import 'package:intl/intl.dart';

class AppProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  List<Company> _companies = [];
  List<TimeRecord> _timeRecords = [];
  Company? _selectedCompany;
  bool _isLoading = false;

  List<Company> get companies => _companies;
  List<TimeRecord> get timeRecords => _timeRecords;
  Company? get selectedCompany => _selectedCompany;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _notificationService.initialize();
    await _loadCompanies();
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

  Future<void> markTime(String type) async {
    if (_selectedCompany == null) {
      _notificationService.showErrorNotification(
        'Empresa não selecionada',
        'Por favor, selecione uma empresa antes de marcar o ponto.',
      );
      return;
    }

    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        _notificationService.showErrorNotification(
          'Localização não disponível',
          'Não foi possível obter sua localização. Verifique se o GPS está ativado.',
        );
        return;
      }

      final record = TimeRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        companyId: _selectedCompany!.id,
        companyName: _selectedCompany!.name,
        type: type,
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
        '${type.toUpperCase()}\n${_selectedCompany!.name}\n$formattedDate\n$formattedTime',
      );

      notifyListeners();
    } catch (e) {
      _notificationService.showErrorNotification(
        'Erro ao registrar ponto',
        'Ocorreu um erro ao registrar seu ponto. Tente novamente.',
      );
      debugPrint('Erro ao registrar ponto: $e');
    }
  }

  Future<void> deleteTimeRecord(TimeRecord record) async {
    _timeRecords.removeWhere((r) => r.id == record.id);
    await _saveTimeRecords();
    notifyListeners();
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
