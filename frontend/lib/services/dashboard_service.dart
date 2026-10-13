class DashboardStat {
  final String title;
  final String value;
  final String subtitle;
  final String colorHex;

  const DashboardStat({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.colorHex,
  });
}

class DashboardActivity {
  final String title;
  final String detail;
  final String time;

  const DashboardActivity({
    required this.title,
    required this.detail,
    required this.time,
  });
}

class DashboardMetric {
  final String title;
  final String value;
  final String caption;
  final String colorHex;

  const DashboardMetric({
    required this.title,
    required this.value,
    required this.caption,
    required this.colorHex,
  });
}

class SupplierOffer {
  final String crop;
  final String source;
  final String quantity;
  final String price;
  final String freshness;

  const SupplierOffer({
    required this.crop,
    required this.source,
    required this.quantity,
    required this.price,
    required this.freshness,
  });
}

class AdminDashboardData {
  final List<DashboardStat> stats;
  final List<DashboardActivity> activity;

  const AdminDashboardData({required this.stats, required this.activity});
}

class RetailerDashboardData {
  final List<DashboardMetric> metrics;
  final List<SupplierOffer> offers;

  const RetailerDashboardData({required this.metrics, required this.offers});
}

class DashboardService {
  AdminDashboardData getAdminDashboard() {
    return const AdminDashboardData(
      stats: [
        DashboardStat(
          title: 'Farmers',
          value: '1,284',
          subtitle: '+8.2% this week',
          colorHex: '#2E7D32',
        ),
        DashboardStat(
          title: 'Retailers',
          value: '342',
          subtitle: '+14 new',
          colorHex: '#1976D2',
        ),
        DashboardStat(
          title: 'Markets',
          value: '26',
          subtitle: 'Active nodes',
          colorHex: '#5D4037',
        ),
        DashboardStat(
          title: 'Alerts',
          value: '9',
          subtitle: '4 urgent',
          colorHex: '#E65100',
        ),
      ],
      activity: [
        DashboardActivity(
          title: 'New farmer approval',
          detail: 'Guntur cluster • 12 users waiting',
          time: '12 min ago',
        ),
        DashboardActivity(
          title: 'Price anomaly detected',
          detail: 'Tomato prices up 18% in Vijayawada',
          time: '32 min ago',
        ),
        DashboardActivity(
          title: 'Cold chain check',
          detail: '3 transport routes flagged for review',
          time: '1 hr ago',
        ),
      ],
    );
  }

  RetailerDashboardData getRetailerDashboard() {
    return const RetailerDashboardData(
      metrics: [
        DashboardMetric(
          title: 'Open demand',
          value: '4.8T',
          caption: 'Across 6 categories',
          colorHex: '#1976D2',
        ),
        DashboardMetric(
          title: 'Avg. price',
          value: '₹31/kg',
          caption: 'Based on current offers',
          colorHex: '#2E7D32',
        ),
        DashboardMetric(
          title: 'Fresh stock',
          value: '3.2T',
          caption: 'Ready in next 24h',
          colorHex: '#FB8C00',
        ),
        DashboardMetric(
          title: 'Pending orders',
          value: '14',
          caption: '2 require approval',
          colorHex: '#6D4C41',
        ),
      ],
      offers: [
        SupplierOffer(
          crop: 'Tomato',
          source: 'Guntur farmer cluster',
          quantity: '1,200 kg',
          price: '₹32/kg',
          freshness: '92% fresh',
        ),
        SupplierOffer(
          crop: 'Onion',
          source: 'Kurnool supply pool',
          quantity: '2,300 kg',
          price: '₹28/kg',
          freshness: '88% fresh',
        ),
        SupplierOffer(
          crop: 'Potato',
          source: 'Nandyal market',
          quantity: '900 kg',
          price: '₹30/kg',
          freshness: '94% fresh',
        ),
      ],
    );
  }
}
