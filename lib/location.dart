import 'package:geolocator/geolocator.dart';

class Location{
  double latitude;
  double longtude;

  Future<void> getCurrentLocation()async{
    try{

      Position position= await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high,);
      latitude= position.latitude;
      longtude= position.longitude;
    }catch(e){
      print(e);
    }
  }
}
