import "dart:convert";
import "dart:ui";
import "package:intl/intl.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:weather_app_2/hourly_forecast_item.dart";
import "package:weather_app_2/profile_page.dart";
import "package:weather_app_2/secrets.dart";
import "package:flutter/material.dart";

import 'package:weather_app_2/additional_info_item.dart';
import 'package:http/http.dart' as http;
import "package:weather_app_2/splash_screen.dart";

class WeatherScreen extends StatefulWidget {
  WeatherScreen({super.key, this.city="london", this.cityName="London"});
  String city;
  String cityName;
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  final _cityController = TextEditingController();
  Future<Map<String, dynamic>> getCurrentWeather(
      ) async {
    try {
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=${widget.city}&APPID=$openWeatherApiKey'),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'An unexpected error occured';
      }
      //(data['list'][0]['main']['temp'];
      return data;
    } catch (e) {
      throw "Unable to fetch weather";
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _cityController,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                var prefs=await SharedPreferences.getInstance();
                setState(() {
                  if(_cityController.text.isNotEmpty){
                  String currentCity = _cityController.text.toString().trim().toLowerCase();
                  widget.city=currentCity;
                  widget.cityName=currentCity[0].toUpperCase()+currentCity.substring(1);
                  prefs.setString(SplashScreenState.keyCurrentCity,widget.cityName);
                  _cityController.text="";
                  weather = getCurrentWeather();
                  }
                });
              },
              icon: const Icon(Icons.search)),
        ],
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
),
      drawer: Drawer(
        child: ElevatedButton(onPressed: () async{
          
          var prefs=await SharedPreferences.getInstance();
          prefs.setBool(SplashScreenState.keyLogin, false);
          if(!mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const ProfilePage()));
        }, child: const Text("Logout")),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left:30.0,right: 10.0),
              child: Row(
                children: [
                    Text(
                      widget.cityName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          weather = getCurrentWeather();
                        });
                      },
                      icon: const Icon(Icons.refresh)),
                ],
              ),
            ),
            FutureBuilder(
              future: weather,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                final data = snapshot.data!;

                final currentWeatherData = data['list'][0];

                final currentTemp = currentWeatherData['main']['temp'];
                final currentSky = currentWeatherData['weather'][0]['main'];
                final currentPressure = currentWeatherData['main']['pressure'];
                final currentWindSpeed = currentWeatherData['wind']['speed'];
                final currentHumidity = currentWeatherData['main']['humidity'];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //main card
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        "$currentTemp K",
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Icon(
                                        currentSky == 'Clouds' ||
                                                currentSky == 'Rain'
                                            ? Icons.cloud
                                            : Icons.sunny,
                                        size: 64,
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        currentSky,
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //weather forecast cards

                      const Text(
                        'Hourly Forecast',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      // SingleChildScrollView(
                      //   scrollDirection: Axis.horizontal,
                      //   child: Row(
                      //     children: [
                      //         for(int i=0;i<5;i++)
                      //         HourlyForecastItem(
                      //           time:data['list'][i+1]['dt'].toString(),
                      //           temperature: data['list'][i+1]['main']['temp'].toString(),
                      //           icon: data['list'][i+1]['weather'][0]['main']=='Clouds' || data['list'][i+1]['weather'][0]['main']=='Rain' ? Icons.cloud:Icons.sunny,
                      //         ),
                      //     ],
                      //   ),
                      // ),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            final hourlyForecast = data['list'][index + 1];
                            final time =
                                DateTime.parse(hourlyForecast['dt_txt']);
                            return HourlyForecastItem(
                                time: DateFormat.j().format(time),
                                temperature:
                                    hourlyForecast['main']['temp'].toString(),
                                icon: hourlyForecast['weather'][0]['main'] ==
                                            'Clouds' ||
                                        hourlyForecast['weather'][0]['main'] ==
                                            'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //addn info cards
                      const Text(
                        'Additional Information',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          AdditionalInfoItem(
                            icon: Icons.water_drop,
                            label: 'Humidity',
                            value: currentHumidity.toString(),
                          ),
                          AdditionalInfoItem(
                            icon: Icons.air,
                            label: 'Wind Speed',
                            value: currentWindSpeed.toString(),
                          ),
                          AdditionalInfoItem(
                            icon: Icons.beach_access,
                            label: 'Pressure',
                            value: currentPressure.toString(),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  

}
