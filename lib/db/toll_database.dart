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
        e_m_name TEXT,
        x_m_name TEXT,
        e_m_id INTEGER,
        x_m_id INTEGER,
        e_sta_name TEXT,
        x_sta_name TEXT,
        e_sta_id INTEGER,
        x_sta_id INTEGER,
        v_cat INTEGER,
        t_toll REAL DEFAULT 0.0,
        t_toll_r INTEGER DEFAULT 0,
        t_km REAL DEFAULT 0.0,
        m1_km REAL DEFAULT 0.0,
        m1_toll REAL DEFAULT 0.0,
        m1_toll_r INTEGER DEFAULT 0,
        m1_adj INTEGER DEFAULT 0,
        e35_km REAL DEFAULT 0.0,
        e35_toll REAL DEFAULT 0.0,
        e35_toll_r INTEGER DEFAULT 0,
        e35_adj INTEGER DEFAULT 0,
        m14_km REAL DEFAULT 0.0,
        m14_toll REAL DEFAULT 0.0,
        m14_toll_r INTEGER DEFAULT 0,
        m14_adj INTEGER DEFAULT 0,
        smp_km REAL DEFAULT 0.0,
        smp_toll REAL DEFAULT 0.0,
        smp_toll_r INTEGER DEFAULT 0,
        smp_adj INTEGER DEFAULT 0,
        lsm_km REAL DEFAULT 0.0,
        lsm_toll REAL DEFAULT 0.0,
        lsm_toll_r INTEGER DEFAULT 0,
        lsm_adj INTEGER DEFAULT 0,
        m2_km REAL DEFAULT 0.0,
        m2_toll REAL DEFAULT 0.0,
        m2_toll_r INTEGER DEFAULT 0,
        m2_adj INTEGER DEFAULT 0,
        m3_km REAL DEFAULT 0.0,
        m3_toll REAL DEFAULT 0.0,
        m3_toll_r INTEGER DEFAULT 0,
        m3_adj INTEGER DEFAULT 0,
        m4_km REAL DEFAULT 0.0,
        m4_toll REAL DEFAULT 0.0,
        m4_toll_r INTEGER DEFAULT 0,
        m4_adj INTEGER DEFAULT 0,
        m5_km REAL DEFAULT 0.0,
        m5_toll REAL DEFAULT 0.0,
        m5_toll_r INTEGER DEFAULT 0,
        m5_adj INTEGER DEFAULT 0,
        m9_km REAL DEFAULT 0.0,
        m9_toll REAL DEFAULT 0.0,
        m9_toll_r INTEGER DEFAULT 0,
        m9_adj INTEGER DEFAULT 0,
        e_is_north INTEGER,
        m1_rate REAL DEFAULT 0.0,
        e35_rate REAL DEFAULT 0.0,
        m14_rate REAL DEFAULT 0.0,
        smp_rate REAL DEFAULT 0.0,
        lsm_rate REAL DEFAULT 0.0,
        m2_rate REAL DEFAULT 0.0,
        m3_rate REAL DEFAULT 0.0,
        m4_rate REAL DEFAULT 0.0,
        m5_rate REAL DEFAULT 0.0,
        m9_rate REAL DEFAULT 0.0,
        c_rate INTEGER DEFAULT 0,
        p_rate INTEGER DEFAULT 0,
        updated_by TEXT,
        c_timestamp TEXT,
        u_timestamp TEXT,
        is_north INTEGER
      )
    ''');
  }

  Future<void> loadDataFromCsvAndInsert() async {
    try {
      final db = await database;
      await db.delete('veh_toll_cal_7');

      print('Existing data deleted');

      final csvString = await rootBundle.loadString('assets/data/data.csv');
      print('Raw CSV length: ${csvString.length} characters');

      if (csvString.isEmpty) {
        print('Error: CSV file is empty');
        await db.close();
        return;
      }

      List<List<dynamic>> csvData;
      try {
        csvData = CsvToListConverter(
          eol: '\n',
          shouldParseNumbers: true,
        ).convert(csvString);

        if (csvData.isEmpty) {
          print('Error: No rows found in CSV');
          await db.close();
          return;
        }

        if (csvData[0].length < 69) {
          print(
              'Error: Expected at least 69 columns, found ${csvData[0].length}');
          await db.close();
          return;
        }

        csvData = csvData.sublist(1);
      } catch (parseError) {
        print('CSV parsing failed: $parseError');
        await db.close();
        return;
      }

      await db.transaction((txn) async {
        final batch = txn.batch();
        int insertedRows = 0;

        for (var row in csvData) {
          try {
            batch.insert(
              'veh_toll_cal_7',
              {
                'e_m_name': row[1].toString(),
                'x_m_name': row[2].toString(),
                'e_m_id': row[3],
                'x_m_id': row[4],
                'e_sta_name': row[5].toString(),
                'x_sta_name': row[6].toString(),
                'e_sta_id': row[7],
                'x_sta_id': row[8],
                'v_cat': row[9],
                't_toll': row[10]?.toDouble() ?? 0.0,
                't_toll_r': row[11],
                't_km': row[12]?.toDouble() ?? 0.0,
                'm1_km': row[13]?.toDouble() ?? 0.0,
                'm1_toll': row[14]?.toDouble() ?? 0.0,
                'm1_toll_r': row[15],
                'm1_adj': row[16],
                'e35_km': row[17]?.toDouble() ?? 0.0,
                'e35_toll': row[18]?.toDouble() ?? 0.0,
                'e35_toll_r': row[19],
                'e35_adj': row[20],
                'm14_km': row[21]?.toDouble() ?? 0.0,
                'm14_toll': row[22]?.toDouble() ?? 0.0,
                'm14_toll_r': row[23],
                'm14_adj': row[24],
                'smp_km': row[25]?.toDouble() ?? 0.0,
                'smp_toll': row[26]?.toDouble() ?? 0.0,
                'smp_toll_r': row[27],
                'smp_adj': row[28],
                'lsm_km': row[29]?.toDouble() ?? 0.0,
                'lsm_toll': row[30]?.toDouble() ?? 0.0,
                'lsm_toll_r': row[31],
                'lsm_adj': row[32],
                'm2_km': row[33]?.toDouble() ?? 0.0,
                'm2_toll': row[34]?.toDouble() ?? 0.0,
                'm2_toll_r': row[35],
                'm2_adj': row[36],
                'm3_km': row[37]?.toDouble() ?? 0.0,
                'm3_toll': row[38]?.toDouble() ?? 0.0,
                'm3_toll_r': row[39],
                'm3_adj': row[40],
                'm4_km': row[41]?.toDouble() ?? 0.0,
                'm4_toll': row[42]?.toDouble() ?? 0.0,
                'm4_toll_r': row[43],
                'm4_adj': row[44],
                'm5_km': row[45]?.toDouble() ?? 0.0,
                'm5_toll': row[46]?.toDouble() ?? 0.0,
                'm5_toll_r': row[47],
                'm5_adj': row[48],
                'm9_km': row[49]?.toDouble() ?? 0.0,
                'm9_toll': row[50]?.toDouble() ?? 0.0,
                'm9_toll_r': row[51],
                'm9_adj': row[52],
                'e_is_north': row[53],
                'm1_rate': row[54]?.toDouble() ?? 0.0,
                'e35_rate': row[55]?.toDouble() ?? 0.0,
                'm14_rate': row[56]?.toDouble() ?? 0.0,
                'smp_rate': row[57]?.toDouble() ?? 0.0,
                'lsm_rate': row[58]?.toDouble() ?? 0.0,
                'm2_rate': row[59]?.toDouble() ?? 0.0,
                'm3_rate': row[60]?.toDouble() ?? 0.0,
                'm4_rate': row[61]?.toDouble() ?? 0.0,
                'm5_rate': row[62]?.toDouble() ?? 0.0,
                'm9_rate': row[63]?.toDouble() ?? 0.0,
                'c_rate': row[64],
                'p_rate': row[65],
                'updated_by': row[66]?.toString(),
                'c_timestamp': row[67]?.toString(),
                'u_timestamp': row[68]?.toString(),
                'is_north': row[69]
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            insertedRows++;
          } catch (e) {
            print('Error inserting row: $e');
          }
        }

        await batch.commit(noResult: true);
        print('Inserted $insertedRows rows');
      });

      print('Data insertion complete!');
    } catch (e) {
      print('Error loading data from CSV: $e');
    }
  }
}
