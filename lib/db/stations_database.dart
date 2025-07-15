import 'dart:developer';
import 'package:csv/csv.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StationsDatabase {
  static final StationsDatabase instance = StationsDatabase._init();
  static Database? _database;

  StationsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('veh_toll_cal_8.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    log('Database path: $path');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS motorway_kms (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          motorway_name TEXT,
          motorway_id INTEGER,
          station_name TEXT,
          station_id INTEGER UNIQUE NOT NULL,
          is_sta_active INTEGER
        )
      ''');
      await _checkAndImportData(db);
    } catch (e) {
      log('Error creating database: $e');
      rethrow;
    }
  }

  Future<bool> _isDatabaseEmpty(Database db) async {
    try {
      final count = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM motorway_kms')) ??
          0;
  
      return count == 0;
    } catch (e) {
      log('Error checking if database is empty: $e');
      return true;
    }
  }

  Future<bool> _isDataComplete(Database db) async {
    try {
      final result = await db.rawQuery('''
        SELECT COUNT(*) FROM motorway_kms 
        WHERE motorway_name IS NOT NULL 
          AND motorway_id IS NOT NULL 
          AND station_name IS NOT NULL 
          AND station_id IS NOT NULL
      ''');
      final completeRecords = Sqflite.firstIntValue(result) ?? 0;
      log('Complete records count: $completeRecords');
      return completeRecords > 0;
    } catch (e) {
      log('Error checking data completeness: $e');
      return false;
    }
  }

  Future<void> _checkAndImportData(Database db) async {
    try {
      final isEmpty = await _isDatabaseEmpty(db);
      final isComplete = isEmpty ? false : await _isDataComplete(db);

      if (isEmpty || !isComplete) {
    
        await _loadStationsFromCsv(db);
      } else {
      
      }
    } catch (e) {
      log('Error checking/importing data: $e');
      await _loadStationsFromCsv(db);
    }
  }

  Future<void> _loadStationsFromCsv(Database db) async {
    try {
      await db.delete('motorway_kms');
      log('Cleared old data from motorway_kms table.');

      final csvString = await DefaultAssetBundle.of(Get.context!).loadString('assets/data/stations.csv');
      log('CSV content (first 200 chars): ${csvString.substring(0, csvString.length.clamp(0, 200))}');
      final csvData = CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: true,
      ).convert(csvString);

      if (csvData.isEmpty || csvData.length < 2) {
        log('CSV data is empty or invalid. Rows: ${csvData.length}');
        return;
      }

      final dataRows = csvData.sublist(1);
      log('CSV data rows: ${dataRows.length}');

      await db.transaction((txn) async {
        final batch = txn.batch();
        int rowCount = 0;

        for (final row in dataRows) {
          if (row.length < 6) {
            log('Skipping invalid row (length < 6): $row');
            continue;
          }

          batch.insert(
            'motorway_kms',
            {
              'id': row[0],
              'motorway_name': row[1]?.toString(),
              'motorway_id': row[2],
              'station_name': row[3]?.toString(),
              'station_id': row[4],
              'is_sta_active': row[5].toString().toLowerCase() == 'true' ? 1 : 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          rowCount++;
        }

        await batch.commit(noResult: true);
      
      });

      await debugMotorwayIds([4, 10, 14, 5, 6, 7, 11]);
    } catch (e) {
     
      rethrow;
    }
  }

  Future<void> dumpTableContents() async {
    final db = await database;
    final result = await db.rawQuery('SELECT * FROM motorway_kms');
    log('motorway_kms table contents: $result');
  }

  Future<void> debugMotorwayIds(List<int> motorwayIds) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT * FROM motorway_kms WHERE motorway_id IN (${motorwayIds.join(',')})');
    log('Records for motorway_id IN (${motorwayIds.join(',')}): $result');
    final activeResult = await db.rawQuery(
        'SELECT * FROM motorway_kms WHERE motorway_id IN (${motorwayIds.join(',')}) AND is_sta_active = 1');
    log('Active records for motorway_id IN (${motorwayIds.join(',')}): $activeResult');
  }

  Future<void> activateStations(List<int> motorwayIds) async {
    final db = await database;
    await db.rawUpdate(
        'UPDATE motorway_kms SET is_sta_active = 1 WHERE motorway_id IN (${motorwayIds.join(',')})');
    log('Activated stations for motorway_id IN (${motorwayIds.join(',')})');
    await debugMotorwayIds(motorwayIds);
  }

  Future<Map<String, dynamic>> getMotStations(int mwid) async {
    try {
      final db = await database;
      String mwidQuery = '';

      if (mwid == 6 || mwid == 7 || mwid == 11 || mwid == 5) {
        mwidQuery = 'IN (7, 6, 11, 5)';
      } else if (mwid == 4 || mwid == 10 || mwid == 14) {
        mwidQuery = 'IN (4, 10, 14)';
      } else {
        mwidQuery = '= $mwid';
      }

      final result = await db.rawQuery('''
        SELECT station_id as stid, station_name as stname 
        FROM motorway_kms 
        WHERE motorway_id $mwidQuery AND is_sta_active = 1
        ORDER BY station_id ASC
      ''');

      log('Query executed: SELECT station_id as stid, station_name as stname FROM motorway_kms WHERE motorway_id $mwidQuery AND is_sta_active = 1');
    

      if (result.isEmpty) {
        await debugMotorwayIds(
            mwid == 6 || mwid == 7 || mwid == 11 || mwid == 5
                ? [7, 6, 11, 5]
                : mwid == 4 || mwid == 10 || mwid == 14
                    ? [4, 10, 14]
                    : [mwid]);
        return {
          "Code": "01",
          "Message": "No stations found for motorway $mwid",
          "Data": []
        };
      }

      return {
        "Code": "00",
        "Message": "Success",
        "Data": result,
      };
    } catch (e) {
      log('Database error in getMotStations: $e');
      return {
        "Code": "02",
        "Message": "Database error: ${e.toString()}",
        "Data": []
      };
    }
  }

  Future<void> importDataIfNeeded() async {
    final db = await database;
    await _checkAndImportData(db);
  }
}