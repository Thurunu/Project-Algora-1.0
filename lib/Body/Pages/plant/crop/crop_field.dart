import 'package:drop_shadow_image/drop_shadow_image.dart';
import 'package:flutter/material.dart';
import 'package:project_algora_2/Body/Pages/Back/crop_field_back.dart';
import 'package:project_algora_2/Body/Pages/plant/crop/bar_graph.dart';
import 'package:project_algora_2/Body/Pages/plant/crop/crop_status.dart';
import 'package:project_algora_2/Body/Pages/plant/crop/recommendations.dart';

class CropField extends StatefulWidget {
  String name;
  String imageUrl;
  int day;
  DateTime plantedDate;
  CropField({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.day,
    required this.plantedDate,
  });

  @override
  State<CropField> createState() => _CropFieldState();
}

class _CropFieldState extends State<CropField> {
  String date = '';
  double todayPh = 7.0;
  int feedingDate = 0;
  final controller = TextEditingController();
  CropFieldBackEnd backEnd = CropFieldBackEnd();
  @override
  void initState() {
    super.initState();
    updateDate(); // Rename to reflect the action
    fetchDataAndUpdate(); // This will fetch data once and update the state
  }

  void updateDate() {
    if (widget.day < 0) {
      date = '${-widget.day} days ago';
    } else if (widget.day == 0) {
      date = 'Today';
    }
    // No need for setState here since initState hasn't completed yet
  }

  Future<void> fetchDataAndUpdate() async {
    await backEnd.fetchData(widget.name.toLowerCase(), widget.plantedDate);
    // Only call setState if there's new data to update
    if (mounted) { // Check if the widget is still in the tree
      setState(() {
        feedingDate = -1*(backEnd.getFeedDay());
        // any other state updates
      });
    }
  }

  Future openBox() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Input PH'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'PH value'),
          ),
          actions: [
            TextButton(
              onPressed: submit,
              child: const Text('Submit'),
            ),
          ],
        ),
      );

  void submit() {
    setState(() {
      todayPh = double.parse(controller.text);
    });
    print(todayPh);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Change the app bar color to white
        foregroundColor: Colors.black,
        title: Center(
            child: Text(
          widget.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  child: Text('Option 1'),
                  value: 'option1',
                ),
                const PopupMenuItem(
                  child: Text('Option 2'),
                  value: 'option2',
                ),
                // Add more options as needed
              ];
            },
            onSelected: (value) {
              // Handle the selected option here
              if (value == 'option1') {
                // Perform action for Option 1
              } else if (value == 'option2') {
                // Perform action for Option 2
              }
              // Add more cases for other options
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: screenHeight % 20,
            right: screenWidth % 20,
            left: screenWidth % 20,
            bottom: screenHeight % 100,
          ),
          child: Column(
            children: [
              // Crop image
              Container(
                width: screenWidth - 40,
                height: screenHeight / 5,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Soil moisture details
              Container(
                width: screenWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(172, 213, 178, 0.2),
                ),
                padding: const EdgeInsets.only(
                    top: 15,
                    bottom: 15,
                    left: 20), // Add padding to space out the content
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Soil Moisture Status',
                      style: TextStyle(
                        fontSize: 20, // Adjust the font size as needed
                        fontWeight: FontWeight.bold, // Make it bold
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.only(top: 3, left: 8),
                      child: Text(
                        'Last update today at 11.00 a.m',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16), // Add more spacing
                    GestureDetector(
                      onTap: openBox,
                      child: Container(
                        height: screenHeight / 10,
                        width: screenWidth - 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.black12),
                        child: MyBarGraph(
                          screenWidth: screenWidth,
                          todayPh: todayPh,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), // Add more spacing
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.paste),
                        SizedBox(
                            width: 6), // Add spacing between the icon and text
                        Text(
                          'History',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ],
                ),
              ),
              // Crop status
              Container(
                color: Colors.grey[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Align the text and button to the start and end of the row
                      children: [
                        const Text(
                          'Crop Status',
                          style: TextStyle(
                            fontSize: 20, // Adjust the font size as needed
                            fontWeight: FontWeight.bold, // Make it bold
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('setup'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // Add spacing
                    cropStatus(Image.asset('assets/icons/Plant Icon.webp'),
                        'Planting date', 'Nov 6', date),
                    const SizedBox(height: 16), // Add spacing
                    cropStatus(Image.asset('assets/icons/Dressing.webp'),
                        '1st dressing', 'Nov 25', '$feedingDate days to go'),
                    const SizedBox(height: 16), // Add spacing
                    cropStatus(Image.asset('assets/icons/Watering.webp'),
                        'Watering', 'Nov 23', '1 day ago'),
                  ],
                ),
              ),
              // Recommendations
              Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recommendations',
                          style: TextStyle(
                            fontSize: 20, // Adjust the font size as needed
                            fontWeight: FontWeight.bold, // Make it bold
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('see more'),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          recommendations(
                              'Planting',
                              "Transplant the seedling to the field14-18 days after sowing.",
                              screenHeight,
                              screenWidth),
                          const SizedBox(
                            width: 10,
                          ),
                          recommendations(
                              'Fertilizing',
                              "Mix 10 t/ha of well decomposed organic matter with the soil of selected field.",
                              screenHeight,
                              screenWidth),
                          const SizedBox(
                            width: 10,
                          ),
                          recommendations(
                              'Watering',
                              "Don’t apply excess water specially in dry season. It causes fruit crack.",
                              screenHeight,
                              screenWidth),
                          SizedBox(
                            width: 10,
                          ),
                          recommendations(
                              'Watering',
                              "Don’t apply excess water specially in dry season. It causes fruit crack.",
                              screenHeight,
                              screenWidth),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
