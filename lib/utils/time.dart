import 'package:intl/intl.dart';


final dateFormat = DateFormat("d.M. hh:mm");
final timeFormat = DateFormat("HH:mm");

String humanizePastDateTIme(DateTime dateTime, {String pre = "Published"}) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Just $pre';
  } else if (difference.inMinutes < 60) {
    return '$pre ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
  } else if (difference.inHours < 24) {
    return '$pre ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
  } else if (difference.inDays < 7) {
    return '$pre ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$pre $weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$pre $months ${months == 1 ? 'month' : 'months'} ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$pre $years ${years == 1 ? 'year' : 'years'} ago';
  }
}

String humanizeUpcomingDate(DateTime dateTime) {
  final now = DateTime.now();
  final difference = dateTime.difference(now);

  if (difference.inDays == 0) {
    return 'Today';
  }

  if (difference.inDays == 1) {
    return 'Tomorrow';
  }

  if (difference.inDays > 1 && difference.inDays <= 7) {
    final weekday = DateFormat('EEEE').format(dateTime);
    return 'Next $weekday';
  }

  if (difference.inDays > 7 && dateTime.year == now.year) {
    return DateFormat('d MMM').format(dateTime);
  }

  return DateFormat('d MMM yyyy').format(dateTime);
}