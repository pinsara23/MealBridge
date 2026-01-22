class DashboardStats {
  final int totalDonations;
  final int thisMonthDonations;
  final int activeDonations;
  final int peopleFed;

  DashboardStats({
    required this.totalDonations,
    required this.thisMonthDonations,
    required this.activeDonations,
    required this.peopleFed,
  });

  factory DashboardStats.fromJson(int total, int month, int active) {
    return DashboardStats(
      totalDonations: total,
      thisMonthDonations: month,
      activeDonations: active,
      // Logic: Assuming 1 donation feeds roughly 4 people. Adjust this math as needed!
      peopleFed: total * 4, 
    );
  }
}