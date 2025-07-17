
import 'dart:developer';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

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

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS motorway_kms (
        id INTEGER PRIMARY KEY,
        motorway_name TEXT,
        motorway_id INTEGER,
        station_name TEXT,
        station_id INTEGER UNIQUE NOT NULL,
        is_sta_active BOOLEAN
      )
    ''');
  }

  Future<int> _getCsvVersion() async {
    final csvString = await rootBundle.loadString('assets/data/stations.csv');
    final firstLine = csvString.split('\n').first.trim();
    if (firstLine.startsWith('#version=')) {
      return int.tryParse(firstLine.split('=').last.trim()) ?? 1;
    }
    return 1;
  }

  Future<int> _getStoredVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('csv_version') ?? 0;
  }

  Future<void> _setStoredVersion(int version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('csv_version', version);
  }

  Future<void> importDataIfNeeded() async {
    final db = await database;
    final currentVersion = await _getCsvVersion();
    final savedVersion = await _getStoredVersion();

    if (savedVersion < currentVersion) {
      log('New CSV version detected: $currentVersion (old: $savedVersion), importing...');
      await _loadStationsFromCsv(db);
      await _setStoredVersion(currentVersion);
    } else {
      log('CSV version $currentVersion already imported, skipping...');
    }
  }

  Future<void> _loadStationsFromCsv(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS motorway_kms (
          id INTEGER PRIMARY KEY,
          motorway_name TEXT,
          motorway_id INTEGER,
          station_name TEXT,
          station_id INTEGER UNIQUE NOT NULL,
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

      final dataRows = csvData
          .where((row) => row.isNotEmpty && !row[0].toString().startsWith('#'))
          .toList()
          .sublist(1); // skip header

      await db.transaction((txn) async {
        final batch = txn.batch();

        for (final row in dataRows) {
          if (row.length < 12) continue;

          batch.insert(
            'motorway_kms',
            {
              'id': row[0],
              'motorway_name': row[1]?.toString(),
              'motorway_id': row[2],
              'station_name': row[3]?.toString(),
              'station_id': row[4],
              'is_sta_active': row[11].toString().toLowerCase() == 'true' ? 1 : 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        await batch.commit(noResult: true);
        log('Stations imported: ${dataRows.length}');
      });
    } catch (e) {
      log('CSV import failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMotStations(int mwid) async {
    try {
      final db = await database;
      String mwidQuery;

      if ([6, 7, 11, 5].contains(mwid)) {
        mwidQuery = 'IN (7, 6, 11, 5)';
      } else if ([4, 10, 14].contains(mwid)) {
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
      log('getMotStations error: $e');
      return {
        "Code": "02",
        "Message": "Database error: ${e.toString()}",
        "Data": []
      };
    }
  }
}
