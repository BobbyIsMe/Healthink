class FoodAddons {
  static Map<String, Map<String, FoodAddons>> menu = {
    "chicken": {
      ConstantAddon.rice.addon: ConstantAddon.rice.foodAddons,
      ConstantAddon.utensil.addon: ConstantAddon.utensil.foodAddons,
    },
    "pork": {
      ConstantAddon.rice.addon: ConstantAddon.rice.foodAddons,
      ConstantAddon.utensil.addon: ConstantAddon.utensil.foodAddons,
    },
    "silog": {
      ConstantAddon.rice.addon: ConstantAddon.rice.foodAddons,
      ConstantAddon.utensil.addon: ConstantAddon.utensil.foodAddons,
    },
    "lumpia shanghai": {
      ConstantAddon.rice.addon: ConstantAddon.rice.foodAddons,
      ConstantAddon.utensil.addon: ConstantAddon.utensil.foodAddons,
    },
    "ngohiong": {
      ConstantAddon.rice.addon: ConstantAddon.rice.foodAddons,
      ConstantAddon.utensil.addon: ConstantAddon.utensil.foodAddons,
    },
    "burp burger": {
      ConstantAddon.patty.addon: ConstantAddon.patty.foodAddons,
      ConstantAddon.cheese.addon: ConstantAddon.cheese.foodAddons,
      ConstantAddon.ham.addon: ConstantAddon.ham.foodAddons,
      ConstantAddon.egg.addon: ConstantAddon.egg.foodAddons,
    },
    "sandwich": {
      ConstantAddon.patty.addon: ConstantAddon.patty.foodAddons,
      ConstantAddon.cheese.addon: ConstantAddon.cheese.foodAddons,
      ConstantAddon.ham.addon: ConstantAddon.ham.foodAddons,
      ConstantAddon.egg.addon: ConstantAddon.egg.foodAddons,
    },
    "squid roll": {
      ConstantAddon.rice.addon: ConstantAddon.rice.foodAddons,
      ConstantAddon.utensil.addon: ConstantAddon.utensil.foodAddons,
    },
    "squid ball": {
      ConstantAddon.rice.addon: ConstantAddon.rice.foodAddons,
      ConstantAddon.utensil.addon: ConstantAddon.utensil.foodAddons,
    },
    "tempura": {
      ConstantAddon.rice.addon: ConstantAddon.rice.foodAddons,
      ConstantAddon.utensil.addon: ConstantAddon.utensil.foodAddons,
    },
  };

  final double calories, price, protein, carbs, fats, iron, zinc, b12;

  const FoodAddons(
      {required this.calories,
      required this.protein,
      required this.carbs,
      required this.fats,
      required this.iron,
      required this.zinc,
      required this.b12,
      required this.price});
}

class ConstantAddon {
  final String addon;
  final FoodAddons foodAddons;

  const ConstantAddon({required this.addon, required this.foodAddons});

  static const patty = ConstantAddon(
      addon: 'patty',
      foodAddons: FoodAddons(
        calories: 95,
        protein: 2.3,
        carbs: 9,
        fats: 6.4,
        iron: 0,
        zinc: 0,
        b12: 0,
        price: 15,
      ));

  static const cheese = ConstantAddon(
      addon: 'cheese',
      foodAddons: FoodAddons(
        calories: 113,
        protein: 6.4,
        carbs: 0.9,
        fats: 9.3,
        iron: 0,
        zinc: 0,
        b12: 0,
        price: 10,
      ));

  static const ham = ConstantAddon(
      addon: 'ham',
      foodAddons: FoodAddons(
        calories: 49,
        protein: 5.5,
        carbs: 0.7,
        fats: 2.5,
        iron: 0.3,
        zinc: 0,
        b12: 0,
        price: 15,
      ));

  static const egg = ConstantAddon(
      addon: 'egg',
      foodAddons: FoodAddons(
        calories: 59,
        protein: 5,
        carbs: 0.3,
        fats: 4,
        iron: 0.7,
        zinc: 0,
        b12: 0,
        price: 15,
      ));

  static const rice = ConstantAddon(
      addon: 'rice',
      foodAddons: FoodAddons(
        calories: 205,
        protein: 4.3,
        carbs: 45,
        fats: 0.4,
        iron: 1.9,
        zinc: 0,
        b12: 0,
        price: 15,
      ));

  static const utensil = ConstantAddon(
      addon: 'utensil',
      foodAddons: FoodAddons(
        calories: 0,
        protein: 0,
        carbs: 0,
        fats: 0,
        iron: 0,
        zinc: 0,
        b12: 0,
        price: 5,
      ));

  MapEntry<String, FoodAddons> toEntry() => MapEntry(addon, foodAddons);
}
