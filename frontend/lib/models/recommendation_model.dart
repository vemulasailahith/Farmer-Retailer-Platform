/// Structured models representing the Farm-to-Market Recommendation API response.
/// Compatible with FastAPI Modules 1-8 output schema.
library;

class SupplyData {
  final String commodity;
  final String state;
  final String district;
  final double farmAreaHa;
  final double predictedYieldKgPerHa;
  final double expectedSupplyKg;
  final double expectedSupplyTonnes;

  const SupplyData({
    required this.commodity,
    required this.state,
    required this.district,
    required this.farmAreaHa,
    required this.predictedYieldKgPerHa,
    required this.expectedSupplyKg,
    required this.expectedSupplyTonnes,
  });

  factory SupplyData.fromJson(Map<String, dynamic> json) {
    return SupplyData(
      commodity: json['commodity']?.toString() ?? json['crop']?.toString() ?? 'Rice',
      state: json['state']?.toString() ?? json['state_name']?.toString() ?? '',
      district: json['district']?.toString() ?? json['dist_name']?.toString() ?? '',
      farmAreaHa: _toDouble(json['farm_area_ha'] ?? json['area_ha']) ?? 0.0,
      predictedYieldKgPerHa: _toDouble(json['predicted_yield_kg_per_ha'] ?? json['predicted_yield']) ?? 0.0,
      expectedSupplyKg: _toDouble(json['expected_supply_kg'] ?? json['supply_kg']) ?? 0.0,
      expectedSupplyTonnes: _toDouble(json['expected_supply_tonnes'] ?? json['supply_tonnes']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'commodity': commodity,
    'state': state,
    'district': district,
    'farm_area_ha': farmAreaHa,
    'predicted_yield_kg_per_ha': predictedYieldKgPerHa,
    'expected_supply_kg': expectedSupplyKg,
    'expected_supply_tonnes': expectedSupplyTonnes,
  };
}

class FreshnessData {
  final double freshProbability;
  final double rottenProbability;
  final double confidence;

  const FreshnessData({
    required this.freshProbability,
    required this.rottenProbability,
    required this.confidence,
  });

  factory FreshnessData.fromJson(Map<String, dynamic> json) {
    return FreshnessData(
      freshProbability: _toDouble(json['fresh_probability'] ?? json['fresh']) ?? 1.0,
      rottenProbability: _toDouble(json['rotten_probability'] ?? json['rotten']) ?? 0.0,
      confidence: _toDouble(json['confidence']) ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'fresh_probability': freshProbability,
    'rotten_probability': rottenProbability,
    'confidence': confidence,
  };
}

class RoutingData {
  final double distanceKm;
  final double travelTimeHours;

  const RoutingData({
    required this.distanceKm,
    required this.travelTimeHours,
  });

  factory RoutingData.fromJson(Map<String, dynamic> json) {
    return RoutingData(
      distanceKm: _toDouble(json['distance_km'] ?? json['distance']) ?? 0.0,
      travelTimeHours: _toDouble(json['travel_time_hours'] ?? json['duration_hours']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'distance_km': distanceKm,
    'travel_time_hours': travelTimeHours,
  };
}

class TransportData {
  final double transportCost;

  const TransportData({
    required this.transportCost,
  });

  factory TransportData.fromJson(Map<String, dynamic> json) {
    return TransportData(
      transportCost: _toDouble(json['transport_cost'] ?? json['cost']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'transport_cost': transportCost,
  };
}

class SpoilageData {
  final double spoilagePercentage;
  final double saleableQuantityKg;
  final double spoiledQuantityKg;
  final String riskLevel;

  const SpoilageData({
    required this.spoilagePercentage,
    required this.saleableQuantityKg,
    this.spoiledQuantityKg = 0.0,
    this.riskLevel = 'LOW',
  });

  factory SpoilageData.fromJson(Map<String, dynamic> json) {
    final pct = _toDouble(json['spoilage_percentage'] ?? json['spoilage_pct']) ?? 0.0;
    return SpoilageData(
      spoilagePercentage: pct,
      saleableQuantityKg: _toDouble(json['saleable_quantity'] ?? json['saleable_quantity_kg']) ?? 0.0,
      spoiledQuantityKg: _toDouble(json['spoiled_quantity_kg']) ?? 0.0,
      riskLevel: json['risk_level']?.toString() ?? (pct < 20 ? 'LOW' : 'MEDIUM'),
    );
  }

  Map<String, dynamic> toJson() => {
    'spoilage_percentage': spoilagePercentage,
    'saleable_quantity_kg': saleableQuantityKg,
    'spoiled_quantity_kg': spoiledQuantityKg,
    'risk_level': riskLevel,
  };
}

class PriceData {
  final double currentModalPrice;
  final double predictedFutureModalPrice;
  final double predictedPricePerKg;
  final String priceUnit;

  const PriceData({
    required this.currentModalPrice,
    required this.predictedFutureModalPrice,
    required this.predictedPricePerKg,
    this.priceUnit = 'INR/kg',
  });

  factory PriceData.fromJson(Map<String, dynamic> json) {
    return PriceData(
      currentModalPrice: _toDouble(json['current_modal_price']) ?? 0.0,
      predictedFutureModalPrice: _toDouble(json['predicted_future_modal_price']) ?? 0.0,
      predictedPricePerKg: _toDouble(json['predicted_price_per_kg']) ?? 0.0,
      priceUnit: json['price_unit']?.toString() ?? 'INR/kg',
    );
  }

  Map<String, dynamic> toJson() => {
    'current_modal_price': currentModalPrice,
    'predicted_future_modal_price': predictedFutureModalPrice,
    'predicted_price_per_kg': predictedPricePerKg,
    'price_unit': priceUnit,
  };
}

class DemandData {
  final double demandKg;
  final double availableCapacityKg;
  final double buyerCapacityKg;
  final double demandCoverage;
  final String demandLevel;
  final String capacityStatus;

  const DemandData({
    required this.demandKg,
    required this.availableCapacityKg,
    this.buyerCapacityKg = 30000.0,
    required this.demandCoverage,
    required this.demandLevel,
    this.capacityStatus = 'Available',
  });

  factory DemandData.fromJson(Map<String, dynamic> json) {
    return DemandData(
      demandKg: _toDouble(json['demand'] ?? json['demand_kg']) ?? 0.0,
      availableCapacityKg: _toDouble(json['available_capacity'] ?? json['available_capacity_kg']) ?? 0.0,
      buyerCapacityKg: _toDouble(json['buyer_capacity'] ?? json['buyer_capacity_kg']) ?? 30000.0,
      demandCoverage: _toDouble(json['demand_coverage']) ?? 0.0,
      demandLevel: json['demand_level']?.toString() ?? 'low_demand',
      capacityStatus: json['capacity_status']?.toString() ?? 'Available',
    );
  }

  Map<String, dynamic> toJson() => {
    'demand_kg': demandKg,
    'available_capacity_kg': availableCapacityKg,
    'buyer_capacity_kg': buyerCapacityKg,
    'demand_coverage': demandCoverage,
    'demand_level': demandLevel,
    'capacity_status': capacityStatus,
  };
}

class DecisionData {
  final double sellableQuantityKg;
  final double grossRevenue;
  final double transportCost;
  final double netRevenue;
  final bool feasible;
  final bool isRecommended;

  const DecisionData({
    required this.sellableQuantityKg,
    required this.grossRevenue,
    required this.transportCost,
    required this.netRevenue,
    required this.feasible,
    this.isRecommended = false,
  });

  factory DecisionData.fromJson(Map<String, dynamic> json) {
    return DecisionData(
      sellableQuantityKg: _toDouble(json['sellable_quantity'] ?? json['sellable_quantity_kg']) ?? 0.0,
      grossRevenue: _toDouble(json['gross_revenue']) ?? 0.0,
      transportCost: _toDouble(json['transport_cost']) ?? 0.0,
      netRevenue: _toDouble(json['net_revenue']) ?? 0.0,
      feasible: json['feasible'] == true || json['feasible']?.toString().toLowerCase() == 'true',
      isRecommended: json['is_recommended'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'sellable_quantity_kg': sellableQuantityKg,
    'gross_revenue': grossRevenue,
    'transport_cost': transportCost,
    'net_revenue': netRevenue,
    'feasible': feasible,
    'is_recommended': isRecommended,
  };
}

class MarketOptionData {
  final String market;
  final String buyerName;
  final RoutingData route;
  final TransportData transport;
  final SpoilageData spoilage;
  final PriceData price;
  final DemandData demand;
  final DecisionData decision;

  const MarketOptionData({
    required this.market,
    required this.buyerName,
    required this.route,
    required this.transport,
    required this.spoilage,
    required this.price,
    required this.demand,
    required this.decision,
  });

  factory MarketOptionData.fromJson(Map<String, dynamic> json) {
    return MarketOptionData(
      market: json['market']?.toString() ?? '',
      buyerName: json['buyer_name']?.toString() ?? json['buyer']?.toString() ?? '',
      route: RoutingData.fromJson(
        (json['routing'] ?? json['route'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
      transport: TransportData.fromJson(
        (json['transport'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
      spoilage: SpoilageData.fromJson(
        (json['spoilage'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
      price: PriceData.fromJson(
        (json['price'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
      demand: DemandData.fromJson(
        (json['demand'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
      decision: DecisionData.fromJson(
        (json['decision'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'market': market,
    'buyer_name': buyerName,
    'routing': route.toJson(),
    'transport': transport.toJson(),
    'spoilage': spoilage.toJson(),
    'price': price.toJson(),
    'demand': demand.toJson(),
    'decision': decision.toJson(),
  };
}

class RecommendationSummaryData {
  final String market;
  final String buyerName;
  final String reason;

  const RecommendationSummaryData({
    required this.market,
    required this.buyerName,
    required this.reason,
  });

  factory RecommendationSummaryData.fromJson(Map<String, dynamic> json) {
    return RecommendationSummaryData(
      market: json['market']?.toString() ?? '',
      buyerName: json['buyer_name']?.toString() ?? json['buyer']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'market': market,
    'buyer_name': buyerName,
    'reason': reason,
  };
}

class RecommendationResponse {
  final SupplyData supply;
  final FreshnessData freshness;
  final String priceUnit;
  final List<MarketOptionData> markets;
  final RecommendationSummaryData recommendation;

  const RecommendationResponse({
    required this.supply,
    required this.freshness,
    required this.priceUnit,
    required this.markets,
    required this.recommendation,
  });

  /// Returns the recommended [MarketOptionData] from the [markets] list.
  MarketOptionData get recommendedMarket {
    return markets.firstWhere(
      (m) =>
          m.market.toLowerCase() == recommendation.market.toLowerCase() &&
          m.buyerName.toLowerCase() == recommendation.buyerName.toLowerCase(),
      orElse: () => markets.first,
    );
  }

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    final rawMarkets = json['markets'] as List<dynamic>? ?? [];
    return RecommendationResponse(
      supply: SupplyData.fromJson(
        (json['supply'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
      freshness: FreshnessData.fromJson(
        (json['freshness'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
      priceUnit: json['price_unit']?.toString() ?? 'INR/kg',
      markets: rawMarkets
          .map((m) => MarketOptionData.fromJson(m as Map<String, dynamic>))
          .toList(),
      recommendation: RecommendationSummaryData.fromJson(
        (json['recommendation'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'supply': supply.toJson(),
    'freshness': freshness.toJson(),
    'price_unit': priceUnit,
    'markets': markets.map((m) => m.toJson()).toList(),
    'recommendation': recommendation.toJson(),
  };

  /// Provides the exact sample mock data specified in STEP 4 for deterministic UI development.
  static RecommendationResponse get mockSample {
    return const RecommendationResponse(
      supply: SupplyData(
        commodity: 'Rice',
        state: 'Andhra Pradesh',
        district: 'Guntur',
        farmAreaHa: 5.0,
        predictedYieldKgPerHa: 5451.25,
        expectedSupplyKg: 27256.2498,
        expectedSupplyTonnes: 27.2562,
      ),
      freshness: FreshnessData(
        freshProbability: 0.9231,
        rottenProbability: 0.0769,
        confidence: 0.9231,
      ),
      priceUnit: 'INR/kg',
      markets: [
        MarketOptionData(
          market: 'Guntur Market',
          buyerName: 'Buyer A',
          route: RoutingData(
            distanceKm: 2.18,
            travelTimeHours: 0.05,
          ),
          transport: TransportData(
            transportCost: 65.40,
          ),
          spoilage: SpoilageData(
            spoilagePercentage: 14.0968,
            saleableQuantityKg: 23413.9817,
            spoiledQuantityKg: 3842.27,
            riskLevel: 'LOW',
          ),
          price: PriceData(
            currentModalPrice: 3300.0,
            predictedFutureModalPrice: 3229.90,
            predictedPricePerKg: 32.30,
            priceUnit: 'INR/kg',
          ),
          demand: DemandData(
            demandKg: 5000.0,
            availableCapacityKg: 28000.0,
            buyerCapacityKg: 30000.0,
            demandCoverage: 0.4,
            demandLevel: 'low_demand',
            capacityStatus: 'Available',
          ),
          decision: DecisionData(
            sellableQuantityKg: 5000.0,
            grossRevenue: 161500.0,
            transportCost: 65.40,
            netRevenue: 161434.60,
            feasible: true,
            isRecommended: false,
          ),
        ),
        MarketOptionData(
          market: 'Vijayawada Market',
          buyerName: 'Buyer B',
          route: RoutingData(
            distanceKm: 35.9,
            travelTimeHours: 0.6,
          ),
          transport: TransportData(
            transportCost: 1077.0,
          ),
          spoilage: SpoilageData(
            spoilagePercentage: 14.326,
            saleableQuantityKg: 23351.5195,
            spoiledQuantityKg: 3904.73,
            riskLevel: 'LOW',
          ),
          price: PriceData(
            currentModalPrice: 3400.0,
            predictedFutureModalPrice: 3437.81,
            predictedPricePerKg: 34.38,
            priceUnit: 'INR/kg',
          ),
          demand: DemandData(
            demandKg: 6000.0,
            availableCapacityKg: 28000.0,
            buyerCapacityKg: 30000.0,
            demandCoverage: 0.3333,
            demandLevel: 'low_demand',
            capacityStatus: 'Available',
          ),
          decision: DecisionData(
            sellableQuantityKg: 6000.0,
            grossRevenue: 206280.0,
            transportCost: 1077.0,
            netRevenue: 205203.0,
            feasible: true,
            isRecommended: true,
          ),
        ),
      ],
      recommendation: RecommendationSummaryData(
        market: 'Vijayawada Market',
        buyerName: 'Buyer B',
        reason:
            'Highest feasible net expected revenue after transport cost, while accounting for spoilage and buyer capacity.',
      ),
    );
  }
}

/// Helper functions for safe type conversion
double? _toDouble(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val);
  return null;
}
