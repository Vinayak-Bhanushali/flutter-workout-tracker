import 'package:sembast/sembast.dart';
import 'package:workout_tracker/datasources/local/sembast_database/app_database.dart';
import 'package:workout_tracker/models/workout.dart';

class WorkoutDao {
  static const String WORKOUT_STORE_NAME = 'workout';
  // A Store with int keys and Map<String, dynamic> values.
  // This Store acts like a persistent map, values of which are Workout objects converted to Map
  final _workoutStore = intMapStoreFactory.store(WORKOUT_STORE_NAME);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insert(Workout workout) async {
    await _workoutStore.add(await _db, workout.toJson());
  }

  Future update(Workout workout) async {
    // For filtering by key (ID), RegEx, greater than, and many other criteria,
    // we use a Finder.
    final finder = Finder(
      filter: Filter.byKey(workout.id),
    );

    await _workoutStore.update(
      await _db,
      workout.toJson(),
      finder: finder,
    );
  }

  Future delete(Workout workout) async {
    final finder = Finder(filter: Filter.byKey(workout.id));
    return await _workoutStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future<List<Workout>> getAllSortedByName() async {
    // Finder object can also sort data.
    final finder = Finder(sortOrders: [
      SortOrder('name'),
    ]);

    final recordSnapshots = await _workoutStore.find(
      await _db,
      finder: finder,
    );

    // Making a List<Workout> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final workout = Workout.fromJson(snapshot.value);
      // An ID is a key of a record from the database.
      workout.id = snapshot.key;
      return workout;
    }).toList();
  }
}
