import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:weather_app/secrets.dart';
import "addtional_information_screen.dart";
import 'hrs_forecast_disply_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class weatherScreen extends StatefulWidget {
  const weatherScreen({super.key});

  @override
  State<weatherScreen> createState() => _weatherScreenState();
}

class _weatherScreenState extends State<weatherScreen> {
  late Future <Map<String,dynamic>> weather;

  @override
  void initState() {
    super.initState();
    weather=getWeather();
  }

  Future<Map<String, dynamic>> getWeather() async {
    try {
      final result = await http.get(
        Uri.parse(
          "http://api.openweathermap.org/data/2.5/forecast?q=mumbai&appid=$openWeatherApiKey",
        ),
      );
      final data = jsonDecode(result.body);
      if (data['cod'] != '200') {
        throw ("an unexpected error occur");
      }
      return data;
    } catch (e) {
      throw (e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Weather App",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
              weather = getWeather();
              });
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final data = snapshot.data!;
          final currenTemp = data['list'][0]['main']['temp'];
          final temp =  currenTemp- 273.15;

          final currentWeather = data['list'][0]['weather'][0]['main'];
          final humidity = data['list'][0]['main']['humidity'];
          final windSpeed = data['list'][0]['wind']['speed'];
          final pressure = data['list'][0]['main']['pressure'];


          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "${temp.toStringAsFixed(2)} °C",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                              ),
                              SizedBox(height: 16),
                              Icon(
                                currentWeather == 'Clouds' ||
                                        currentWeather == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 60,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "$currentWeather",
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // space
                Text(
                  "Weather Forecast",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 9),

                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 5; i++)
                //         hrsForcastDisply(
                //           time: "${data['list'][i + 1]['dt']}",
                //           icon:
                //               data['list'][i + 1]['weather'][0]['main'] ==
                //                       "Clouds" ||
                //                   data['list'][i + 1]['weather'][0]['main'] ==
                //                       "Rain"
                //               ? Icons.cloud
                //               : Icons.sunny,
                //           temp: "${data['list'][i + 1]['main']['temp']}k",
                //         ),
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final time = DateTime.parse(data['list'][index + 1]['dt_txt']);
                      return hrsForcastDisply(
                        // data['list'][index+1]['dt'].toString()
                        time: DateFormat.j().format(time),
                        icon:
                            data['list'][index + 1]['weather'][0]['main'] == "Clouds" ||
                                data['list'][index + 1]['weather'][0]['main']== "Rain"
                            ? Icons.cloud
                            : Icons.sunny,
                        temp: data['list'][index + 1]['main']['temp'].toString(),
                      );
                    },
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  "Additional Information",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionInfo(
                      label: "humidity",
                      icon: Icons.water_drop,
                      value: humidity.toString(),
                    ),
                    AdditionInfo(
                      label: "wind speed",
                      icon: Icons.air,
                      value: "$windSpeed",
                    ),
                    AdditionInfo(
                      label: "Pressure",
                      icon: Icons.beach_access,
                      value: pressure.toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// class weatherScreen extends StatefulWidget {
//   const weatherScreen({super.key});
//
//   @override
//   State<weatherScreen> createState() => _weatherScreenState();
// }

// class _weatherScreenState extends State<weatherScreen> {
//   double temp =0.0;
//   @override
//   void initState() {
//     super.initState();
//     getWeather();
//   }
//
//  Future getWeather() async{
//     try{
//    final result=await http.get(
//      Uri.parse("http://api.openweathermap.org/data/2.5/forecast?q=London&appid=6e8c97879885e14f307bcb2fc44e9626")
//    );
//    final data= jsonDecode(result.body);
//    print(data);
//    if (data['cod']!= '200'){
//      throw("an unexpected error occur");
//    }
//    setState(() {
//      temp= data['list'][0]['main']['temp'];
//    }
//    );
//
//  }
//     catch(e){
//       throw(e.toString());
//     }
//  }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Center(
//           child: Text(
//             "Weather App",
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 25,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               print("refresh");
//             },
//             icon: Icon(Icons.refresh),
//           ),
//         ],
//       ),
//       body: temp==0 ? Center(child: CircularProgressIndicator())
//           : Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: double.infinity,
//               child: Card(
//                 elevation: 10,
//
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         children: [
//                           Text(
//                             "$temp k",
//                             style: TextStyle(
//                               fontSize: 30,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 16),
//                           Icon(Icons.cloud, color: Colors.white, size: 60),
//                           SizedBox(height: 16),
//                           Text(
//                             "rain",
//                             style: TextStyle(fontSize: 25, color: Colors.white),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 20), // space
//
//             Text(
//               "Weather Forecast",
//               style: TextStyle(
//                 fontSize: 25,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//
//             SizedBox(height: 9),
//
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   hrsForcastDisply(
//                     time:"3.00",
//                     icon:Icons.cloud,
//                     temp:"300f"
//                   ),
//                   hrsForcastDisply(
//                       time:"3.00",
//                       icon:Icons.severe_cold,
//                       temp:"300f"
//                   ),
//                   hrsForcastDisply(
//                       time:"3.00",
//                       icon:Icons.cloud,
//                       temp:"300f"
//                   ),
//                   hrsForcastDisply(
//                       time:"3.00",
//                       icon:Icons.sunny,
//                       temp:"300f"
//                   ),
//                   hrsForcastDisply(
//                       time:"3.00",
//                       icon:Icons.cloud,
//                       temp:"300f"
//                   ),
//                 ],
//               ),
//             ),
//
//             SizedBox(height: 20),
//
//             Text(
//               "Additional Information",
//               style: TextStyle(
//                 fontSize: 25,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//
//             SizedBox(height: 15),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround ,
//               children: [
//                 AdditionInfo(
//                     label: "humidity",
//                     icon: Icons.water_drop,
//                     value:"94"),
//                 AdditionInfo(
//                     label:"wind speed",
//                     icon:Icons.air,
//                     value:"89.0"),
//                 AdditionInfo(
//                   label: "Pressure",
//                   icon: Icons.beach_access,
//                   value: "23.0",),
//               ],
//             ),
//
//
//           ],
//         ),
//       ),
//     );
//   }
// }
