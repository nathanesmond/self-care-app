class CalorieLogItem {
  final int idCalorieLog;
  final String namaMakanan;
  final int jumlahCalori;
  final String mealType;
  final String loggedTime;
  final String logDate;

  CalorieLogItem({
    required this.idCalorieLog,
    required this.namaMakanan,
    required this.jumlahCalori,
    required this.mealType,
    required this.loggedTime,
    required this.logDate,
  });

  factory CalorieLogItem.fromJson(Map<String, dynamic> json) {
    return CalorieLogItem(
      idCalorieLog: json['id_calorie_log'] as int,
      namaMakanan: json['nama_makanan'] as String,
      jumlahCalori: json['jumlah_kalori'] as int,
      mealType: json['meal_type'] as String,
      loggedTime: json['logged_time'] as String,
      logDate: json['log_date'] as String,
    );
  }
}
