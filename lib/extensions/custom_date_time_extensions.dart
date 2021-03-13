extension DateTimeExtensions on DateTime {
  DateTime roundDown({Duration delta = const Duration(minutes: 30)}) {
    return DateTime.fromMillisecondsSinceEpoch(this.millisecondsSinceEpoch - this.millisecondsSinceEpoch % delta.inMilliseconds);
  }

  DateTime roundUp({Duration delta = const Duration(minutes: 30)}) {
    return DateTime.fromMillisecondsSinceEpoch(this.millisecondsSinceEpoch - this.millisecondsSinceEpoch % delta.inMilliseconds);
  }
}
