import 'package:benji_seeker/models/PackageModel.dart';

class CreateJobModel {
  String categoryId;
  String taskId = "";
  int estimatedTime = -1;

  double latitude = 0.0;
  double longitude = 0.0;
  String address = "";
  String placeId;

  DateTime jobTime = DateTime.now();
  String isRecurringID = "";
  String recurringText;
  DateTime endTime;

  String emailDateLabel;

  List<RecurringOptions> setRecurringOptions;
}
