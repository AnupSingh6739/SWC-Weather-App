import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app_2/splash_screen.dart';
import 'package:weather_app_2/weather_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  dynamic prefs;
  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    countryController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 8, 8),
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(
                  Icons.account_circle_outlined,
                  color: Colors.yellow,
                ),
                TextField(
                  decoration: const InputDecoration(
                    label: Text("Name"),
                  ),
                  controller: nameController,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  decoration: const InputDecoration(
                    label: Text("Country"),
                  ),
                  controller: countryController,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  decoration: const InputDecoration(
                    label: Text("City"),
                  ),
                  controller: cityController,
            
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () {
                    prefs.setBool(SplashScreenState.keyLogin,true);
                    prefs.setString("name", nameController.text.toString());
                    prefs.setString("country", countryController.text.toString());
                    String city=cityController.text.toString().trim().toLowerCase();
                    String cityName=city[0].toUpperCase()+city.substring(1);
                    prefs.setString("city", city);
                    prefs.setString("currentCity", cityName);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> WeatherScreen(city: city,cityName: cityName,)));
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void getPrefs() async{
    prefs= await SharedPreferences.getInstance();
  }
}
