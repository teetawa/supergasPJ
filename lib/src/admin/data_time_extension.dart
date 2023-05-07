class DateTimeExtension  {
  static bool isAfterOrEqual(DateTime other,DateTime date) {
    return date.isAtSameMomentAs(other) || date.isAfter(other);
  }

  static bool isBeforeOrEqual(DateTime other,DateTime date) {
    return date.isAtSameMomentAs(other) || date.isBefore(other);
  }
  
  static bool isBetween(DateTime date,{required DateTime from, required DateTime to}) {
    return isAfterOrEqual(from,date) && isBeforeOrEqual(to,date);
  }
  
  static bool isBetweenExclusive(DateTime date,{required DateTime from, required DateTime to}) {
    return date.isAfter(from) && date.isBefore(to);
  }
}
