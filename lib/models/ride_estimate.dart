class RideEstimate {
  final double distanceKm;
  final int durationMinutes;
  final double price;

  const RideEstimate({
    required this.distanceKm,
    required this.durationMinutes,
    required this.price,
  });

  String get distanceLabel => '${distanceKm.toStringAsFixed(1)} km';

  String get durationLabel => '$durationMinutes min';

  String get priceLabel => 'Bs ${price.toStringAsFixed(2)}';
}
