from services.recommendation_service import RecommendationService
import json


service = RecommendationService()

data = {
    "supply": {
        "state_name": "Andhra Pradesh",
        "dist_name": "Guntur",
        "crop": "Rice",
        "area_ha": 5.0,
        "year": 2018,
        "n_req_kg_per_ha": 120.0,
        "p_req_kg_per_ha": 60.0,
        "k_req_kg_per_ha": 40.0,
        "temperature_c": 28.0,
        "humidity_percent": 75.0,
        "ph": 6.5,
        "rainfall_mm": 900.0,
        "wind_speed_m_s": 3.0,
        "solar_radiation_mj_m2_day": 18.0
    },

    "freshness": {
        "image_path": "test_images/sample_produce.jpg",
        "shelf_life_hours": 72
    },

    "farmer_location": {
        "latitude": 16.3067,
        "longitude": 80.4365
    },

    "spoilage": {
        "shelf_life_hours": 72,
        "temperature_c": 28.0,
        "humidity_percent": 75.0
    },

    "markets": [
        {
            "market": "Guntur Market",
            "buyer_name": "Buyer A",
            "latitude": 16.3000,
            "longitude": 80.4500,
            "price_unit": "INR/kg",

            "price": {
                "State": "Andhra Pradesh",
                "District": "Guntur",
                "Market": "Guntur",
                "Commodity": "Rice",
                "Variety": "Common",
                "Grade": "FAQ",
                "Date": "2025-04-16",
                "Min_Price": 3000.0,
                "Max_Price": 3500.0,
                "Modal_Price": 3300.0,
                "Previous_Price": 3250.0,
                "Price_Change": 50.0,
                "Rolling_Mean_3": 3283.33,
                "Rolling_Mean_7": 3310.71,
                "Commodity_Code": 82
            },

            "demand": {
                "commodity": "Rice",
                "demand_kg": 5000.0,
                "buyer_capacity_kg": 30000.0,
                "current_supply_kg": 2000.0
            },

            "transport": {
                "cost_per_km": 30.0
            },

            "shelf_life_hours": 72,
            "temperature_c": 28.0,
            "humidity_percent": 75.0
        },

        {
            "market": "Vijayawada Market",
            "buyer_name": "Buyer B",
            "latitude": 16.5062,
            "longitude": 80.6480,
            "price_unit": "INR/kg",

            "price": {
                "State": "Andhra Pradesh",
                "District": "Krishna",
                "Market": "Vijayawada",
                "Commodity": "Rice",
                "Variety": "Common",
                "Grade": "FAQ",
                "Date": "2025-04-16",
                "Min_Price": 3100.0,
                "Max_Price": 3600.0,
                "Modal_Price": 3400.0,
                "Previous_Price": 3350.0,
                "Price_Change": 50.0,
                "Rolling_Mean_3": 3383.33,
                "Rolling_Mean_7": 3410.71,
                "Commodity_Code": 82
            },

            "demand": {
                "commodity": "Rice",
                "demand_kg": 6000.0,
                "buyer_capacity_kg": 30000.0,
                "current_supply_kg": 2000.0
            },

            "transport": {
                "cost_per_km": 30.0
            },

            "shelf_life_hours": 72,
            "temperature_c": 28.0,
            "humidity_percent": 75.0
        }
    ]
}


try:
    result = service.recommend(data)

    print("\n" + "=" * 70)
    print("REAL END-TO-END RECOMMENDATION RESULT")
    print("=" * 70)

    print(json.dumps(result, indent=2, default=str))

    print("\n" + "=" * 70)
    print("IMPORTANT CHECKS")
    print("=" * 70)

    print("Expected supply:",
          result["supply"]["expected_supply_kg"], "kg")

    print("Freshness:",
          result["freshness"]["predicted_class"])

    for market in result["markets"]:
        print("\nMarket:", market["market"])
        print("Distance:",
              market["routing"]["distance_km"], "km")
        print("Transport cost:",
              market["transport"]["total_transport_cost"])
        print("Spoilage:",
              market["spoilage"]["spoilage_percentage"], "%")
        print("Predicted price:",
              market["price"]["predicted_future_modal_price"],
              "INR/quintal")
        print("Predicted price per kg:",
              market["price"]["predicted_price_per_kg"],
              "INR/kg")
        print("Decision:",
              market["decision"])

    print("\nRecommended market:",
          result["recommendation"])

    print("\n" + "=" * 70)
    print("E2E TEST COMPLETED")
    print("=" * 70)

except Exception as e:
    print("\n" + "=" * 70)
    print("E2E TEST FAILED")
    print("=" * 70)
    print(type(e).__name__ + ":", str(e))
