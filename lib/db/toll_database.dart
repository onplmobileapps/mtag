

import 'dart:developer';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TollDatabase {
  static final TollDatabase instance = TollDatabase._init();
  static Database? _database;
  TollDatabase._init();
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tolls_db_v1.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE veh_toll_cal_7 (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        e_sta_id INTEGER,
        x_sta_id INTEGER,
        v_cat INTEGER,
        t_toll_r INTEGER DEFAULT 0
      )
    ''');
  }

  Future<int> _getCsvVersion() async {
    final csvString = await rootBundle.loadString('assets/data/data.csv');
    final firstLine = csvString.split('\n').first.trim();
    if (firstLine.startsWith('#version=')) {
      return int.tryParse(firstLine.split('=').last.trim()) ?? 1;
    }
    return 1; // default if version not found
  }

  Future<int> _getStoredVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('data_csv_version') ?? 0;
  }

  Future<void> _setStoredVersion(int version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('data_csv_version', version);
  }

  Future<void> importDataIfNeeded() async {
    final db = await database;
    final currentVersion = await _getCsvVersion();
    final storedVersion = await _getStoredVersion();

    if (storedVersion < currentVersion) {
      log('New CSV version detected: $currentVersion (old: $storedVersion), importing...');
      await _loadDataFromCsvAndInsert(db);
      await _setStoredVersion(currentVersion);
    } else {
      log('CSV version $currentVersion already imported, skipping...');
    }
  }

  Future<void> _loadDataFromCsvAndInsert(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS veh_toll_cal_7 (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          e_sta_id INTEGER,
          x_sta_id INTEGER,
          v_cat INTEGER,
          t_toll_r INTEGER DEFAULT 0
        )
      ''');
      await db.delete('veh_toll_cal_7');
      log('Existing toll data deleted');

      final csvString = await rootBundle.loadString('assets/data/data.csv');

      final rows = const CsvToListConverter().convert(csvString);

      // Skip version and header lines
      final dataRows = rows
          .where((row) =>
      row.isNotEmpty &&
          !row[0].toString().startsWith('#') &&
          row[0].toString().toLowerCase() != 'e_sta_id')
          .toList();

      if (dataRows.isEmpty) {
        log('No valid data found in CSV');
        return;
      }

      await db.transaction((txn) async {
        final batch = txn.batch();
        int inserted = 0;

        for (final row in dataRows) {
          if (row.length < 4) continue;

          final eStaId = int.tryParse(row[0].toString().trim());
          final xStaId = int.tryParse(row[1].toString().trim());
          final vCat = int.tryParse(row[2].toString().trim());
          final tTollR = int.tryParse(row[3].toString().trim()) ?? 0;

          if (eStaId != null && xStaId != null && vCat != null) {
            batch.insert(
              'veh_toll_cal_7',
              {
                'e_sta_id': eStaId,
                'x_sta_id': xStaId,
                'v_cat': vCat,
                't_toll_r': tTollR,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            inserted++;
          }
        }

        await batch.commit(noResult: true);
        log('Inserted $inserted toll records');
      });
    } catch (e) {
      log('Error during CSV toll import: $e');
    }
  }
}