import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gmaptest/app_info.dart';
import 'package:gmaptest/assisttant/assistant_methods.dart';
import 'package:gmaptest/authentication/login_screen.dart';
import 'package:gmaptest/fuel_request_page.dart';
import 'package:gmaptest/global/global.dart';
import 'package:gmaptest/push_notification/push_notification_system.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MyMapScreen extends StatefulWidget {
  const MyMapScreen({super.key});

  @override
  State<MyMapScreen> createState() => _MyMapScreenState();
}

class _MyMapScreenState extends State<MyMapScreen> {

  String statusText = "Now Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  GoogleMapController? mapController;

  final LatLng _center = LatLng(45.521563, -122.677433);

  double OrderUIunderMap = 250.0;

  double bottomPaddingOfMap = 0;
  var geolocator = Geolocator();

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    usercurrentposotion = cPosition;

    LatLng latLngPostion =
        LatLng(usercurrentposotion!.latitude, usercurrentposotion!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPostion, zoom: 18);

    mapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoOrdinates(
            usercurrentposotion!, context);

    print("this is your address :" + humanReadableAddress);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      bottomPaddingOfMap = 350;
    });
    locateUserPosition();
  }

  readCurrentDriverInformation() async {


    currentFirebaseUser = fAuth.currentUser;

    await FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((DatabaseEvent snap)
    {
      if(snap.snapshot.value != null)
      {

        onlineDriverData.id = (snap.snapshot.value as Map)["id"];
        onlineDriverData.name = (snap.snapshot.value as Map)["name"];
        onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
        onlineDriverData.email = (snap.snapshot.value as Map)["email"];
        onlineDriverData.car_color = (snap.snapshot.value as Map)["car_details"]["car_color"];
        onlineDriverData.car_model = (snap.snapshot.value as Map)["car_details"]["car_model"];
        onlineDriverData.car_number = (snap.snapshot.value as Map)["car_details"]["car_number"];

        print("########################Car Details :: ########################################");
        print(onlineDriverData.car_color);
        print(onlineDriverData.car_model);
        print(onlineDriverData.car_number);
      }

    });

    currentFirebaseUser = fAuth.currentUser;
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initialCloudMessaging(context);
    pushNotificationSystem.generateandGetToken();

  }



  @override
  void initState() {
    super.initState();
    readCurrentDriverInformation();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _center, zoom: 14.0),
          ),
          statusText != "Now Online"
              ? Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            color: Colors.black87,
          )
              : Container(),

          Positioned(
            top: statusText != "Now Online"
                ? MediaQuery.of(context).size.height * 0.46
                : 25,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: ()
                  {
                    if(isDriverActive != true) //offline
                        {
                      driverIsOnlineNow();
                      updateDriversLocationAtRealTime();

                      setState(() {
                        statusText = "Now Online";
                        isDriverActive = true;
                        buttonColor = Colors.transparent;
                      });

                      //display Toast
                      Fluttertoast.showToast(msg: "you are Online Now");
                    }
                    else //online
                        {
                      driverIsOfflineNow();

                      setState(() {
                        statusText = "Now Offline";
                        isDriverActive = false;
                        buttonColor = Colors.grey;
                      });

                      //display Toast
                      Fluttertoast.showToast(msg: "you are Offline Now");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: buttonColor,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: statusText != "Now Online"
                      ? Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons.phonelink_ring,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),


        ],
      ),
    );
  }
  driverIsOnlineNow() async
  {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    usercurrentposotion = pos; // need  to chage it to usercurrentpostion

    Geofire.initialize("activeDrivers");

    Geofire.setLocation(
        currentFirebaseUser!.uid,
        usercurrentposotion!.latitude,
        usercurrentposotion!.longitude
    );

    DatabaseReference ref = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");

    ref.set("idle"); //searching for ride request
    ref.onValue.listen((event) { });
  }

  updateDriversLocationAtRealTime()
  {
    streamSubscriptionPosition = Geolocator.getPositionStream()
        .listen((Position position)
    {
      usercurrentposotion = position;

      if(isDriverActive == true)
      {
        Geofire.setLocation(
            currentFirebaseUser!.uid,
            usercurrentposotion!.latitude,
            usercurrentposotion!.longitude
        );
      }

      LatLng latLng = LatLng(
        usercurrentposotion!.latitude,
        usercurrentposotion!.longitude,
      );

      mapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  driverIsOfflineNow(){
    Geofire.removeLocation(currentFirebaseUser!.uid);

    DatabaseReference? ref = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");
    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(const Duration(milliseconds: 2000), ()
    {
      //SystemChannels.platform.invokeMethod("SystemNavigator.pop");
      SystemNavigator.pop();
    });
  }
}
