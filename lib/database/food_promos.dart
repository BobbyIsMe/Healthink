class FoodPromos {
  static Map<String, Map<String, FoodPromos>> menu = {
    "chicken": {
      ConstantPromo.rice.addon: ConstantPromo.rice.foodAddons,
    },
    "pork": {
      ConstantPromo.rice.addon: ConstantPromo.rice.foodAddons,
    },
    "silog": {
      ConstantPromo.rice.addon: ConstantPromo.rice.foodAddons,
    },
  };

  final double calories, price, protein, carbs, fats, iron, zinc, b12;

  const FoodPromos(
      {required this.calories,
      required this.protein,
      required this.carbs,
      required this.fats,
      required this.iron,
      required this.zinc,
      required this.b12,
      required this.price});
}

class ConstantPromo {
  final String addon;
  final FoodPromos foodAddons;

  const ConstantPromo({required this.addon, required this.foodAddons});

  static const rice = ConstantPromo(
      addon: 'rice',
      foodAddons: FoodPromos(
        calories: 205,
        protein: 4.3,
        carbs: 45,
        fats: 0.4,
        iron: 1.9,
        zinc: 0,
        b12: 0,
        price: 10,
      ));
}
