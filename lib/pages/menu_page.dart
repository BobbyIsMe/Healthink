import 'package:flutter/material.dart';
import 'package:healthink/database/database_helper.dart';
import 'package:healthink/database/food_addons.dart';
import 'package:healthink/database/food_menu.dart';
import 'package:healthink/database/food_promos.dart';
import 'package:healthink/pages/meal_planner_page.dart';
import 'package:healthink/widgets/food_page_body.dart';
import 'package:healthink/widgets/row_space.dart';
import 'package:healthink/widgets/text_desc.dart';
import 'package:healthink/widgets/text_header.dart';

class Menu extends StatefulWidget {
  final int category;
  final String date;
  final List<MealPlanner> mealPlanners;
  final ProfileLimiter lim;
  const Menu(
      {required this.category,
      required this.date,
      required this.mealPlanners,
      required this.lim,
      super.key});

  @override
  State<StatefulWidget> createState() => MenuState();
}

class MenuState extends State<Menu> {
  late FoodMenuBody body;
  late FoodMenu foodMenu;
  late List<String> variants;
  late List<String>? promos;
  late List<String>? addons;
  late Map<String, int> addonsValue;
  late Map<String, int> promosValue;
  late ProgressPlanner p;
  late ProfileLimiter lim;
  String foodName = "", variant = "";
  int amount = 1, curIndex = 0;
  double protein = 0,
      carbs = 0,
      fats = 0,
      iodine = 0,
      iron = 0,
      zinc = 0,
      b12 = 0,
      calories = 0,
      price = 0;

  @override
  void initState() {
    addonsValue = {};
    promosValue = {};
    foodName = FoodMenu.menu[widget.category]!.keys.first;
    body = FoodMenu.menu[widget.category]![foodName]!;
    variants = body.variants.keys.toList();
    variant = variants.first;
    foodMenu = body.variants[variant]!;
    addons = FoodAddons.menu[foodName]?.keys.toList();
    promos = FoodPromos.menu[foodName]?.keys.toList();
    calories = foodMenu.calories;
    protein = foodMenu.protein;
    carbs = foodMenu.carbs;
    fats = foodMenu.fats;
    iron = foodMenu.iron;
    zinc = foodMenu.zinc;
    b12 = foodMenu.b12;
    price = foodMenu.price;
    p = DatabaseHelper.instance.getProgress(widget.mealPlanners, widget.date);
    lim = widget.lim;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Healthink"),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: true,
        ),
        backgroundColor: const Color.fromARGB(255, 240, 236, 236),
        bottomNavigationBar: bottomBarWidget(),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FoodPageBody(
                    category: widget.category,
                    onClick: (body, index) {
                      if (curIndex != index) {
                        setState(() {
                          addonsValue = {};
                          promosValue = {};
                          amount = 1;
                          curIndex = index;
                          this.body = body;
                          variants = body.variants.keys.toList();
                          variant = variants.first;
                          foodMenu = body.variants[variant]!;
                          foodName = FoodMenu.menu[widget.category]!.keys
                              .elementAt(index);
                          addons = FoodAddons.menu[foodName]?.keys.toList();
                          promos = FoodPromos.menu[foodName]?.keys.toList();
                          calories = foodMenu.calories * amount;
                          protein = foodMenu.protein * amount;
                          carbs = foodMenu.carbs * amount;
                          fats = foodMenu.fats * amount;
                          iron = foodMenu.iron * amount;
                          zinc = foodMenu.zinc * amount;
                          b12 = foodMenu.b12 * amount;
                          price = foodMenu.price * amount;
                        });
                      }
                    },
                  ),
                  Container(
                      padding: const EdgeInsets.only(top: 10),
                      width: 350,
                      child: const TextHeader(text: "Serving Amount")),
                  ContainerView(
                      colorName: Colors.white,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      width: 350,
                      child: Column(children: [
                        TextHeader(
                          text: foodName,
                        ),
                        const Divider(
                          color: Colors.grey,
                        ),
                        promosWidget(),
                        dropdownWidget(),
                        addonsWidget(),
                        amountWidget(),
                      ])),
                  Container(
                      padding: const EdgeInsets.only(top: 10),
                      width: 350,
                      child: const TextHeader(text: "Nutrients & Price")),
                  ContainerView(
                      colorName: Colors.white,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      width: 350,
                      child: Column(children: [
                        nutritionValue("Calories: ", 'kcal', calories,
                            p.calories, lim.calories),
                        const Divider(
                          color: Colors.grey,
                        ),
                        nutritionValue(
                            "Protein: ", 'g', protein, p.protein, lim.protein),
                        nutritionValue(
                            "Carbohydrates: ", 'g', carbs, p.carbs, lim.carbs),
                        nutritionValue("Fats: ", 'g', fats, p.fats, lim.fats),
                        const Divider(
                          color: Colors.grey,
                        ),
                        nutritionValue("Iron: ", 'mg', iron, p.iron, lim.iron),
                        nutritionValue("Zinc: ", 'mg', zinc, p.zinc, lim.zinc),
                        nutritionValue(
                            "Vitamin B12: ", 'μg', b12, p.b12, lim.b12),
                        const Divider(
                          color: Colors.grey,
                        ),
                        detailWidget("Price: ", "+ ₱$price", price, p.price,
                            lim.price, FontWeight.bold),
                      ])),
                  const SizedBox(
                    height: 20,
                  ),
                ])));
  }

  Widget nutritionValue(
      String nutrient, String unit, double cur, double p, double value) {
    return detailWidget(nutrient, "+ ${cur.toStringAsFixed(1)} $unit", cur, p,
        value, FontWeight.normal);
  }

  Widget detailWidget(String nutrient, String cur, double d, double p,
      double value, FontWeight fontWeight) {
    return RowSpace(
        lWidget: Row(children: [
          TextDesc(
            text: nutrient,
            fontWeight: fontWeight,
          ),
          TextDesc(
            text: cur,
            color: (d + p <= value || d == 0) ? Colors.green : Colors.red,
            fontWeight: fontWeight,
          ),
        ]),
        rWidget: [
          TextDesc(
              text: p.toStringAsFixed(1),
              color: (p <= value) ? Colors.green : Colors.red),
          TextDesc(text: '/${value.toStringAsFixed(1)}')
        ]);
  }

  Widget dropdownWidget() {
    return Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: DropdownButton(
          value: variant,
          isExpanded: true,
          items: variants.map(
            (e) {
              return DropdownMenuItem(
                value: e,
                child: Text(e),
              );
            },
          ).toList(),
          onChanged: (variants.length != 1)
              ? (value) {
                  setState(() {
                    variant = value.toString();
                    updateDetails(-1);

                    foodMenu = body.variants[variant]!;

                    updateDetails(1);
                  });
                }
              : null,
        ));
  }

  void updateDetails(int num) {
    calories = calories + num * (foodMenu.calories * amount);
    protein = protein + num * (foodMenu.protein * amount);
    carbs = carbs + num * (foodMenu.carbs * amount);
    fats = fats + num * (foodMenu.fats * amount);
    iron = iron + num * (foodMenu.iron * amount);
    zinc = zinc + num * (foodMenu.zinc * amount);
    b12 = b12 + num * (foodMenu.b12 * amount);
    price = price + num * (foodMenu.price * amount);
  }

  Widget promosWidget() {
    if (promos == null) return const SizedBox(height: 10);
    return Column(
        children: List.generate(promos!.length, (index) {
      String ad = promos![index];
      int? aV = promosValue[ad];
      return Row(
        children: [
          TextDesc(text: 'w/ $ad'),
          Switch(
            value: aV != null,
            onChanged: (value) {
              setState(() {
                FoodPromos addon = FoodPromos.menu[foodName]![ad]!;
                if (aV == null) {
                  promosValue[ad] = 1;
                  updateValues(
                      ad,
                      amount,
                      addon.calories,
                      addon.protein,
                      addon.carbs,
                      addon.fats,
                      addon.iron,
                      addon.zinc,
                      addon.b12,
                      addon.price);
                } else {
                  promosValue.remove(ad);
                  updateValues(
                      ad,
                      -amount,
                      addon.calories,
                      addon.protein,
                      addon.carbs,
                      addon.fats,
                      addon.iron,
                      addon.zinc,
                      addon.b12,
                      addon.price);
                }
              });
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.black12,
            trackOutlineColor: MaterialStateProperty.all(Colors.white),
          )
        ],
      );
    }));
  }

  Widget addonsWidget() {
    if (addons == null) return const SizedBox(height: 10);
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        width: 340,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: Column(children: [
          const TextDesc(
            text: "Addons",
            fontWeight: FontWeight.bold,
          ),
          const Divider(
            color: Colors.grey,
          ),
          Container(
              width: 340,
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Wrap(
                  children: List.generate(addons!.length, (index) {
                String ad = addons![index];
                int? aV = addonsValue[ad];
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextDesc(
                          text: addons!.elementAt(index),
                        ),
                        Row(children: [
                          IconButton(
                            onPressed: (aV != null)
                                ? () {
                                    setState(() {
                                      if (aV == 1) {
                                        addonsValue.remove(ad);
                                      } else {
                                        addonsValue[ad] = aV - 1;
                                      }
                                      FoodAddons addon =
                                          FoodAddons.menu[foodName]![ad]!;
                                      updateValues(
                                          ad,
                                          -amount,
                                          addon.calories,
                                          addon.protein,
                                          addon.carbs,
                                          addon.fats,
                                          addon.iron,
                                          addon.zinc,
                                          addon.b12,
                                          addon.price);
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_left),
                          ),
                          Container(
                            width: 30,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey,
                              ),
                            ),
                            child: Text(
                              (aV != null) ? aV.toString() : '0',
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            onPressed: (aV == null || aV != 10)
                                ? () {
                                    setState(() {
                                      if (aV == null) {
                                        addonsValue[ad] = 1;
                                      } else {
                                        addonsValue[ad] = aV + 1;
                                      }
                                      FoodAddons addon =
                                          FoodAddons.menu[foodName]![ad]!;
                                      updateValues(
                                          ad,
                                          amount,
                                          addon.calories,
                                          addon.protein,
                                          addon.carbs,
                                          addon.fats,
                                          addon.iron,
                                          addon.zinc,
                                          addon.b12,
                                          addon.price);
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_right),
                          )
                        ])
                      ],
                    ),
                    if (index + 1 != addons!.length)
                      const Divider(
                        color: Colors.grey,
                      )
                  ],
                );
              }))),
        ]));
  }

  void updateValues(
      String ad,
      int amount,
      double calories,
      double protein,
      double carbs,
      double fats,
      double iron,
      double zinc,
      double b12,
      double price) {
    this.calories = this.calories + (calories * amount);
    this.protein = this.protein + (protein * amount);
    this.carbs = this.carbs + (carbs * amount);
    this.fats = this.fats + (fats * amount);
    this.iron = this.iron + (iron * amount);
    this.zinc = this.zinc + (zinc * amount);
    this.b12 = this.b12 + (b12 * amount);
    this.price = this.price + (price * amount);
  }

  Widget amountWidget() {
    return RowSpace(
        lWidget: const TextDesc(
          text: 'Amount',
          fontWeight: FontWeight.bold,
        ),
        rWidget: [
          iconButton(const Icon(Icons.arrow_left), amount - 1, 1),
          Container(
            width: 30,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            child: Text(
              amount.toString(),
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          iconButton(const Icon(Icons.arrow_right), amount + 1, 10)
        ]);
  }

  Widget iconButton(Icon icon, int value, int limit) {
    return IconButton(
      onPressed: (amount != limit)
          ? () {
              setState(() {
                calories = ((calories / amount) * value);
                protein = ((protein / amount) * value);
                carbs = ((carbs / amount) * value);
                fats = ((fats / amount) * value);
                iodine = ((iodine / amount) * value);
                iron = ((iron / amount) * value);
                zinc = ((zinc / amount) * value);
                b12 = ((b12 / amount) * value);
                price = ((price / amount) * value);
                amount = value;
              });
            }
          : null,
      icon: icon,
    );
  }

  Widget bottomBarWidget() {
    return BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shadowColor: Colors.grey,
        height: 70,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              const Text('Total Cost: ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '₱$price',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              )
            ],
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "You've added ${amount}x $foodName ($variant) to planner!"),
                  showCloseIcon: true,
                  duration: const Duration(seconds: 2),
                ));
                Map<String, int> fr = Map.from(addonsValue);
                fr.forEach((key, value) {
                  if (!promosValue.containsKey(key)) promosValue[key] = 0;
                });
                var promosList = promosValue.entries.toList();
                promosList.sort((a, b) => a.key.compareTo(b.key));
                Map<String, int> pr = Map.fromEntries(promosList);
                pr.forEach((key, value) {
                  if (fr[key] != null) {
                    fr[key] = value + 1;
                  } else {
                    if (promosValue[key] != 0) {
                      fr[key] = 1;
                    }
                  }
                });
                var addonsList = fr.entries.toList();
                addonsList.sort((a, b) => a.key.compareTo(b.key));
                Map<String, int> f = Map.fromEntries(addonsList);
                MealPlanner mP = MealPlanner(
                    foodName: foodName,
                    category: widget.category,
                    price: price,
                    amount: amount,
                    variant: variant,
                    addons: f.keys.join(','),
                    promos: pr.values.join(','),
                    addonsValue: f.values.join(','),
                    done: 0,
                    calories: calories,
                    protein: protein,
                    carbs: carbs,
                    fats: fats,
                    iron: iron,
                    zinc: zinc,
                    b12: b12);
                p.calories += mP.calories;
                p.protein += mP.protein;
                p.carbs += mP.carbs;
                p.fats += mP.fats;
                p.iron += mP.iron;
                p.zinc += mP.zinc;
                p.b12 += mP.b12;
                p.price += mP.price;
                widget.mealPlanners.add(mP);
                update(mP);
              });
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)))),
            child: const Text('Add To Planner',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          )
        ]));
  }

  Future<void> update(MealPlanner mP) async {
    await DatabaseHelper.instance.addMP(widget.date, mP);
  }
}

class FoodMenuBody {
  final AssetImage image;
  final Map<String, FoodMenu> variants;

  FoodMenuBody({required this.image, required this.variants});
}
