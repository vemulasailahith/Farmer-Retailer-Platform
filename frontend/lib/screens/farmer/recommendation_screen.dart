import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/recommendation_model.dart';
import '../../services/recommendation_repository.dart';
import '../../widgets/language_selector.dart';

/// Low-literacy, farmer-friendly recommendation screen.
/// Displays optimal market selection, expected revenue, supply summary,
/// side-by-side market comparison, logistics route, freshness & spoilage,
/// pricing details, and buyer capacity in a green-and-white visual theme.
class RecommendationScreen extends StatefulWidget {
  final RecommendationResponse? recommendationData;
  final RecommendationRepository? repository;

  const RecommendationScreen({
    super.key,
    this.recommendationData,
    this.repository,
  });

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  late final RecommendationRepository _repository;
  RecommendationResponse? _data;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? const MockRecommendationRepository();

    if (widget.recommendationData != null) {
      _data = widget.recommendationData;
    } else {
      _fetchRecommendation();
    }
  }

  Future<void> _fetchRecommendation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _repository.getRecommendation();
      if (!mounted) return;
      setState(() {
        _data = response;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 1,
        title: Text(
          l10n.farmToMarketRecommendation,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: const [
          LanguageSelector(),
          SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.analyzingFarmDetails,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchRecommendation,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.tryAgain),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(context, l10n, theme),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    final data = _data ?? RecommendationResponse.mockSample;
    final recommended = data.recommendedMarket;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: SinglefulScrollWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Banner
              _buildHeaderBanner(l10n),
              const SizedBox(height: 14),

              // 2. Analysis Status (Compact Card)
              _buildAnalysisStatusCard(l10n),
              const SizedBox(height: 14),

              // 3. Recommended Market Card (Most Prominent)
              _buildRecommendedMarketCard(l10n, recommended),
              const SizedBox(height: 14),

              // 4. Supply Summary Card
              _buildSupplySummaryCard(l10n, data.supply),
              const SizedBox(height: 14),

              // 5. Market Comparison Cards
              _buildMarketComparisonSection(l10n, data.markets),
              const SizedBox(height: 14),

              // 6. Why this recommendation?
              _buildWhyRecommendationCard(l10n, data.recommendation.reason),
              const SizedBox(height: 14),

              // 7. Transport Route Card
              _buildTransportCard(l10n, recommended),
              const SizedBox(height: 14),

              // 8. Freshness & Spoilage Card
              _buildFreshnessSpoilageCard(l10n, data.freshness, recommended.spoilage),
              const SizedBox(height: 14),

              // 9. Price Details Card
              _buildPriceCard(l10n, recommended.price),
              const SizedBox(height: 14),

              // 10. Demand & Buyer Capacity Card
              _buildDemandCapacityCard(l10n, recommended.demand, recommended.buyerName),
              const SizedBox(height: 20),

              // 11. Action Buttons
              _buildActionButtons(l10n),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Header Banner
  Widget _buildHeaderBanner(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.farmToMarketRecommendation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.recommendedSellingOption,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Compact Analysis Status Card
  Widget _buildAnalysisStatusCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.analyzingFarmDetails,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B5E20),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  l10n.analysisComplete,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Recommended Market Card (Most Prominent)
  Widget _buildRecommendedMarketCard(AppLocalizations l10n, MarketOptionData market) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E7D32), width: 2.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trophy Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
                child: const Text('🏆', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.recommendedMarketTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    Text(
                      market.market,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF81C784)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, size: 16, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 4),
                    Text(
                      market.buyerName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Two Prominent Metric Cards (Expected Price & Expected Net Revenue)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 420;
              final priceTile = _buildProminentMetric(
                label: l10n.expectedPrice,
                value: '₹${market.price.predictedPricePerKg.toStringAsFixed(2)}',
                unit: '/ ${l10n.kg}',
                icon: Icons.currency_rupee,
                accentColor: const Color(0xFF2E7D32),
              );
              final revenueTile = _buildProminentMetric(
                label: l10n.expectedNetRevenue,
                value: '₹${_formatThousands(market.decision.netRevenue)}',
                icon: Icons.account_balance_wallet_outlined,
                accentColor: const Color(0xFF1B5E20),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: priceTile),
                    const SizedBox(width: 12),
                    Expanded(child: revenueTile),
                  ],
                );
              } else {
                return Column(
                  children: [
                    priceTile,
                    const SizedBox(height: 10),
                    revenueTile,
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProminentMetric({
    required String label,
    required String value,
    String? unit,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    if (unit != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Supply Summary Card
  Widget _buildSupplySummaryCard(AppLocalizations l10n, SupplyData supply) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌾', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                l10n.expectedSupply,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Supply Numbers Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBE7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCE775)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatThousands(supply.expectedSupplyKg.round())} ${l10n.kg}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${supply.expectedSupplyTonnes.toStringAsFixed(2)} ${l10n.tonnes}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.scale, color: Color(0xFF2E7D32), size: 24),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Crop & Area details
          Row(
            children: [
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.cropLabel,
                  value: supply.commodity,
                  icon: Icons.eco_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.farmAreaLabel,
                  value: '${supply.farmAreaHa.toStringAsFixed(0)} ha',
                  icon: Icons.aspect_ratio,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Market Comparison Section
  Widget _buildMarketComparisonSection(AppLocalizations l10n, List<MarketOptionData> markets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.compare_arrows, color: Color(0xFF2E7D32), size: 22),
              const SizedBox(width: 8),
              Text(
                l10n.marketComparisonTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 640;
            final cards = markets.map((m) => _buildMarketComparisonCard(l10n, m)).toList();

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[1]),
                ],
              );
            } else {
              return Column(
                children: [
                  cards[0],
                  const SizedBox(height: 12),
                  cards[1],
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildMarketComparisonCard(AppLocalizations l10n, MarketOptionData m) {
    final isRecommended = m.decision.isRecommended;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended ? const Color(0xFF2E7D32) : Colors.grey.shade300,
          width: isRecommended ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isRecommended
                ? const Color(0xFF2E7D32).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Market name + Buyer badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  m.market,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isRecommended ? const Color(0xFF1B5E20) : Colors.black87,
                  ),
                ),
              ),
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF81C784)),
                  ),
                  child: const Text(
                    '★ Top Pick',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.person_outline, size: 15, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                m.buyerName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Comparison Key Values
          _buildComparisonRow(
            label: l10n.expectedPrice,
            value: '₹${m.price.predictedPricePerKg.toStringAsFixed(2)} / ${l10n.kg}',
            isBold: true,
          ),
          _buildComparisonRow(
            label: l10n.saleableQuantity,
            value: '${_formatThousands(m.decision.sellableQuantityKg)} ${l10n.kg}',
          ),
          _buildComparisonRow(
            label: l10n.transportCost,
            value: '₹${_formatThousands(m.decision.transportCost)}',
          ),
          _buildComparisonRow(
            label: l10n.expectedNetRevenue,
            value: '₹${_formatThousands(m.decision.netRevenue)}',
            isHighlighted: true,
          ),
          _buildComparisonRow(
            label: l10n.spoilageLabel,
            value: '${m.spoilage.spoilagePercentage.toStringAsFixed(2)}%',
          ),
          _buildComparisonRow(
            label: l10n.demandStatusLabel,
            value: _formatDemandStatus(l10n, m.demand.demandLevel),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow({
    required String label,
    required String value,
    bool isBold = false,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 13 : 12,
              fontWeight: isHighlighted || isBold ? FontWeight.bold : FontWeight.w600,
              color: isHighlighted ? const Color(0xFF1B5E20) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // 6. Why this recommendation? Card
  Widget _buildWhyRecommendationCard(AppLocalizations l10n, String reason) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.whyThisRecommendationTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  reason.isNotEmpty ? reason : l10n.recommendationReasonDefault,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 7. Transport Card (Recommended market route)
  Widget _buildTransportCard(AppLocalizations l10n, MarketOptionData market) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, color: Color(0xFF2E7D32), size: 22),
              const SizedBox(width: 10),
              Text(
                l10n.transportRouteTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Visual Route Diagram
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBE7).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Origin
                Column(
                  children: [
                    const Text('📍', style: TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(
                      l10n.farmOrigin,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // Arrow with Distance
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🚚', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              '${market.route.distanceKm.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(height: 2, color: const Color(0xFF2E7D32)),
                      ],
                    ),
                  ),
                ),
                // Destination
                Column(
                  children: [
                    const Text('🏪', style: TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(
                      market.market,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Travel Time and Transport Cost
          Row(
            children: [
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.travelTimeLabel,
                  value: '~${market.route.travelTimeHours.toStringAsFixed(1)} hrs',
                  icon: Icons.schedule_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.transportCost,
                  value: '₹${_formatThousands(market.transport.transportCost)}',
                  icon: Icons.payments_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 8. Freshness / Spoilage Card
  Widget _buildFreshnessSpoilageCard(
    AppLocalizations l10n,
    FreshnessData freshness,
    SpoilageData spoilage,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, color: Color(0xFF2E7D32), size: 22),
              const SizedBox(width: 10),
              Text(
                l10n.freshnessSpoilageTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Visual Indicator Tiles (Freshness vs Rotten)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            l10n.freshnessLabel,
                            style: TextStyle(fontSize: 12, color: Colors.green.shade900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(freshness.freshProbability * 100).toStringAsFixed(2)}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_outlined, color: Colors.red.shade700, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            l10n.rottenLabel,
                            style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(freshness.rottenProbability * 100).toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Spoilage risk & quantities
          Row(
            children: [
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.spoilageRisk,
                  value: '${spoilage.spoilagePercentage.toStringAsFixed(2)}%',
                  icon: Icons.shield_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.riskLevel,
                  value: l10n.lowRisk,
                  icon: Icons.verified_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.saleableQuantity,
                  value: '${_formatThousands(spoilage.saleableQuantityKg)} ${l10n.kg}',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.spoiledQuantity,
                  value: '${_formatThousands(spoilage.spoiledQuantityKg)} ${l10n.kg}',
                  icon: Icons.remove_circle_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 9. Price Card
  Widget _buildPriceCard(AppLocalizations l10n, PriceData price) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.price_change_outlined, color: Color(0xFF2E7D32), size: 22),
              const SizedBox(width: 10),
              Text(
                l10n.priceDetailsTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Per-kg Price Tiles
          Row(
            children: [
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.currentMarketPrice,
                  value: '₹${(price.currentModalPrice / 100).toStringAsFixed(2)}/${l10n.kg}',
                  icon: Icons.storefront_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.predictedFuturePrice,
                  value: '₹${price.predictedPricePerKg.toStringAsFixed(2)}/${l10n.kg}',
                  icon: Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Modal Price (quintal)
          Row(
            children: [
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.currentModalPrice,
                  value: '₹${_formatThousands(price.currentModalPrice)}/${l10n.perQuintal}',
                  icon: Icons.receipt_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.predictedFutureModalPrice,
                  value: '₹${_formatThousands(price.predictedFutureModalPrice)}/${l10n.perQuintal}',
                  icon: Icons.assessment_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 10. Demand / Buyer Capacity Card
  Widget _buildDemandCapacityCard(AppLocalizations l10n, DemandData demand, String buyerName) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_outlined, color: Color(0xFF2E7D32), size: 22),
              const SizedBox(width: 10),
              Text(
                l10n.demandBuyerCapacityTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Buyer & Demand
          Row(
            children: [
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.buyerLabel,
                  value: buyerName,
                  icon: Icons.badge_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.demandLabel,
                  value: '${_formatThousands(demand.demandKg)} ${l10n.kg}',
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Buyer Capacity & Available Capacity
          Row(
            children: [
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.buyerCapacity,
                  value: '${_formatThousands(demand.buyerCapacityKg)} ${l10n.kg}',
                  icon: Icons.warehouse_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.availableCapacity,
                  value: '${_formatThousands(demand.availableCapacityKg)} ${l10n.kg}',
                  icon: Icons.check_box_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Demand Coverage & Status
          Row(
            children: [
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.demandCoverage,
                  value: '${(demand.demandCoverage * 100).toStringAsFixed(2)}%',
                  icon: Icons.pie_chart_outline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSimpleInfoTile(
                  label: l10n.capacityStatus,
                  value: l10n.capacityAvailable,
                  icon: Icons.done_all,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 11. Action Buttons
  Widget _buildActionButtons(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // View Market Details Button
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.marketDetailsNote),
                backgroundColor: const Color(0xFF2E7D32),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.info_outline),
          label: Text(
            l10n.viewMarketDetails,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1B5E20),
            side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 12),

        // Start New Recommendation Button
        ElevatedButton.icon(
          onPressed: () {
            // Navigate back to the Farmer Input flow
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.replay),
          label: Text(
            l10n.startNewRecommendation,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
          ),
        ),
      ],
    );
  }

  // Helper tile widget for clean information display
  Widget _buildSimpleInfoTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBE7).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDemandStatus(AppLocalizations l10n, String status) {
    if (status.toLowerCase().contains('low')) {
      return l10n.lowDemand;
    } else if (status.toLowerCase().contains('high')) {
      return l10n.highDemand;
    }
    return l10n.mediumDemand;
  }

  String _formatThousands(num value) {
    final isInt = value is int || value == value.toInt();
    final stringVal = isInt
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    final parts = stringVal.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    final regex = RegExp(r'\B(?=(\d{3})+(?!\d))');
    final formattedInt = integerPart.replaceAll(regex, ',');
    return '$formattedInt$decimalPart';
  }
}

/// Helper wrapper for comfortable single scroll with padding
class SinglefulScrollWrapper extends StatelessWidget {
  final Widget child;

  const SinglefulScrollWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: child,
    );
  }
}
