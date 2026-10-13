import 'package:flutter/material.dart';
import '../../models/order_model.dart';

class FarmerOrdersScreen extends StatefulWidget {
  final bool isTab;
  const FarmerOrdersScreen({super.key, this.isTab = true});

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'In Transit', 'Settled', 'Pending'];

  List<OrderItem> get _filteredOrders {
    if (_selectedFilter == 'All') return OrderItem.sampleOrders;
    return OrderItem.sampleOrders
        .where((order) => order.status == _selectedFilter)
        .toList();
  }

  void _showInvoiceDialog(OrderItem order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: Color(0xFF1B4332)),
            const SizedBox(width: 8),
            Text('Invoice ${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crop: ${order.cropName}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Quantity: ${order.quantityTonnes} Tonnes'),
            const SizedBox(height: 4),
            Text('Buyer: ${order.buyerName}'),
            const SizedBox(height: 4),
            Text('Total Realization: ₹${order.amountINR.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4332), fontSize: 16)),
            const SizedBox(height: 8),
            Text('Settlement: ${order.bankAccount ?? "Pending"}', style: const TextStyle(color: Colors.grey)),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF40916C), size: 16),
                const SizedBox(width: 6),
                Text('Status: ${order.status}', style: const TextStyle(color: Color(0xFF2D6A4F), fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invoice ${order.id} downloaded successfully.'),
                  backgroundColor: const Color(0xFF1B4332),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4332),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header summary container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B4332).withAlpha(30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL SETTLED REALIZATION',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF52B788).withAlpha(50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, color: Color(0xFF52B788), size: 13),
                          SizedBox(width: 4),
                          Text('Direct NEFT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '₹6,51,380',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Text(
                      '4 Transactions • 23.7 Tonnes Dispatched',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedFilter = filter);
                    },
                    selectedColor: const Color(0xFFD8F3DC),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF1B4332) : const Color(0xFF64748B),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    checkmarkColor: const Color(0xFF1B4332),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF1B4332) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Orders List
          ..._filteredOrders.map((order) {
            final isSettled = order.status == 'Settled';
            final isInTransit = order.status == 'In Transit';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B4332).withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: ID, Crop & Status Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            order.id,
                            style: const TextStyle(
                              color: Color(0xFF1B4332),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${order.quantityTonnes}T ${order.cropName}',
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSettled
                              ? const Color(0xFFE8F5E9)
                              : isInTransit
                                  ? const Color(0xFFE0F2FE)
                                  : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSettled
                                  ? Icons.check_circle
                                  : isInTransit
                                      ? Icons.navigation
                                      : Icons.access_time_filled,
                              size: 13,
                              color: isSettled
                                  ? const Color(0xFF2D6A4F)
                                  : isInTransit
                                      ? const Color(0xFF0284C7)
                                      : const Color(0xFFD97706),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSettled
                                    ? const Color(0xFF2D6A4F)
                                    : isInTransit
                                        ? const Color(0xFF0284C7)
                                        : const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Middle Row: Amount & Buyer/Account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (order.bankAccount != null)
                            Row(
                              children: [
                                const Icon(Icons.account_balance, size: 14, color: Color(0xFF40916C)),
                                const SizedBox(width: 4),
                                Text(
                                  order.bankAccount!,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                ),
                              ],
                            ),
                          const SizedBox(height: 2),
                          Text(
                            'Destination: ${order.destination}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      Text(
                        '₹${order.amountINR.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFF1B4332),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 18, color: Color(0xFFF1F5F2)),

                  // Bottom Row: Date & Action Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.dateString,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                      InkWell(
                        onTap: () => _showInvoiceDialog(order),
                        child: const Row(
                          children: [
                            Text(
                              'Invoice PDF',
                              style: TextStyle(
                                color: Color(0xFF40916C),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.download, size: 14, color: Color(0xFF40916C)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );

    if (widget.isTab) {
      return content;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text('Orders & Settlements'),
        backgroundColor: const Color(0xFF1B4332),
      ),
      body: content,
    );
  }
}
