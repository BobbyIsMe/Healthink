import 'package:healthink/database/food_addons.dart';
import 'package:healthink/database/food_menu.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const int _version = 1;
  static const String _dbName = "MealPlanner.db";

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async =>
      _database ??= await _initiateDatabase();

  Future<Database> _initiateDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(path, version: _version, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE User(
        id INTEGER PRIMARY KEY,
        date VARCHAR(12) NOT NULL,
        foodName VARCHAR(40) NOT NULL,
        category INTEGER NOT NULL,
        price REAL NOT NULL,
        amount INTEGER NOT NULL,
        variant VARCHAR(40) NOT NULL,
        addons VARCHAR(80),
        promos VARCHAR(80),
        addonsValue VARCHAR(80),
        done INTEGER NOT NULL
      );
      ''');
    await db.execute('''
      CREATE TABLE Progress(
        date VARCHAR(12) PRIMARY KEY,
        complete INTEGER NOT NULL,
        incomplete INTEGER NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fats REAL NOT NULL,
        iron REAL NOT NULL,
        zinc REAL NOT NULL,
        b12 REAL NOT NULL,
        price REAL NOT NULL
      );
      ''');
    await db.execute('''
      CREATE TABLE Profile(
        profile TEXT PRIMARY KEY,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fats REAL NOT NULL,
        iron REAL NOT NULL,
        zinc REAL NOT NULL,
        b12 REAL NOT NULL,
        price REAL NOT NULL
      );
      ''');
    await db.execute('''
      CREATE TABLE DateLimit(
        date VARCHAR(12) PRIMARY KEY,
        profile TEXT NOT NULL
      )
    ''');
    await db.insert(
        "Profile",
        ProfileLimiter(
                profile: 'Default',
                calories: 761,
                protein: 34.0,
                carbs: 169.9,
                fats: 30.2,
                iron: 9.75,
                zinc: 2.7,
                b12: 2.4,
                price: 200)
            .toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

//_${DateFormat("MMddyy").format(time)}
  Future<void> addMP(String date, MealPlanner mp) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert("User", mp.toJson(date),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await insertIncomplete(db, date, mp, '+');
  }

  Future<void> addProfile(ProfileLimiter limiter) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert("Profile", limiter.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> setDateLimit(String date, String profile) async {
    final db = await DatabaseHelper.instance.database;
    if (profile != 'Default') {
      await db.insert("DateLimit", {'date': date, 'profile': profile},
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await db.delete(
        "DateLimit",
        where: 'date = ?',
        whereArgs: [date],
      );
    }
  }

  Future<void> deleteLimit(
      String date, String oldProfile, String newProfile) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      "Profile",
      where: 'profile = ?',
      whereArgs: [oldProfile],
    );
    await setDateLimit(date, newProfile);
  }

  Future<void> completeMP(int id, String date, int done) async {
    final db = await DatabaseHelper.instance.database;
    await db.rawUpdate('''
      UPDATE User
      SET done = $done
      WHERE id= ?
      ''', [id]);

    await db.rawUpdate('''
      UPDATE Progress
      SET complete = complete ${(done == 1) ? '+' : '-'} 1,
      incomplete = incomplete ${(done == 0) ? '+' : '-'} 1
      WHERE date = ?
    ''', [date]);
  }

  Future<void> deleteMP(String date, MealPlanner mp) async {
    final db = await DatabaseHelper.instance.database;
    db.delete("User", where: "id = ?", whereArgs: [mp.id]);

    List<Map<String, dynamic>> userMP =
        await db.rawQuery("SELECT COUNT(*) FROM User WHERE date='$date';");

    if (userMP[0]['COUNT(*)'] == 0) {
      await db.delete(
        "Progress",
        where: 'date = ?',
        whereArgs: [date],
      );
      return;
    }

    String done = "";

    if (mp.done == 1) {
      done = "complete";
    } else {
      done = "incomplete";
    }

    updateProgress(db, date, done, '-', mp);
  }

  Future<void> insertIncomplete(
      Database db, String date, MealPlanner mp, String symbol) async {
    final ic = await db.insert(
        "Progress",
        {
          'date': date,
          'complete': 0,
          'incomplete': 1,
          'calories': mp.calories,
          'protein': mp.protein,
          'carbs': mp.carbs,
          'fats': mp.fats,
          'iron': mp.iron,
          'zinc': mp.zinc,
          'b12': mp.b12,
          'price': mp.price,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);

    if (ic != 0) {
      return;
    }

    updateProgress(db, date, 'incomplete', '+', mp);
  }

  Future<void> updateProgress(Database db, String date, String done,
      String symbol, MealPlanner mp) async {
    await db.rawUpdate('''
      UPDATE Progress
      SET $done = $done $symbol 1,
      calories = calories $symbol ${mp.calories},
      protein = protein $symbol ${mp.protein},
      carbs = carbs $symbol ${mp.carbs},
      fats = fats $symbol ${mp.fats},
      iron = iron $symbol ${mp.iron},
      zinc = zinc $symbol ${mp.zinc},
      b12 = b12 $symbol ${mp.b12},
      price = price $symbol ${mp.price}
      WHERE date = ?
    ''', [date]);
  }

  Future<List<MealPlanner>> getAllMP(String date) async {
    final db = await DatabaseHelper.instance.database;

    List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM User WHERE date=?', [date]);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (index) {
      Map<String, dynamic> json = Map.of(maps[index]);
      int category = json['category'];
      int amount = json['amount'];
      String variant = json['variant'];
      String addons = json['addons'];
      String addonsValue = json['addonsValue'];
      String foodName = json['foodName'];
      FoodMenu menu = FoodMenu.menu[category]![foodName]!.variants[variant]!;

      json['calories'] = menu.calories * amount;
      json['protein'] = menu.protein * amount;
      json['carbs'] = menu.carbs * amount;
      json['fats'] = menu.fats * amount;
      json['iron'] = menu.iron * amount;
      json['zinc'] = menu.zinc * amount;
      json['b12'] = menu.b12 * amount;

      if (addons.isNotEmpty) {
        for (String mpAddons in addons.split(",")) {
          for (String mpValues in addonsValue.split(",")) {
            FoodAddons addon = FoodAddons.menu[foodName]![mpAddons]!;
            int adAmount = int.parse(mpValues);
            json['calories'] =
                json['calories'] + ((addon.calories * adAmount) * amount);
            json['protein'] =
                json['protein'] + ((addon.protein * adAmount) * amount);
            json['carbs'] = json['carbs'] + ((addon.carbs * adAmount) * amount);
            json['fats'] = json['fats'] + ((addon.fats * adAmount) * amount);
            json['iron'] = json['iron'] + ((addon.iron * adAmount) * amount);
            json['zinc'] = json['zinc'] + ((addon.zinc * adAmount) * amount);
            json['b12'] = json['b12'] + ((addon.b12 * adAmount) * amount);
          }
        }
      }
      return MealPlanner.fromJson(json);
    });
  }

  Future<ProfileLimiter> getLimit(String date) async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM DateLimit WHERE date=?', [date]);
    List<Map<String, dynamic>>? profile;

    if (maps.isNotEmpty) {
      profile = await db.rawQuery(
          'SELECT * FROM Profile WHERE profile=?', [maps.first['profile']]);
    }

    if (profile != null && profile.isNotEmpty) {
      return ProfileLimiter.fromJson(profile.first);
    } else {
      profile = await db
          .rawQuery('SELECT * FROM Profile WHERE profile=?', ['Default']);
      return ProfileLimiter.fromJson(profile.first);
    }
  }

  Future<Map<String, ProfileLimiter>> getProfiles() async {
    final db = await DatabaseHelper.instance.database;

    List<Map<String, dynamic>> maps = await db.query("Profile");
    Map<String, ProfileLimiter> profiles = {};
    for (Map<String, dynamic> map in maps) {
      profiles[map['profile']] = ProfileLimiter.fromJson(map);
    }

    return profiles;
  }

  Future<void> updateProfile(String profile, ProfileLimiter limiter) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('Profile', limiter.toJsonNoProfile(),
        where: 'profile = ?', whereArgs: [profile]);
  }

  Future<Map<String, MarkerPlanner>?> getAllProgress() async {
    final db = await DatabaseHelper.instance.database;

    List<Map<String, dynamic>> maps = await db.query("Progress");

    if (maps.isEmpty) {
      return null;
    }

    final Map<String, MarkerPlanner> resultMap = {};
    for (Map<String, dynamic> map in maps) {
      final String date = map['date'];
      final MarkerPlanner value = MarkerPlanner.fromJson(map);
      resultMap[date] = value;
    }
    return resultMap;
  }

  ProgressPlanner getProgress(List<MealPlanner> mealPlanners, String date) {
    double calories = 0,
        price = 0,
        protein = 0,
        carbs = 0,
        fats = 0,
        iron = 0,
        zinc = 0,
        b12 = 0;
    for (MealPlanner mP in mealPlanners) {
      calories += mP.calories;
      protein += mP.protein;
      carbs += mP.carbs;
      fats += mP.fats;
      iron += mP.iron;
      zinc += mP.zinc;
      b12 += mP.b12;
      price += mP.price;
    }
    return ProgressPlanner(
        calories: calories,
        protein: protein,
        carbs: carbs,
        fats: fats,
        iron: iron,
        zinc: zinc,
        b12: b12,
        price: price);
  }
}

class ProgressPlanner {
  double calories, price, protein, carbs, fats, iron, zinc, b12;

  ProgressPlanner({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.iron,
    required this.zinc,
    required this.b12,
    required this.price,
  });
}

class MarkerPlanner {
  final int complete;
  final int incomplete;

  const MarkerPlanner({required this.complete, required this.incomplete});

  factory MarkerPlanner.fromJson(Map<String, dynamic> json) =>
      MarkerPlanner(complete: json['complete'], incomplete: json['incomplete']);
}

class MealPlanner {
  final String foodName;
  final int? id;
  final int category;
  final int amount;
  final String variant;
  final String addons;
  final String promos;
  final String addonsValue;
  int done;
  final double calories, price, protein, carbs, fats, iron, zinc, b12;

  MealPlanner(
      {required this.foodName,
      this.id,
      required this.category,
      required this.price,
      required this.amount,
      required this.variant,
      required this.addons,
      required this.promos,
      required this.addonsValue,
      required this.done,
      required this.calories,
      required this.protein,
      required this.carbs,
      required this.fats,
      required this.iron,
      required this.zinc,
      required this.b12});

  factory MealPlanner.fromJson(Map<String, dynamic> json) => MealPlanner(
        foodName: json['foodName'],
        id: json['id'],
        category: json['category'],
        price: json['price'],
        amount: json['amount'],
        variant: json['variant'],
        addons: json['addons'],
        promos: json['promos'],
        addonsValue: json['addonsValue'],
        done: json['done'],
        calories: json['calories'],
        protein: json['protein'],
        carbs: json['carbs'],
        fats: json['fats'],
        iron: json['iron'],
        zinc: json['zinc'],
        b12: json['b12'],
      );

  Map<String, dynamic> toJson(String date) => {
        'date': date,
        'foodName': foodName,
        'category': category,
        'price': price,
        'amount': amount,
        'variant': variant,
        'addons': addons,
        'promos': promos,
        'addonsValue': addonsValue,
        'done': done
      };

  void toggleDone() {
    if (done == 1) {
      done = 0;
    } else {
      done = 1;
    }
  }
}

class ProfileLimiter {
  final String profile;
  final double calories, price, protein, carbs, fats, iron, zinc, b12;

  ProfileLimiter({
    required this.profile,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.iron,
    required this.zinc,
    required this.b12,
    required this.price,
  });

  factory ProfileLimiter.fromJson(Map<String, dynamic> json) => ProfileLimiter(
        profile: json['profile'],
        calories: json['calories'],
        protein: json['protein'],
        carbs: json['carbs'],
        fats: json['fats'],
        iron: json['iron'],
        zinc: json['zinc'],
        b12: json['b12'],
        price: json['price'],
      );

  Map<String, dynamic> toJson() => {
        'profile': profile,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'iron': iron,
        'zinc': zinc,
        'b12': b12,
        'price': price,
      };

  Map<String, dynamic> toJsonNoProfile() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'iron': iron,
        'zinc': zinc,
        'b12': b12,
        'price': price,
      };
}
