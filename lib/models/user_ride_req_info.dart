import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideRequestInformation{

 LatLng? originLatLng;
 String? orginAddress;
 String? rideRequestId;
 String? userName;
 String? fuelQuantity;
 String? fuelType;
 String? userPhone;

 UserRideRequestInformation({
   this.fuelQuantity,
   this.fuelType,
   this.orginAddress,
   this.originLatLng,
   this.rideRequestId,
   this.userName,
   this.userPhone,

});
}