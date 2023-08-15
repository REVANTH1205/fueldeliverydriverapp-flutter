import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gmaptest/assisttant/assistant_methods.dart';
import 'package:gmaptest/global/global.dart';
import 'package:gmaptest/models/user_ride_req_info.dart';
import 'package:gmaptest/trip_screen/check.dart';
import 'package:gmaptest/trip_screen/new_trip_screen.dart';

class NotificationDialogBox extends StatefulWidget {
   UserRideRequestInformation? userRideRequestdetails;

   NotificationDialogBox({this.userRideRequestdetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[800],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 14,),

            Image.asset(
              "images/car_logo.png",
              width: 160,
            ),

            const SizedBox(height: 10,),

            //title
            const Text(
              "New Fuel Request",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.grey
              ),
            ),

            const SizedBox(height: 14.0),

            const Divider(
              height: 3,
              thickness: 3,
            ),

            //addresses origin destination
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  //origin location with icon
                  Row(
                    children: [
                      Image.asset(
                        "images/origin.png",
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 14,),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userRideRequestdetails!.orginAddress!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20.0),

                  // fuel Type  with icon
                  Row(
                    children: [
                      Image.asset(
                        "images/origin.png", // cahnge  to fuel type logo
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 14,),
                      Expanded(
                        child: Container(
                          child: Text(
                            "Fuel Type :  " + widget.userRideRequestdetails!
                                .fuelType!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      Image.asset(
                        "images/origin.png", // change to fuel quan logo
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 14,),
                      Expanded(
                        child: Container(
                          child: Text(
                            "Fuel Quantity : " + widget.userRideRequestdetails!
                                .fuelQuantity!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),


            const Divider(
              height: 3,
              thickness: 3,
            ),

            //buttons cancel accept
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    onPressed: () {
                      //cancel the rideRequest

                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),

                  const SizedBox(width: 25.0),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                    onPressed: () {
                      //accept the rideRequest
                      Navigator.push(context, MaterialPageRoute(builder: (c) =>
                          NewTripScreen(
                            userRideRequestdetails: widget.userRideRequestdetails,)));
                          acceptRideRequest(context);
                    },
                    child: Text(
                      "Accept".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  acceptRideRequest(BuildContext context) {


String getRideRequestId = "";

     FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap)  {
      if(snap.snapshot.value != null)
      {
        getRideRequestId = snap.snapshot.value.toString();
        print("This is the RideRequest ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::");
        print(getRideRequestId);
      }
      else
      {
        Fluttertoast.showToast(msg: "This ride request do not exists.");
      }
      print("This is the RideRequest ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::");
      print(getRideRequestId);
      if(getRideRequestId == widget.userRideRequestdetails!.rideRequestId)
      {
         FirebaseDatabase.instance.ref()
            .child("drivers")
            .child(currentFirebaseUser!.uid)
            .child("newRideStatus")
            .set("accepted");


         AssistantMethods.pauseLiveLocationUpdates();

         Navigator.push(context, MaterialPageRoute(builder: (c)=> NewTripScreen(
          userRideRequestdetails: widget.userRideRequestdetails,
        )
        ));
      }
      else
      {
        Fluttertoast.showToast(msg: "This Ride Request do not exists.");
      }


    });

  }
}

