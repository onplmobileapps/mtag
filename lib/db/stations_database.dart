import 'dart:developer';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StationsDatabase {
  static final StationsDatabase instance = StationsDatabase._init();
  static Database? _database;

  StationsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('veh_toll_cal_7.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // First create the table if it doesn't exist
    await db.execute('''
      CREATE TABLE IF NOT EXISTS motorway_kms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        motorway_name TEXT,
        motorway_id INTEGER,
        station_name TEXT,
        station_id INTEGER UNIQUE NOT NULL,
        station_km REAL,
        total_lane INTEGER,
        seq_id INTEGER,
        img_server TEXT,
        entry_lane INTEGER,
        lat_lng TEXT,
        is_sta_active BOOLEAN
      )
    ''');

    // Then check if we need to import data
    await _checkAndImportData(db);
  }

  Future<bool> _isDatabaseEmpty(Database db) async {
    try {
      final count = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM motorway_kms')) ??
          0;
      return count == 0;
    } catch (e) {
      // If table doesn't exist yet, consider it empty
      return true;
    }
  }

  Future<bool> _isDataComplete(Database db) async {
    try {
      // Check if we have at least one complete record
      final result = await db.rawQuery('''
        SELECT COUNT(*) FROM motorway_kms 
        WHERE motorway_name IS NOT NULL 
          AND motorway_id IS NOT NULL 
          AND station_name IS NOT NULL 
          AND station_id IS NOT NULL
      ''');

      final completeRecords = Sqflite.firstIntValue(result) ?? 0;
      return completeRecords > 0;
    } catch (e) {
      // If there's any error checking completeness, consider data incomplete
      return false;
    }
  }

  Future<void> _checkAndImportData(Database db) async {
    try {
      final isEmpty = await _isDatabaseEmpty(db);
      final isComplete = isEmpty ? false : await _isDataComplete(db);

      if (isEmpty || !isComplete) {
        log('Database is empty or incomplete, importing stations data...');
        await _loadStationsFromCsv(db);
      } else {
        log(
            'Database already contains complete stations data, skipping import.');
      }
    } catch (e) {
      log('Error checking/importing data: $e');
      // If there's an error, try to import data anyway
      await _loadStationsFromCsv(db);
    }
  }

  Future<void> _loadStationsFromCsv(Database db) async {
    try {
      // First ensure the table exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS motorway_kms (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          motorway_name TEXT,
          motorway_id INTEGER,
          station_name TEXT,
          station_id INTEGER UNIQUE NOT NULL,
          station_km REAL,
          total_lane INTEGER,
          seq_id INTEGER,
          img_server TEXT,
          entry_lane INTEGER,
          lat_lng TEXT,
          is_sta_active BOOLEAN
        )
      ''');

      await db.delete('motorway_kms');
      log('Old data cleared.');

      final csvString = await rootBundle.loadString('assets/data/stations.csv');
      final csvData = CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: true,
      ).convert(csvString);

      if (csvData.isEmpty || csvData.length < 2) {
        log('CSV data is empty or invalid.');
        return;
      }

      final dataRows = csvData.sublist(1); // Skip header

      await db.transaction((txn) async {
        final batch = txn.batch();

        for (final row in dataRows) {
          if (row.length < 12) continue;

          batch.insert(
            'motorway_kms',
            {
              'motorway_name': row[1]?.toString(),
              'motorway_id': row[2],
              'station_name': row[3]?.toString(),
              'station_id': row[4],
              'station_km': double.tryParse(row[5].toString()) ?? 0.0,
              'total_lane': row[6],
              'seq_id': row[7],
              'img_server': row[8]?.toString(),
              'entry_lane': row[9],
              'lat_lng': row[10]?.toString(),
              'is_sta_active':
                  row[11].toString().toLowerCase() == 'true' ? 1 : 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        await batch.commit(noResult: true);
        log('Stations loaded: ${dataRows.length}');
      });
    } catch (e) {
      log('Failed to load CSV data: $e');
      rethrow; // Re-throw to handle in calling function
    }
  }

  // Public method to manually trigger data import if needed
  Future<void> importDataIfNeeded() async {
    final db = await database;
    await _checkAndImportData(db);
  }

  // Function to fetch stations based on motorway ID (mwid)
  Future<Map<String, dynamic>> getMotStations(int mwid) async {
    try {
      final db = await database;
      String mwidQuery = '';

      if (mwid == 6 || mwid == 7 || mwid == 11 || mwid == 5) {
        mwidQuery = 'IN (7, 6, 11,5)';
      } else if (mwid == 4 || mwid == 10 || mwid == 14) {
        mwidQuery = 'IN (4, 10, 14)';
      } else {
        mwidQuery = '= $mwid';
      }

      final result = await db.rawQuery('''
        SELECT station_id as stid, station_name as stname 
        FROM motorway_kms 
        WHERE motorway_id $mwidQuery AND is_sta_active = 1
        ORDER BY station_km ASC
      ''');

      if (result.isEmpty) {
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
      log('Database error: $e');
      return {
        "Code": "02",
        "Message": "Database error: ${e.toString()}",
        "Data": []
      };
    }
  }
}
