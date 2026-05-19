String minutesToTime(int m) {
  int th = m ~/ 60;
  int tm = m % 60;

  String time = "${th > 9 ? th.toString() : "0$th"}:${tm > 9 ? tm.toString() : "0$tm"}";
  return time;
}