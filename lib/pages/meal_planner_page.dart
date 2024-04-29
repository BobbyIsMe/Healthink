import 'package:flutter/material.dart';
import 'package:healthink/database/database_helper.dart';
import 'package:healthink/database/food_addons.dart';
import 'package:healthink/database/food_menu.dart';
import 'package:healthink/database/food_promos.dart';
import 'package:healthink/pages/category_page.dart';
import 'package:healthink/pages/planner_data_page.dart';
import 'package:healthink/widgets/row_space.dart';
import 'package:healthink/widgets/text_header.dart';

class UserMP extends StatefulWidget {
  const UserMP(
      {super.key,
      required this.month,
      required this.day,
      required this.year,
      required this.date});

  final String month;
  final String day;
  final String year;
  final String date;

  @override
  State<StatefulWidget> createState() => _UserMPState();
}

class _UserMPState extends State<UserMP> {
  List<MealPlanner> mealPlanners = [];
  int cur = -1;
  int category = -1;
  late Future<List<MealPlanner>> planner;

  @override
  void initState() {
    planner = updatePlanner();
    super.initState();
  }

  Future<List<MealPlanner>> updatePlanner() async {
    return await DatabaseHelper.instance.getAllMP(widget.date);
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FoodStall(
                          date: widget.date,
                          mealPlanners: mealPlanners,
                        ))).then((value) => setState(() {
                  planner = updatePlanner();
                  cur = -1;
                  category = -1;
                }));
          },
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
        backgroundColor: const Color.fromARGB(255, 240, 236, 236),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  width: double.infinity,
                  color: Colors.green,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${widget.month} ${widget.day}\n${widget.year}",
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              height: 1,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PlannerDataPage(
                                          date: widget.date,
                                          mealPlanners: mealPlanners,
                                        )));
                          },
                          icon: const Icon(Icons.list, size: 50),
                          color: Colors.white,
                        )
                      ])),
              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<List<MealPlanner>?>(
                          future: planner,
                          builder: (context,
                              AsyncSnapshot<List<MealPlanner>?> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                color: Colors.green,
                              ));
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text(snapshot.error.toString()));
                            } else if (snapshot.hasData) {
                              if (snapshot.data != null) {
                                mealPlanners = snapshot.data!;
                                List<MealPlanner> edibles = snapshot.data!
                                    .where((element) => element.category == 1)
                                    .toList();
                                List<MealPlanner> beverages = snapshot.data!
                                    .where((element) => element.category == 2)
                                    .toList();
                                return plan(context, edibles, beverages);
                              }
                            }
                            return plan(context, null, null);
                          }),
                      const SizedBox(
                        height: 20,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  )),
              const SizedBox(
                height: 50,
              )
            ])));
  }

  Widget mealPlannerWidget(BuildContext context, List<MealPlanner>? mP, int c) {
    if (mP == null || mP.isEmpty) {
      return const ContainerView(
          colorName: Colors.green,
          width: 350,
          margin: EdgeInsets.only(top: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(height: 20),
            Center(
                child: Icon(
              Icons.no_meals_outlined,
              color: Colors.white,
              size: 50,
            )),
            SizedBox(height: 10),
            Center(
                child: Text("Nothing added yet in this category!",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      height: 1,
                      fontSize: 20,
                      color: Colors.white,
                    ))),
            SizedBox(height: 20),
          ]));
    }
    return Wrap(
        direction: Axis.vertical,
        children: List.generate(mP.length, (index) {
          return Row(children: [
            foodContainerView(mP[index], 350, 10, Colors.white, c, index),
            AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(top: 10, left: 10),
                height: (cur == index && category == c) ? 120 : 0,
                width: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green,
                ))
          ]);
        }));
  }

  Widget plan(BuildContext context, List<MealPlanner>? edibles,
      List<MealPlanner>? beverages) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const TextHeader(
        text: "Edibles",
      ),
      mealPlannerWidget(context, edibles, 1),
      const SizedBox(
        height: 20,
      ),
      const TextHeader(
        text: "Beverages",
      ),
      mealPlannerWidget(context, beverages, 2),
    ]);
  }

  Widget foodContainerView(MealPlanner mp, double width, double gap,
      Color colorName, int c, int index) {
    List<String> addons = mp.addons.split(',');
    List<String> addonsValue = mp.addonsValue.split(',');
    AssetImage image = FoodMenu.menu[mp.category]![mp.foodName]!.image;
    Color grey = Colors.grey;
    Color green = Colors.green;
    Color black = Colors.black;
    Color white = Colors.white;
    if (mp.done == 1) {
      grey = Colors.white;
      green = Colors.white;
      black = Colors.white;
      white = Colors.green;
    }
    return GestureDetector(
        onTap: () {
          setState(() {
            category = c;
            if (cur != index) {
              cur = index;
            } else {
              cur = -1;
            }
          });
        },
        onLongPress: () {
          setState(() {
            category = c;
            cur = index;
          });
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            barrierColor: Colors.black87.withOpacity(0.5),
            isDismissible: true,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            builder: (context) => Container(
              height: 400,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30)),
                        image:
                            DecorationImage(fit: BoxFit.cover, image: image)),
                  ),
                  const SizedBox(height: 10),
                  addonsWidget(mp),
                  valueWidget(
                      'Calories:', '${mp.calories.toStringAsFixed(1)} kcal'),
                  const Divider(
                    color: Colors.grey,
                  ),
                  valueWidget('Protein:', '${mp.protein.toStringAsFixed(1)} g'),
                  valueWidget(
                      'Carbohydrates:', '${mp.carbs.toStringAsFixed(1)} g'),
                  valueWidget('Fats:', '${mp.fats.toStringAsFixed(1)} g'),
                  const Divider(
                    color: Colors.grey,
                  ),
                  valueWidget('Iron:', '${mp.iron.toStringAsFixed(1)} mg'),
                  valueWidget('Zinc:', '${mp.zinc.toStringAsFixed(1)} mg'),
                  valueWidget(
                      'Vitamin B12:', '${mp.b12.toStringAsFixed(1)} µg'),
                ],
              ),
            ),
          );
        },
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(top: gap),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            height: 145,
            width: width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 10,
                  ),
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                        alignment: Alignment.center,
                        width: 120,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                fit: BoxFit.cover, image: image))),
                    const SizedBox(width: 5),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                    spacing: -5,
                                    direction: Axis.vertical,
                                    children: [
                                      Text(
                                        mp.foodName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: black,
                                        ),
                                      ),
                                      Text(
                                        '• ${mp.variant}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: grey,
                                        ),
                                      ),
                                    ]),
                                if (addons.first.isNotEmpty)
                                  Wrap(
                                    spacing: -5,
                                    direction: Axis.vertical,
                                    children:
                                        List.generate(addons.length, (index) {
                                      return Row(children: [
                                        Text('${addonsValue[index]}x ',
                                            style: TextStyle(color: green)),
                                        Text(addons[index],
                                            style: TextStyle(color: grey))
                                      ]);
                                    }),
                                  )
                              ]),
                          Row(children: [
                            Text(
                              '${mp.amount}x ',
                              style: TextStyle(
                                color: green,
                              ),
                            ),
                            Text(
                              'Serv. Amount',
                              style: TextStyle(
                                color: grey,
                              ),
                            ),
                          ]),
                        ]),
                  ],
                ),
                Wrap(
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 5,
                  children: [
                    button(c, index, () {
                      setState(() {
                        mp.toggleDone();
                        if (mp.done == 1) {
                          DatabaseHelper.instance
                              .completeMP(mp.id!, widget.date, 1);
                        } else {
                          DatabaseHelper.instance
                              .completeMP(mp.id!, widget.date, 0);
                        }
                      });
                    }, (mp.done == 0) ? Icons.check : Icons.close, green,
                        white),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: green,
                          ),
                        ),
                        child: Center(
                            child: Text(
                          '₱${mp.price}',
                          style: TextStyle(color: green, fontSize: 15),
                        ))),
                    button(c, index, () {
                      setState(() {
                        mealPlanners.remove(mp);
                        mealPlanners = mealPlanners;
                        DatabaseHelper.instance.deleteMP(widget.date, mp);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "You've removed ${mp.amount}x ${mp.foodName} (${mp.variant})!"),
                          showCloseIcon: true,
                          duration: const Duration(seconds: 2),
                        ));
                        if (mealPlanners.isEmpty) {
                          cur = -1;
                          category = -1;
                        }
                      });
                    }, Icons.delete, green, white),
                  ],
                )
              ],
            )));
  }

  Future<List<MealPlanner>> delete(MealPlanner mp) async {
    await DatabaseHelper.instance.deleteMP(widget.date, mp);
    return await DatabaseHelper.instance.getAllMP(widget.date);
  }

  Widget button(int c, int index, Function() onTap, IconData icon, Color green,
      Color white) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: (cur == index && category == c) ? 30 : 0,
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: green,
        ),
        child: Icon(
          icon,
          color: white,
          size: 15,
        ),
      ),
    );
  }

  Widget addonsWidget(MealPlanner mp) {
    List<String> addons = mp.addons.split(',');
    List<String> promos = mp.promos.split(',');
    List<String> addonsValue = mp.addonsValue.split(',');
    return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: Column(children: [
          RowSpace(
              lWidget: Row(children: [
                Text(
                  mp.foodName,
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  ' | ${mp.variant}',
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ]),
              rWidget: [
                Text(
                  '₱${FoodMenu.menu[mp.category]![mp.foodName]!.variants[mp.variant]!.price}',
                  style: const TextStyle(fontSize: 15, color: Colors.green),
                ),
              ]),
          const Divider(
            color: Colors.grey,
          ),
          if (mp.addons.isNotEmpty)
            Column(
              children: List.generate(addons.length, (index) {
                String ad = addons[index];
                int promo =
                    (mp.promos.isNotEmpty) ? int.parse(promos[index]) : 0;
                int amount = int.parse(addonsValue.elementAt(index));
                double price = 0;
                if (promo >= 1) {
                  price += FoodPromos.menu[mp.foodName]![ad]!.price * promo;
                }
                if (promo < amount) {
                  price += FoodAddons.menu[mp.foodName]![ad]!.price *
                      (amount - promo);
                }
                return Column(children: [
                  const SizedBox(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Text(
                            '${amount}x ',
                            style: const TextStyle(
                                fontSize: 15, color: Colors.green),
                          ),
                          Text(
                            addons.elementAt(index),
                            style: const TextStyle(
                                fontSize: 15, color: Colors.grey),
                          ),
                        ]),
                        Text(
                          '₱$price',
                          style: const TextStyle(
                              fontSize: 15, color: Colors.green),
                        ),
                      ]),
                  const SizedBox(height: 10),
                  const Divider(
                    color: Colors.grey,
                  )
                ]);
              }),
            ),
          valueWidget('Amount: ', '${mp.amount}x'),
          detailWidget('Total Cost: ', '₱${mp.price}', FontWeight.bold)
        ]));
  }

  Widget valueWidget(String left, String cur) {
    return detailWidget(left, cur, FontWeight.normal);
  }

  Widget detailWidget(String left, String cur, FontWeight weight) {
    return RowSpace(
        lWidget: Row(children: [
          Text(
            left,
            style: TextStyle(fontSize: 15, fontWeight: weight),
          ),
        ]),
        rWidget: [
          Text(
            cur.toString(),
            style: TextStyle(
                fontSize: 15, color: Colors.green, fontWeight: weight),
          ),
        ]);
  }
}

class ContainerView extends StatelessWidget {
  final Color colorName;
  final double width;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Widget child;

  const ContainerView(
      {super.key,
      required this.colorName,
      required this.width,
      required this.margin,
      this.padding = const EdgeInsets.all(0),
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        padding: padding,
        width: width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: colorName,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 10,
              ),
            ]),
        child: child);
  }
}
