import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/company.dart';
import '../models/time_record.dart';

class StorageService {
  static const String _companiesFileName = 'companies.json';
  static const String _timeRecordsFileName = 'time_records.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _companiesFile async {
    final path = await _localPath;
    return File('$path/$_companiesFileName');
  }

  Future<File> get _timeRecordsFile async {
    final path = await _localPath;
    return File('$path/$_timeRecordsFileName');
  }

  Future<List<Company>> loadCompanies() async {
    try {
      final file = await _companiesFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => Company.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao carregar empresas: $e');
      return [];
    }
  }

  Future<void> saveCompanies(List<Company> companies) async {
    try {
      final file = await _companiesFile;
      final jsonList = companies.map((company) => company.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Erro ao salvar empresas: $e');
    }
  }

  Future<List<TimeRecord>> loadTimeRecords() async {
    try {
      final file = await _timeRecordsFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => TimeRecord.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao carregar registros: $e');
      return [];
    }
  }

  Future<void> saveTimeRecords(List<TimeRecord> records) async {
    try {
      final file = await _timeRecordsFile;
      final jsonList = records.map((record) => record.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Erro ao salvar registros: $e');
    }
  }

  Future<void> addTimeRecord(TimeRecord record) async {
    final records = await loadTimeRecords();
    records.add(record);
    await saveTimeRecords(records);
  }

  Future<void> addCompany(Company company) async {
    final companies = await loadCompanies();
    companies.add(company);
    await saveCompanies(companies);
  }

  Future<void> updateCompany(Company company) async {
    final companies = await loadCompanies();
    final index = companies.indexWhere((c) => c.id == company.id);
    if (index != -1) {
      companies[index] = company;
      await saveCompanies(companies);
    }
  }

  Future<void> deleteCompany(String id) async {
    final companies = await loadCompanies();
    companies.removeWhere((company) => company.id == id);
    await saveCompanies(companies);
  }

  Future<void> deleteTimeRecord(String id) async {
    final records = await loadTimeRecords();
    records.removeWhere((record) => record.id == id);
    await saveTimeRecords(records);
  }
}
