import 'package:flutter/material.dart';
import 'package:project_algora_2/Body/Pages/Back/back_end.dart';
import 'package:project_algora_2/Body/Pages/Back/crop_profile.dart';
import 'package:project_algora_2/widgets/Buttons/plant_adding_button.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class UserPlantList extends StatefulWidget {
  const UserPlantList({super.key});

  @override
  State<UserPlantList> createState() => _UserPlantListState();
}

class _UserPlantListState extends State<UserPlantList> {
  List<Map<String, dynamic>> cropDataList = [];
  String image = '';
  BackEnd backend = BackEnd();

  @override
  void initState() {
    super.initState();
    processCropData();
  }

  Future<void> processCropData() async {
    Map<String, dynamic> cropData = await backend.getCropData();

    if (!cropData.containsKey('Error')) {
      cropDataList = cropData['Crops'] ?? [];
    } else {
      String error = cropData['Error'];
      print("Error: $error");
    }
  }

  Future<void> imageData(String name) async {
    image = await backend.getImageUrl(name);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Crop List'),
          centerTitle: true,
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false, // Set this property to false
        ),
        body: Stack(
          children: [
            ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: cropDataList.length,
              itemBuilder: (context, index) {
                final cropItem = cropDataList[index];
                final name = cropItem['name'] ?? '';
                final plantedData = cropItem['planted_data'];
                final formattedDate = plantedData != null
                    ? "${plantedData.day}-${plantedData.month}-${plantedData.year}"
                    : '';

                return FutureBuilder<void>(
                  future: imageData(name),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 10, left: 20, right: 20, bottom: 10),
                        child: Container(
                            width: screenWidth - 20,
                            height: screenHeight / 6,
                            child: CropProfile(
                                name: name,
                                date: formattedDate,
                                imageUrl: image)),
                      );
                    } else {
                      // You can return a loading indicator or placeholder here if needed.
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SimpleCircularProgressBar(
                          // valueNotifier: valueNotifier,
                          progressStrokeWidth: 16,
                          backStrokeWidth: 0,
                          animationDuration: 2,
                          mergeMode: true,
                          onGetText: (value) {
                            return Text(
                              '${value.toInt()}',
                              // style: centerTextStyle,
                            );
                          },
                          progressColors: [
                            Colors.green.shade400,
                            Colors.green.shade800
                          ],
                          backColor: Colors.black.withOpacity(0.4),
                        ),
                      ); // Example loading indicator.
                    }
                  },
                );
              },
            ),
            PlantAddingButton(),
          ],
        ),
      ),
    );
  }
}
