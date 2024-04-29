import 'package:flutter/material.dart';
import 'package:healthink/database/food_menu.dart';
import 'package:healthink/pages/menu_page.dart';
import 'package:healthink/widgets/text_header.dart';

class FoodPageBody extends StatefulWidget {
  final int category;
  final Function(FoodMenuBody body, int index) onClick;
  const FoodPageBody(
      {super.key, required this.category, required this.onClick});

  @override
  State<StatefulWidget> createState() => _FoodPageBodyState();
}

class _FoodPageBodyState extends State<FoodPageBody> {
  PageController pageController = PageController(viewportFraction: 0.85);
  int position = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        height: 140,
        child: PageView.builder(
            itemCount: FoodMenu.menu[widget.category]!.length,
            controller: pageController,
            itemBuilder: (context, position) {
              return _buildPageItem(position);
            }));
  }

  Widget _buildPageItem(int index) {
    FoodMenuBody body = FoodMenu.menu[widget.category]!.values.elementAt(index);
    return GestureDetector(
        onTap: () {
          setState(() {
            position = index;
            widget.onClick(body, position);
          });
        },
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            color: (position == index) ? Colors.green : Colors.white,
            child: Stack(children: [
              Container(
                  height: 130,
                  width: 350,
                  margin: const EdgeInsets.only(top: 5, left: 5, right: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.red,
                      image: DecorationImage(
                          fit: BoxFit.cover, image: body.image))),
              Container(
                margin: const EdgeInsets.only(left: 10, top: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                ),
                child: TextHeader(
                    text:
                        FoodMenu.menu[widget.category]!.keys.elementAt(index)),
              )
            ])));
  }
}
