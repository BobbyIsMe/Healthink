import 'package:flutter/material.dart';
import 'package:healthink/pages/calendar_page.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //deleteDatabaseIfExists();
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.green,
      home: MainPage(),
    );
  }

  Future<void> deleteDatabaseIfExists() async {
    try {
      // Get the path to the database file
      String databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'MealPlanner.db');

      // Check if the database exists
      bool databaseExistse = await databaseExists(path);

      if (databaseExistse) {
        // Delete the database file
        await deleteDatabase(path);
        print('Database deleted successfully.');
      } else {
        print('Database does not exist.');
      }
    } catch (e) {
      print('Error deleting database: $e');
    }
  }
}
