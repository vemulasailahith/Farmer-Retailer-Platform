class OrderItem {
  final String id;
  final String cropName;
  final double quantityTonnes;
  final String buyerName;
  final String destination;
  final double amountINR;
  final String status; // 'Settled', 'In Transit', 'Pending'
  final String dateString;
  final String? bankAccount;
  final String? vehicleNumber;

  const OrderItem({
    required this.id,
    required this.cropName,
    required this.quantityTonnes,
    required this.buyerName,
    required this.destination,
    required this.amountINR,
    required this.status,
    required this.dateString,
    this.bankAccount,
    this.vehicleNumber,
  });

  static List<OrderItem> get sampleOrders => const [
        OrderItem(
          id: '#FV-8410',
          cropName: 'Green Chillies',
          quantityTonnes: 4.0,
          buyerName: 'BigBasket Wholesale Hub',
          destination: 'Kothapet Wholesale Yard',
          amountINR: 118000,
          status: 'Settled',
          dateString: 'Yesterday, 18:20 IST',
          bankAccount: 'Canara Bank (A/C ...4019)',
          vehicleNumber: 'TS 07 UA 4819',
        ),
        OrderItem(
          id: '#FV-8492',
          cropName: 'Hybrid Tomato (Grade A)',
          quantityTonnes: 12.0,
          buyerName: 'Bowenpally Wholesale Terminal',
          destination: 'Bowenpally Hub 4 (Bay 12)',
          amountINR: 391680,
          status: 'In Transit',
          dateString: 'Today, 06:30 AM',
          bankAccount: 'Direct NEFT Settlement Pending',
          vehicleNumber: 'TS 07 UA 4819',
        ),
        OrderItem(
          id: '#FV-8301',
          cropName: 'Nasik Red Onion',
          quantityTonnes: 5.5,
          buyerName: 'Reliance Fresh Direct FPO',
          destination: 'Gaddiannaram Mandi',
          amountINR: 162500,
          status: 'Settled',
          dateString: '10 Oct 2026, 14:15 IST',
          bankAccount: 'SBI (A/C ...8821)',
          vehicleNumber: 'AP 21 TY 1042',
        ),
        OrderItem(
          id: '#FV-8219',
          cropName: 'Capsicum (Green)',
          quantityTonnes: 2.2,
          buyerName: 'Metro Cash & Carry',
          destination: 'Moosapet Terminal Hub',
          amountINR: 79200,
          status: 'Settled',
          dateString: '05 Oct 2026, 11:30 IST',
          bankAccount: 'Canara Bank (A/C ...4019)',
          vehicleNumber: 'TS 08 AB 9931',
        ),
      ];
}
