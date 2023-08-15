import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gmaptest/models/user_ride_req_info.dart';
import 'package:gmaptest/push_notification/push_notificaton_dialog_box.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global/global.dart';

class PushNotificationSystem
{
  FirebaseMessaging message = FirebaseMessaging.instance;

  Future initialCloudMessaging(BuildContext context) async{


  //1. Terminated
    //when the app is completely closed and opened directly from the push notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage){

      if(remoteMessage != null){


       // display ride request info -- user info who request a ride
        print("####################### Ride Reques Id ###############################");
        print(remoteMessage.data);

        readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context);
      }
    });

    //2. Foreground
    //When app is open and it receive a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage)
    {
      print("####################### Ride Reques Id ###############################");
      print(remoteMessage!.data);
      //display ride request information - user information who request a ride
      readUserRideRequestInformation(remoteMessage!.data["rideRequestId"], context);
    });


    //3. Background
    //When the app is in the background and opened directly from the push notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage)
    {
      print("####################### Ride Reques Id ###############################");
      print(remoteMessage!.data);
      //display ride request information - user information who request a ride
      readUserRideRequestInformation(remoteMessage!.data["rideRequestId"], context);
    });

  }
  readUserRideRequestInformation(String userRideRequestId, BuildContext context){

    FirebaseDatabase.instance.ref()
        .child("All Ride Request")
        .child(userRideRequestId)
        .once()
        .then((snapData)
         {
        if(snapData.snapshot.value != null){

          String originAddress = (snapData.snapshot.value! as Map)["location"];
          String userName = (snapData.snapshot.value! as Map)["name"];
          String userPhone = (snapData.snapshot.value! as Map)["phone"];
          String fuelType = (snapData.snapshot.value! as Map)["fuel_type"];
          String fuelSize = (snapData.snapshot.value! as Map)["fuel_quantity"];
          double originLat = (snapData.snapshot.value! as Map)["originLat"];
          double originLng = (snapData.snapshot.value! as Map)["orginLad"];
          String? rideRequestId = snapData.snapshot.key;


          UserRideRequestInformation userRideRequestdetails = UserRideRequestInformation();
          userRideRequestdetails.originLatLng = LatLng(originLat, originLng);
          userRideRequestdetails.orginAddress = originAddress;
          userRideRequestdetails.userName = userName;
          userRideRequestdetails.userPhone = userPhone;
          userRideRequestdetails.fuelType = fuelType;
          userRideRequestdetails.fuelQuantity = fuelSize;
          userRideRequestdetails.rideRequestId = rideRequestId;

          print("This is the user Fuel Request Details ::::::");
          print(userRideRequestdetails.userName);
          print(userRideRequestdetails.userPhone);
          print(userRideRequestdetails.fuelType);
          print(userRideRequestdetails.fuelQuantity);
          print(userRideRequestdetails.orginAddress);
          print(userRideRequestdetails.originLatLng);
          print(userRideRequestdetails.rideRequestId);

          showDialog(
              context: context,
              builder: (BuildContext context) => NotificationDialogBox(
                  userRideRequestdetails: userRideRequestdetails,
              ),
          );
        }else{
          Fluttertoast.showToast(msg: "This Ride Request Id do not exist");
        }  
    });

  }

  Future generateandGetToken() async{

    String? registationToken = await message.getToken();
    
    print("FCM Registration Token :");
    print(registationToken);
    
    
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("token")
        .set(registationToken);

    message.subscribeToTopic("allDrivers");
    message.subscribeToTopic("allUsers");

  }

}