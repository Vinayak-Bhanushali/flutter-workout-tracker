import 'package:sembast/sembast.dart';
import 'package:workout_tracker/datasources/local/sembast_database/app_database.dart';
import 'package:workout_tracker/models/exercise.dart';
import 'package:workout_tracker/models/workout.dart';

class ExerciseDao {
  static const String EXERCISE_STORE_NAME = 'exercise';
  // A Store with int keys and Map<String, dynamic> values.
  // This Store acts like a persistent map, values of which are Exercise objects converted to Map
  final _exerciseStore = intMapStoreFactory.store(EXERCISE_STORE_NAME);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insert(Exercise exercise) async {
    await _exerciseStore.add(await _db, exercise.toJson());
  }

  Future update(Exercise exercise) async {
    // For filtering by key (ID), RegEx, greater than, and many other criteria,
    // we use a Finder.
    final finder = Finder(
      filter: Filter.byKey(exercise.id),
    );

    await _exerciseStore.update(
      await _db,
      exercise.toJson(),
      finder: finder,
    );
  }

  Future delete(Exercise exercise) async {
    final finder = Finder(filter: Filter.byKey(exercise.id));
    return await _exerciseStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future increaseFrequency(int exerciseId) async {
    final finder = Finder(
      filter: Filter.byKey(exerciseId),
    );

    final snapShot = await _exerciseStore.findFirst(
      await _db,
      finder: finder,
    );

    if (snapShot != null) {
      final exercise = Exercise.fromJson(snapShot.value);
      exercise.id = snapShot.key;

      exercise.frequency += 1;
      await _exerciseStore.update(
        await _db,
        exercise.toJson(),
        finder: finder,
      );
    }
  }

  Future decreaseFrequency(int exerciseId) async {
    final finder = Finder(
      filter: Filter.byKey(exerciseId),
    );

    final snapShot = await _exerciseStore.findFirst(
      await _db,
      finder: finder,
    );

    if (snapShot != null) {
      final exercise = Exercise.fromJson(snapShot.value);
      exercise.id = snapShot.key;

      exercise.frequency -= 1;
      await _exerciseStore.update(
        await _db,
        exercise.toJson(),
        finder: finder,
      );
    }
  }

  Future removeWorkoutFromExercises(Workout workout) async {
    List<Exercise> exercises = await getAllByWorkout(workout);
    exercises.forEach((exercise) {
      exercise.workoutIDs.remove(workout.id);
    });
    exercises.forEach((exercise) async {
      await update(exercise);
    });
  }

  Future<List<Exercise>> getAllSortedByName() async {
    // Finder object can also sort data.
    final finder = Finder(sortOrders: [
      SortOrder(
        'dailyExercise',
      ),
      SortOrder(
        'frequency',
        false,
      ),
      SortOrder('name'),
    ]);

    final recordSnapshots = await _exerciseStore.find(
      await _db,
      finder: finder,
    );

    // Making a List<Exercise> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final exercise = Exercise.fromJson(snapshot.value);
      // An ID is a key of a record from the database.
      exercise.id = snapshot.key;
      return exercise;
    }).toList();
  }

  Future<List<Exercise>> getAllByWorkout(Workout workout,
      {bool inverse = false}) async {
    // Finder object can also sort data.
    final finder = Finder(
      filter: Filter.custom(
        (RecordSnapshot recordSnapshot) => inverse
            ? !recordSnapshot.value['workoutIDs'].contains(workout.id)
            : recordSnapshot.value['workoutIDs'].contains(workout.id),
      ),
      sortOrders: [
        SortOrder(
          'dailyExercise',
          // if its all workout show dailyexercises first
          !inverse,
        ),
        SortOrder(
          'frequency',
          false,
        ),
      ],
    );

    final recordSnapshots = await _exerciseStore.find(
      await _db,
      finder: finder,
    );

    // Making a List<Exercise> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final exercise = Exercise.fromJson(snapshot.value);
      // An ID is a key of a record from the database.
      exercise.id = snapshot.key;
      return exercise;
    }).toList();
  }
}
