import 'dart:math';

import 'package:sembast/sembast.dart';
import 'package:workout_tracker/datasources/local/sembast_database/app_database.dart';
import 'package:workout_tracker/models/quote.dart';

class QuoteDao {
  static const String QUOTE_STORE_NAME = 'quote';
  // A Store with int keys and Map<String, dynamic> values.
  // This Store acts like a persistent map, values of which are Quote objects converted to Map
  final _quoteStore = intMapStoreFactory.store(QUOTE_STORE_NAME);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insert(Quote quote) async {
    await _quoteStore.add(await _db, quote.toJson());
    deleteOld();
  }

  Future<Quote> getRandom() async {
    int len = await _quoteStore.count(await _db);
    if (len == 0) return null;
    int key = Random().nextInt(len);
    RecordSnapshot snapshot = await _quoteStore.findFirst(
      await _db,
      finder: Finder(
        filter: Filter.byKey(key),
      ),
    );
    if (snapshot == null) return null;
    return Quote.fromJson(snapshot.value);
  }

  deleteAll() async {
    await _quoteStore.drop(await _db);
  }

  deleteOld() async {
    List<int> keys = await _quoteStore.findKeys(await _db);
    if (keys.length > 60) {
      _quoteStore.delete(await _db, finder: Finder(limit: 50));
    }
  }
}
