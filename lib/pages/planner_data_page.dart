import 'package:flutter/material.dart';
import 'package:healthink/database/database_helper.dart';
import 'package:healthink/widgets/text_header.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PlannerDataPage extends StatefulWidget {
  final String date;
  final List<MealPlanner> mealPlanners;
  const PlannerDataPage(
      {super.key, required this.date, required this.mealPlanners});

  @override
  State<StatefulWidget> createState() => PlannerPageState();
}

class PlannerPageState extends State<PlannerDataPage> {
  int index = 0;
  List<Widget> pages = [];

  @override
  void initState() {
    pages = [
      PlannerChartPage(date: widget.date, mealPlanners: widget.mealPlanners),
      const InformationPage()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Healthink"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
      ),
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      backgroundColor: const Color.fromARGB(255, 240, 236, 236),
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.green,
          onTap: (value) {
            setState(() {
              index = value;
            });
          },
          currentIndex: index,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: "Progress",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: "Information",
            ),
          ]),
    );
  }
}

class PlannerChartPage extends StatelessWidget {
  final String date;
  final int mealSize;
  final List<MealPlanner> mealPlanners;
  const PlannerChartPage(
      {super.key, required this.date, required this.mealPlanners})
      : mealSize = mealPlanners.length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
            child: FutureBuilder<ProfileLimiter>(
                future: DatabaseHelper.instance.getLimit(date),
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
                    ProfileLimiter limiter = snapshot.data!;
                    ProgressPlanner planner =
                        DatabaseHelper.instance.getProgress(mealPlanners, date);
                    List<PieData> macro = [
                      PieData('Protein', 'g', planner.protein,
                          const Color.fromARGB(255, 101, 131, 84)),
                      PieData('Carbohydrates', 'g', planner.carbs,
                          const Color.fromARGB(255, 117, 151, 94)),
                      PieData('Fats', 'g', planner.fats,
                          const Color.fromARGB(255, 135, 171, 105)),
                    ];
                    List<PieData> micro = [
                      PieData('Iron', 'mg', planner.iron,
                          const Color.fromARGB(255, 101, 131, 84)),
                      PieData('Zinc', 'mg', planner.zinc,
                          const Color.fromARGB(255, 117, 151, 94)),
                      PieData('Vitamin B12', 'µg', planner.b12,
                          const Color.fromARGB(255, 135, 171, 105)),
                    ];
                    List<BarData> bar = [
                      BarData('Price', '₱', planner.price, limiter.price),
                      BarData('Vitamin\nB12', 'µg', planner.b12, limiter.b12),
                      BarData('Iron', 'mg', planner.iron, limiter.iron),
                      BarData('Fats', 'g', planner.fats, limiter.fats),
                      BarData('Carbs.', 'g', planner.carbs, limiter.carbs),
                      BarData('Protein', 'g', planner.protein, limiter.protein),
                      BarData('Calories', 'kcal', planner.calories,
                          limiter.calories),
                    ];
                    return (mealSize == 0)
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                SizedBox(height: 200),
                                Icon(
                                  Icons.no_meals_outlined,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                                Text(
                                  'No meals found in the meal planner!',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 30,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ])
                        : Column(
                            children: [
                              detail('Calories',
                                  '${planner.calories.toStringAsFixed(1)} kcal'),
                              detail('Price',
                                  '₱${planner.price.toStringAsFixed(1)}'),
                              donutChart('Macronutrients', macro),
                              donutChart('Micronutrients', micro),
                              const SizedBox(height: 20),
                              barChart(bar),
                              const SizedBox(height: 20),
                            ],
                          );
                  }
                })));
  }

  Widget detail(String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Text(
              '$label: ',
              style: const TextStyle(fontSize: 25),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 25, color: Colors.green),
            )
          ],
        ));
  }

  Widget donutChart(String title, List<PieData> data) {
    double total = 0;
    for (var item in data) {
      total += item.value;
    }
    return Stack(children: [
      SfCircularChart(
        title: ChartTitle(text: '$title Chart'),
        legend: const Legend(
            isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
        series: <CircularSeries>[
          DoughnutSeries<PieData, String>(
            dataSource: data,
            xValueMapper: (PieData data, _) => data.detail,
            yValueMapper: (PieData data, _) => data.value,
            pointColorMapper: (PieData data, _) => data.color,
            dataLabelMapper: (PieData data, _) =>
                '${data.value.toStringAsFixed(1)} ${data.unit}',
            dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(fontSize: 15, color: Colors.black),
                labelPosition: ChartDataLabelPosition.outside),
          ),
        ],
      ),
      SfCircularChart(
        title: ChartTitle(text: '$title Chart'),
        legend: const Legend(
            isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
        series: <CircularSeries>[
          DoughnutSeries<PieData, String>(
            dataSource: data,
            xValueMapper: (PieData data, _) => data.detail,
            yValueMapper: (PieData data, _) => data.value,
            pointColorMapper: (PieData data, _) => data.color,
            dataLabelMapper: (PieData data, _) =>
                '${(data.value / total * 100).toStringAsFixed(1)}%',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(fontSize: 13, color: Colors.white),
              labelPosition: ChartDataLabelPosition.inside,
              labelIntersectAction: LabelIntersectAction.hide,
            ),
          ),
        ],
      ),
    ]);
  }

  Widget barChart(List<BarData> data) {
    return SizedBox(
        width: 400,
        height: 600,
        child: SfCartesianChart(
          title: const ChartTitle(text: 'Progress Graph'),
          primaryXAxis: const CategoryAxis(),
          primaryYAxis:
              const NumericAxis(minimum: 0, maximum: 100, interval: 10),
          series: <CartesianSeries>[
            BarSeries<BarData, String>(
              dataSource: data,
              width: 0.8,
              xValueMapper: (BarData data, _) => data.detail,
              yValueMapper: (BarData data, _) => data.percent,
              pointColorMapper: (BarData data, _) =>
                  (data.value <= data.limit) ? Colors.green : Colors.red,
              dataLabelMapper: (BarData data, _) =>
                  '${data.value.toStringAsFixed(1)}/${data.limit.toStringAsFixed(1)} (${data.unit})\n${data.percent.toStringAsFixed(1)}%',
              dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(fontSize: 13),
                  labelPosition: ChartDataLabelPosition.inside),
            ),
          ],
        ));
  }
}

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  State<StatefulWidget> createState() => InformationPageState();
}

class InformationPageState extends State<InformationPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 10),
              const TextHeader(text: 'Macronutrients'),
              rect(
                  Column(
                    children: [
                      nutrientsDesc('Protein', '''
Protein is made up of lengthy chains of molecules known as amino acids. They are vital to the cellular growth, development, maintenance, and repair of bodily tissues.

Every bodily cell contains protein, and maintaining the health of the muscles, bones, and tissues depends on consuming enough of it. Additionally, protein is essential for many biological activities, including those that nourish and maintain cells, help the immune system, and biochemical reactions.
'''),
                      nutrientsDesc('Carbohydrates', '''
Carbohydrates are a preferred source of energy for several body tissues, and the primary energy source for the brain. The body can break carbohydrates down into glucose, which moves from the bloodstream into the body’s cells and allows them to function.

Carbohydrates are important for muscle contraction during intense exercise. Even at rest, carbohydrates enable the body to perform vital functions such as maintaining body temperature, keeping the heart beating, and digesting food.
'''),
                      nutrientsDesc('Fats', '''
Healthy fats can help the body produce energy and are a vital component of a diet. Although there are health benefits and drawbacks to different types of dietary fats, they are an integral component of the diet and are involved in the synthesis of hormones, cell division, energy storage, and key vitamin absorption.
'''),
                    ],
                  ),
                  0),
              const SizedBox(height: 20),
              const TextHeader(text: 'Micronutrients'),
              rect(
                  Column(
                    children: [
                      nutrientsDesc('Iron', '''
Iron is an essential component for the body's growth and development. Iron is used by your body to produce hemoglobin, a protein found in red blood cells that transports oxygen from the lungs to all areas of the body, and myoglobin, a protein that supplies oxygen to muscles.
'''),
                      nutrientsDesc('Zinc', '''
Zinc plays a role in neurotransmitter activity, synaptic plasticity, and neurogenesis, all of which are critical for learning and memory.
'''),
                      nutrientsDesc('Vitamin B12', '''
Vitamin B12 is required for the development of red blood cells as well as normal nervous system and brain function.
'''),
                    ],
                  ),
                  0),
              const SizedBox(height: 20)
            ])));
  }

  Widget rect(Widget child, double value) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
            padding: EdgeInsets.all(value), color: Colors.white, child: child));
  }

  Widget nutrientsDesc(String nutrient, String desc) {
    return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTileTheme(
            data: const ExpansionTileThemeData(
              iconColor: Colors.green,
              textColor: Colors.green,
              collapsedTextColor: Colors.grey,
            ),
            child: ExpansionTile(
              title: Text(
                nutrient,
                textAlign: TextAlign.justify,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              children: [
                ListTile(
                    title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      desc,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const Divider(
                      color: Colors.grey,
                    )
                  ],
                ))
              ],
            )));
  }
}

class PieData {
  final String detail;
  final String unit;
  final double value;
  final Color color;

  PieData(this.detail, this.unit, this.value, this.color);
}

class BarData {
  final String detail;
  final String unit;
  final double value;
  final double limit;
  final double percent;

  BarData(this.detail, this.unit, this.value, this.limit)
      : percent = (value / limit * 100);
}
