import 'package:flutter/material.dart';
import 'package:healthink/database/database_helper.dart';
import 'package:healthink/pages/meal_planner_page.dart';
import 'package:healthink/pages/menu_page.dart';
import 'package:healthink/pages/profile_page.dart';
import 'package:healthink/widgets/text_desc.dart';
import 'package:healthink/widgets/text_header.dart';

class FoodStall extends StatefulWidget {
  final String date;
  final List<MealPlanner> mealPlanners;
  const FoodStall({required this.date, required this.mealPlanners, super.key});

  @override
  State<StatefulWidget> createState() => FoodStallState();
}

class FoodStallState extends State<FoodStall> {
  ProfileLimiter? limiter;

  void setLimiter(ProfileLimiter limiter) {
    this.limiter = limiter;
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
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.only(top: 10),
                    width: 350,
                    child: const TextHeader(text: "Categories")),
                categoryWidget('Edibles', 1, Icons.local_pizza_rounded),
                categoryWidget('Beverages', 2, Icons.local_drink_rounded),
                Container(
                    padding: const EdgeInsets.only(top: 20),
                    width: 350,
                    child: const TextHeader(text: "Nutrition & Price Limiter")),
                LimiterWidget(
                  date: widget.date,
                  setLimiter: setLimiter,
                ),
                const SizedBox(height: 20)
              ],
            ))));
  }

  Widget categoryWidget(String name, int category, IconData? icon) {
    return GestureDetector(
        onTap: () {
          setState(() {
            if (limiter != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Menu(
                          mealPlanners: widget.mealPlanners,
                          category: category,
                          date: widget.date,
                          lim: limiter!)));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Menu is initializing, please wait."),
                showCloseIcon: true,
                duration: Duration(seconds: 2),
              ));
            }
          });
        },
        child: ContainerView(
            colorName: Colors.white,
            width: 350,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            margin: const EdgeInsets.only(top: 10),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                alignment: Alignment.center,
                width: 120,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green),
                child: Icon(
                  icon,
                  size: 90,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                name,
                style: const TextStyle(
                    fontSize: 30,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              )
            ])));
  }
}

class LimiterWidget extends StatefulWidget {
  final String date;
  final Function(ProfileLimiter) setLimiter;

  const LimiterWidget(
      {super.key, required this.date, required this.setLimiter});

  @override
  State<StatefulWidget> createState() => LimiterState();
}

class LimiterState extends State<LimiterWidget> {
  late Future<Map<String, ProfileLimiter>> prof;
  late Future<ProfileLimiter> limit;
  late Map<String, ProfileLimiter> profiles;
  ProfileLimiter? limiter;

  @override
  void initState() {
    prof = updateProfiles();
    limit = updateLimiter();
    super.initState();
  }

  Future<Map<String, ProfileLimiter>> updateProfiles() async {
    return await DatabaseHelper.instance.getProfiles();
  }

  Future<ProfileLimiter> updateLimiter() async {
    return await DatabaseHelper.instance.getLimit(widget.date);
  }

  @override
  Widget build(BuildContext context) {
    return ContainerView(
        colorName: Colors.white,
        width: 350,
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Column(children: [
          FutureBuilder<Map<String, ProfileLimiter>>(
              future: prof,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Colors.green,
                  ));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  profiles = snapshot.data!;
                  return FutureBuilder<ProfileLimiter>(
                      future: limit,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                            color: Colors.green,
                          ));
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else {
                          limiter ??= snapshot.data!;
                          widget.setLimiter(limiter!);

                          return Column(
                            children: [
                              dropdownWidget(),
                              detailsWidget(),
                              const SizedBox(height: 10),
                              switchWidget(),
                              buttonsWidget()
                            ],
                          );
                        }
                      });
                }
              }),
        ]));
  }

  Widget dropdownWidget() {
    return Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: DropdownButton(
            value: (limiter!.profile != 'Default') ? limiter!.profile : null,
            isExpanded: true,
            items: Map.of(profiles).keys.skip(1).map(
              (e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              },
            ).toList(),
            onChanged: (profiles.length != 1 && limiter!.profile != 'Default')
                ? (value) {
                    setState(() {
                      if (limiter!.profile != value) limiter = profiles[value];
                      DatabaseHelper.instance
                          .setDateLimit(widget.date, limiter!.profile);
                    });
                  }
                : null,
            hint: Text(limiter!.profile)));
  }

  Widget detailsWidget() {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        width: 340,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: Column(children: [
          detail('Calories (kcal)', limiter!.calories),
          const Divider(
            color: Colors.grey,
          ),
          detail('Protein (g)', limiter!.protein),
          detail('Carbohydrates (g)', limiter!.carbs),
          detail('Fats (g)', limiter!.fats),
          const Divider(
            color: Colors.grey,
          ),
          detail('Iron (mg)', limiter!.iron),
          detail('Zinc (mg)', limiter!.zinc),
          detail('Vitamin B12 (µg)', limiter!.b12),
          const Divider(
            color: Colors.grey,
          ),
          detail('Price (₱)', limiter!.price),
        ]));
  }

  Widget switchWidget() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const TextDesc(text: 'Use Profile', fontWeight: FontWeight.bold),
      Switch(
        value: (limiter!.profile != 'Default'),
        onChanged: (profiles.length != 1)
            ? (value) {
                setState(() {
                  if (value) {
                    limiter = profiles.values.elementAt(1);
                  } else {
                    limiter = profiles.values.first;
                  }
                  DatabaseHelper.instance
                      .setDateLimit(widget.date, limiter!.profile);
                });
              }
            : null,
        activeColor: Colors.green,
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.black12,
        trackOutlineColor: MaterialStateProperty.all(Colors.white),
      )
    ]);
  }

  Widget buttonsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        button(Icons.delete, Colors.red, () {
          setState(() {
            String oldProfile = limiter!.profile;
            profiles.remove(oldProfile);
            String profile;
            if (profiles.length != 1) {
              profile = profiles.keys.elementAt(1);
            } else {
              profile = profiles.keys.first;
            }
            DatabaseHelper.instance
                .deleteLimit(widget.date, oldProfile, profile);
            limiter = profiles[profile];
          });
        }, limiter!.profile != 'Default'),
        button(Icons.edit, Colors.green, () {
          gotoProfile(limiter);
          limiter = null;
        }, true),
        button(Icons.add, Colors.green, () {
          gotoProfile(null);
        }, profiles.length < 11),
      ],
    );
  }

  void gotoProfile(ProfileLimiter? limiter) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                  limiter: limiter,
                  profiles: profiles,
                ))).then((value) => setState(() {
          prof = updateProfiles();
          if (limiter != null) limit = updateLimiter();
        }));
  }

  Widget button(
      IconData icon, Color backgroundColor, Function() function, bool bool) {
    return ElevatedButton(
      onPressed: bool
          ? () {
              function();
            }
          : null,
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(100, 40)),
      child: Center(
        child: Icon(icon),
      ),
    );
  }

  Widget detail(String detail, double value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextDesc(text: detail),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: TextDesc(
                  text: value.toStringAsFixed(1),
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ));
  }
}
