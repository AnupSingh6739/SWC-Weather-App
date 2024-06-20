import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app_2/profile_page.dart';
import 'package:weather_app_2/weather_screen.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});


  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  static const keyLogin="login";
  static const keyName="name";
  static const keyCountry="country";
  static const keyCity="city";
  static const keyCurrentCity="currentCity";
  @override
  void initState() {
    super.initState();
    whereToGo();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration:  const BoxDecoration(
          gradient:  LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,

            colors: [Color(0xFFFF800B),Color(0xFFCE1010),]
          ),
          ),
          child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:  [
            Column(
              children: [
                Text("Weather App",textAlign:TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                     fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void whereToGo() async{
    var prefs=await SharedPreferences.getInstance();
    var isLoggedIn=prefs.getBool("login");
    if(isLoggedIn!=null && isLoggedIn==true){
    Timer(const Duration(milliseconds: 1500),
            ()=>Navigator.pushReplacement(context,
            MaterialPageRoute(builder:
                (context) =>
                     WeatherScreen(
                      city:prefs.getString(keyCity)!,
                      cityName:prefs.getString(keyCurrentCity)!
                    )
            )
        )
    );
    }
    else{
      Timer(const Duration(milliseconds: 1500),
            ()=>Navigator.pushReplacement(context,
            MaterialPageRoute(builder:
                (context) =>
                    const ProfilePage()
            )
        )
    );
    }
  }
}