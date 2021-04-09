import 'package:sembast/sembast.dart';
import 'package:workout_tracker/datasources/local/sembast_database/app_database.dart';
import 'package:workout_tracker/models/user_workout.dart';

class UserWorkoutDao {
  static const String USERWORKOUT_STORE_NAME = 'userWorkout';
  // A Store with int keys and Map<String, dynamic> values.
  // This Store acts like a persistent map, values of which are UserWorkout objects converted to Map
  final _userWorkoutStore = intMapStoreFactory.store(USERWORKOUT_STORE_NAME);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<int> insert(UserWorkout userWorkout) async {
    return await _userWorkoutStore.add(await _db, userWorkout.toJson());
  }

  Future update(UserWorkout userWorkout) async {
    // For filtering by key (ID), RegEx, greater than, and many other criteria,
    // we use a Finder.
    final finder = Finder(
      filter: Filter.byKey(userWorkout.id),
    );

    return await _userWorkoutStore.update(
      await _db,
      userWorkout.toJson(),
      finder: finder,
    );
  }

  Future delete(UserWorkout userWorkout) async {
    final finder = Finder(filter: Filter.byKey(userWorkout.id));
    return await _userWorkoutStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future<List<UserWorkout>> getAllSortedByDate() async {
    // Finder object can also sort data.
    final finder = Finder(
      sortOrders: [
        SortOrder('startTime', false),
      ],
    );

    final recordSnapshots = await _userWorkoutStore.find(
      await _db,
      finder: finder,
    );

    // Making a List<UserWorkout> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final userWorkout = UserWorkout.fromJson(snapshot.value);
      // An ID is a key of a record from the database.
      userWorkout.id = snapshot.key;
      return userWorkout;
    }).toList();
  }

  Future<List<UserWorkout>> getAllRecentWithLimit(int offset, int limit) async {
    // Finder object can also sort data.
    final finder = Finder(
      offset: offset,
      limit: limit,
      sortOrders: [
        SortOrder('startTime', false),
      ],
    );

    final recordSnapshots = await _userWorkoutStore.find(
      await _db,
      finder: finder,
    );

    // Making a List<UserWorkout> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final userWorkout = UserWorkout.fromJson(snapshot.value);
      // An ID is a key of a record from the database.
      userWorkout.id = snapshot.key;
      return userWorkout;
    }).toList();
  }

  Future<List<UserWorkout>> getAllAfter(
      UserWorkout userWorkout, int limit) async {
    final record = await _userWorkoutStore.findFirst(await _db,
        finder: Finder(filter: Filter.byKey(userWorkout.id)));
    final finder = Finder(
      start: Boundary(
        record: record,
        include: false,
      ),
      sortOrders: [
        SortOrder('startTime', false),
      ],
      limit: limit,
    );

    final recordSnapshots = await _userWorkoutStore.find(
      await _db,
      finder: finder,
    );

    // Making a List<UserWorkout> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final userWorkout = UserWorkout.fromJson(snapshot.value);
      // An ID is a key of a record from the database.
      userWorkout.id = snapshot.key;
      return userWorkout;
    }).toList();
  }

  Future<List<UserWorkout>> getAllWorkoutsinRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Finder object can also sort data.
    final finder = Finder(
      filter: Filter.and([
        Filter.greaterThanOrEquals(
          'startTime',
          startDate.millisecondsSinceEpoch,
        ),
        Filter.lessThanOrEquals(
          'endTime',
          endDate.millisecondsSinceEpoch,
        ),
      ]),
      sortOrders: [
        SortOrder('startTime', false),
      ],
    );

    final recordSnapshots = await _userWorkoutStore.find(
      await _db,
      finder: finder,
    );

    // Making a List<UserWorkout> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final userWorkout = UserWorkout.fromJson(snapshot.value);
      // An ID is a key of a record from the database.
      userWorkout.id = snapshot.key;
      return userWorkout;
    }).toList();
  }
}
