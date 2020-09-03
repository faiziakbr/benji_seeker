import 'package:benji_seeker/models/PackageModel.dart';

class CreateJobModel {
  String categoryId;
  String taskId = "";
  int estimatedTime;

  double latitude = 0.0;
  double longitude = 0.0;
  String address = "";
  String placeId;

  DateTime jobTime = DateTime.now();
  bool isJobTimeSet = false;
  String isRecurringID = "";
  int recurringDays;
  String recurringText;
  DateTime endTime;
  bool isRecurringSet = false;

  bool createFromCalendar = false;

  String emailDateLabel;

  List<RecurringOptions> setRecurringOptions = List();

  @override
  String toString() {
    return "CatID $categoryId tastId: $taskId estimatedTime $estimatedTime lat $latitude long $longitude address: $address jobTime $jobTime recurrID $isRecurringID endTime $endTime";
  }
}
