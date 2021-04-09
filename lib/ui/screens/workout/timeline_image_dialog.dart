import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:workout_tracker/bloc/timeline_bloc/timeline_bloc.dart';
import 'package:workout_tracker/uitilities/common_functions.dart';

class TimelineImageDialog extends StatelessWidget {
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    TimelineBloc _timelineBloc;
    _timelineBloc = BlocProvider.of<TimelineBloc>(context);

    return BlocBuilder(
      cubit: _timelineBloc,
      builder: (context, state) {
        if (state is SingleTimelineLoaded) {
          return Container(
            color: Colors.black45,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FutureBuilder<List<File>>(
                  future: CommonFunctions.generateImageList(
                    state.timeline.imageData,
                    onImageNotFound: (imagePath) =>
                        state.timeline.imageData.remove(imagePath),
                  ),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.done:
                        return CarouselSlider(
                          items: List.generate(
                            snapshot.data.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Center(
                                child: Stack(
                                  overflow: Overflow.visible,
                                  children: [
                                    Image.file(snapshot.data[index]),
                                    Positioned(
                                      top: -10,
                                      right: -10,
                                      child: Material(
                                        color: Colors.white,
                                        shape: CircleBorder(),
                                        child: InkWell(
                                          onTap: () {
                                            snapshot.data[index].deleteSync();
                                            state.timeline.imageData
                                                .removeAt(index);
                                            _timelineBloc.add(
                                              UpdateTimeline(
                                                state.timeline,
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Icon(
                                              Icons.close,
                                              size: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          options: CarouselOptions(
                            initialPage: 0,
                            enableInfiniteScroll: true,
                            enlargeCenterPage: true,
                            viewportFraction: 0.8,
                            aspectRatio: 0.8,
                            autoPlay: true,
                          ),
                        );
                      default:
                        return CircularProgressIndicator();
                    }
                  },
                ),
                FloatingActionButton(
                  onPressed: () async {
                    final pickedFile = await picker.getImage(
                      source: ImageSource.camera,
                      maxHeight: 1920,
                      maxWidth: 1080,
                      imageQuality: 25,
                    );
                    String dir = (await getExternalStorageDirectory()).path;
                    if (pickedFile != null) {
                      File image = File(pickedFile.path);
                      String newName =
                          (state.timeline.imageData.length + 1).toString() +
                              "-" +
                              DateTime.now().toIso8601String() +
                              ".jpeg";
                      File renamed = image.renameSync(path.join(
                        path.join(dir, "Pictures"),
                        newName,
                      ));
                      state.timeline.imageData.add(renamed.path);
                      _timelineBloc.add(
                        UpdateTimeline(state.timeline),
                      );
                    }
                  },
                  child: const Icon(Icons.add_a_photo),
                )
              ],
            ),
          );
        } else
          return Container();
      },
    );
  }
}
