import 'package:sembast/sembast.dart';
import 'package:workout_tracker/datasources/local/sembast_database/app_database.dart';
import 'package:workout_tracker/models/timeline.dart';

class TimelineDao {
  static const String TIMELINE_STORE_NAME = 'timeline';
  // A Store with int keys and Map<String, dynamic> values.
  // This Store acts like a persistent map, values of which are Timeline objects converted to Map
  final _timeline = intMapStoreFactory.store(TIMELINE_STORE_NAME);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<int> insert(Timeline timeline) async {
    return await _timeline.add(await _db, timeline.toJson());
  }

  Future update(Timeline timeline) async {
    final finder = Finder(
      filter: Filter.byKey(timeline.id),
    );

    await _timeline.update(
      await _db,
      timeline.toJson(),
      finder: finder,
    );
  }

  Future delete(Timeline timeline) async {
    final finder = Finder(filter: Filter.byKey(timeline.id));
    return await _timeline.delete(
      await _db,
      finder: finder,
    );
  }

  Future<List<Timeline>> getAllSortedByDate() async {
    // Finder object can also sort data.
    final finder = Finder(sortOrders: [
      SortOrder(
        'date',
      ),
    ]);

    final recordSnapshots = await _timeline.find(
      await _db,
      finder: finder,
    );

    // Making a List<Timeline> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final timeline = Timeline.fromJson(snapshot.value);
      // An ID is a key of a record from the database.
      timeline.id = snapshot.key;
      return timeline;
    }).toList();
  }
}
