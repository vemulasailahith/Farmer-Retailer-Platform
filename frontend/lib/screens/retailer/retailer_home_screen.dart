import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';

class RetailerHomeScreen extends StatelessWidget {
  const RetailerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final dashboard = DashboardService().getRetailerDashboard();

    final offerTiles = dashboard.offers
        .map(
          (offer) => _OfferTile(
            crop: offer.crop,
            source: offer.source,
            quantity: offer.quantity,
            price: offer.price,
            freshness: offer.freshness,
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Retailer Dashboard'),
        backgroundColor: const Color(0xFF1976D2),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Procurement overview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: dashboard.metrics[0].title,
                      value: dashboard.metrics[0].value,
                      caption: dashboard.metrics[0].caption,
                      color: Color(
                        int.parse(
                          dashboard.metrics[0].colorHex.replaceFirst(
                            '#',
                            '0xFF',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      title: dashboard.metrics[1].title,
                      value: dashboard.metrics[1].value,
                      caption: dashboard.metrics[1].caption,
                      color: Color(
                        int.parse(
                          dashboard.metrics[1].colorHex.replaceFirst(
                            '#',
                            '0xFF',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: dashboard.metrics[2].title,
                      value: dashboard.metrics[2].value,
                      caption: dashboard.metrics[2].caption,
                      color: Color(
                        int.parse(
                          dashboard.metrics[2].colorHex.replaceFirst(
                            '#',
                            '0xFF',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      title: dashboard.metrics[3].title,
                      value: dashboard.metrics[3].value,
                      caption: dashboard.metrics[3].caption,
                      color: Color(
                        int.parse(
                          dashboard.metrics[3].colorHex.replaceFirst(
                            '#',
                            '0xFF',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Current supplier offers',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...offerTiles.map((tile) => tile),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    await authService.signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String caption;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(caption, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  final String crop;
  final String source;
  final String quantity;
  final String price;
  final String freshness;

  const _OfferTile({
    required this.crop,
    required this.source,
    required this.quantity,
    required this.price,
    required this.freshness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF1976D2).withValues(alpha: 0.1),
            child: const Icon(Icons.local_florist, color: Color(0xFF1976D2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      crop,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      price,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  source,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      quantity,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      freshness,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('View')),
        ],
      ),
    );
  }
}
