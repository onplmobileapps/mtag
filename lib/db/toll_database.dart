import 'dart:developer';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:csv/csv.dart';

class TollDatabase {
  static final TollDatabase instance = TollDatabase._init();
  static Database? _database;

  TollDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('veh_toll_cal_7.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE veh_toll_cal_7 (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        e_sta_id INTEGER,
        x_sta_id INTEGER,
        v_cat INTEGER,
        t_toll_r INTEGER DEFAULT 0
      )
    ''');

    // After creating the table, check if we need to import data
    await _checkAndImportData(db);
  }

  Future<bool> _isDatabaseEmpty(Database db) async {
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM veh_toll_cal_7'));
    return count == 0;
  }

  Future<bool> _isDataComplete(Database db) async {
    // Check if we have at least one complete record
    final result = await db.rawQuery('''
      SELECT COUNT(*) FROM veh_toll_cal_7 
      WHERE e_sta_id IS NOT NULL 
        AND x_sta_id IS NOT NULL 
        AND v_cat IS NOT NULL 
        AND t_toll_r IS NOT NULL
    ''');

    final completeRecords = Sqflite.firstIntValue(result) ?? 0;
    return completeRecords > 0;
  }

  Future<void> _checkAndImportData(Database db) async {
    final isEmpty = await _isDatabaseEmpty(db);
    final isComplete = isEmpty ? false : await _isDataComplete(db);

    if (isEmpty || !isComplete) {
      log('Database is empty or incomplete, importing data...');
      await _loadDataFromCsvAndInsert(db);
    } else {
      log('Database already contains complete data, skipping import.');
    }
  }

  Future<void> _loadDataFromCsvAndInsert(Database db) async {
    try {
      await db.delete('veh_toll_cal_7');
      log('Existing data deleted');

      final csvString = await rootBundle.loadString('assets/data/data.csv');
      log('Raw CSV length: ${csvString.length} characters');

      if (csvString.isEmpty) {
        log('Error: CSV file is empty');
        return;
      }

      List<List<dynamic>> csvData;
      try {
        csvData = const CsvToListConverter(
          eol: '\n',
          shouldParseNumbers: true,
        ).convert(csvString);

        if (csvData.isEmpty) {
          log('Error: No rows found in CSV');
          return;
        }

        // Verify the CSV has the expected 4 columns
        if (csvData[0].length != 4) {
          log(
              'Error: Expected 4 columns (e_sta_id, x_sta_id, v_cat, t_toll_r), found ${csvData[0].length}');
          return;
        }

        // Remove header row if present
        if (csvData[0][0] == 'e_sta_id') {
          csvData = csvData.sublist(1);
        }
      } catch (parseError) {
        log('CSV parsing failed: $parseError');
        return;
      }

      await db.transaction((txn) async {
        final batch = txn.batch();
        int insertedRows = 0;

        for (var row in csvData) {
          try {
            // Ensure row has exactly 4 columns and handle null/empty values
            if (row.length == 4) {
              final eStaId = row[0] is int ? row[0] : null;
              final xStaId = row[1] is int ? row[1] : null;
              final vCat = row[2] is int ? row[2] : null;
              final tTollR = row[3] is int ? row[3] : 0;

              // Only insert if critical fields are not null
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
                insertedRows++;
              }
            }
          } catch (e) {
            log('Error inserting row: $e');
          }
        }

        await batch.commit(noResult: true);
        log('Inserted $insertedRows rows');
      });

      log('Data insertion complete!');
    } catch (e) {
      log('Error loading data from CSV: $e');
    }
  }

  // Public method to manually trigger data import if needed
  Future<void> importDataIfNeeded() async {
    final db = await database;
    await _checkAndImportData(db);
  }
}