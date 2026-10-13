import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/dashboard_service.dart';

void main() {
  group('Dashboard data flow', () {
    test('admin dashboard exposes structured summary data', () {
      final data = DashboardService().getAdminDashboard();

      expect(data.stats.length, 4);
      expect(data.activity.length, 3);
      expect(data.stats.first.title, 'Farmers');
      expect(data.activity.first.title, contains('approval'));
    });

    test('retailer dashboard exposes supplier offers and metrics', () {
      final data = DashboardService().getRetailerDashboard();

      expect(data.metrics.length, 4);
      expect(data.offers.length, 3);
      expect(data.offers.first.crop, 'Tomato');
      expect(data.offers.first.price, '₹32/kg');
    });
  });
}
