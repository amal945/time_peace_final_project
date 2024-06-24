class TrackerDetails {
  final String title;
  final String datetime;

  TrackerDetails({required this.title, required this.datetime});
}

class TrackerData {
  final String title;
  final String date;
  final List<TrackerDetails> trackerDetails;

  TrackerData({required this.title, required this.date, required this.trackerDetails});
}
