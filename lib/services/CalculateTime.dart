import 'package:intl/intl.dart';

class CalculateTime {

  static calculateTime(String dateOfPost, String timeOfPost) {
    DateFormat dateFormat = DateFormat("MMM d, yyyy EEEE, hh:mm:ss:SS aaa");
    DateTime dateTimePost = dateFormat.parse(dateOfPost + " " + timeOfPost);

    var difTime = DateTime.now().difference(dateTimePost).inMinutes;

    if(difTime == 0) return "Vừa xong";

    if((difTime/(60*24*365)) >= 1) 
      {
          if((difTime/(60*24*365) - difTime~/(60*24*365)) > 0.5)
            return ((difTime/(60*24*365)).ceil()).toString() + " năm";
          else
            return ((difTime/(60*24*365)).floor()).toString() + " năm";
      }

    if((difTime/(60*24*30)) >= 1) 
    {
          if((difTime/(60*24*30) - difTime~/(60*24*30)) > 0.5)
            return ((difTime/(60*24*30)).ceil()).toString() + " tháng";
          else
            return ((difTime/(60*24*30)).floor()).toString() + " tháng";
    }

    if((difTime/(60*24)) >= 1) 
    {
          if((difTime/(60*24) - difTime~/(60*24)) > 0.5)
            return ((difTime/(60*24)).ceil()).toString() + " ngày";
          else
            return ((difTime/(60*24)).floor()).toString() + " ngày";
    }
      

    if((difTime/60) >= 1) 
    {
          if((difTime/60 - difTime~/60) > 0.5)
            return ((difTime/60).ceil()).toString() + " giờ";
          else
            return ((difTime/60).floor()).toString() + " giờ";
    }
      

    return difTime.round().toString() + " phút";
  }
}