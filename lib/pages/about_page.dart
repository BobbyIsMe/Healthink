import 'package:flutter/material.dart';
import 'package:healthink/widgets/text_desc.dart';
import 'package:healthink/widgets/text_header.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<StatefulWidget> createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Image.asset('assets/icon_about.png', height: 200)),
              const SizedBox(height: 10),
              const TextHeader(text: 'About'),
              rect(
                  const Text(
                    '''Healthink is a mobile application that's designed to guide users in creating their own nutrition planner through informing them the accurate nutritional label of each food in the menu that they need for a balanced meal.
                      ''',
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 15),
                  ),
                  double.infinity,
                  8),
              const SizedBox(height: 20),
              const TextHeader(text: 'Research Team'),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    rect(
                        member('roy', 'Roy Dennis M. Patalinghug',
                            'Research Leader'),
                        270,
                        4),
                    const SizedBox(height: 20),
                    rect(member('zev', 'Zev A. Torrentira', 'Assistant Leader'),
                        270, 4),
                    const SizedBox(height: 20),
                    rect(member('shem', 'Shem Nathan R. Meca', 'Member'), 270,
                        4),
                    const SizedBox(height: 20),
                    rect(member('kat', 'Iesha Katriel P. Ruiz', 'Member'), 270,
                        4),
                    const SizedBox(height: 20),
                    rect(
                        member('jude', 'Jude Ryan O. Tapia', 'Member'), 270, 4),
                    const SizedBox(height: 20),
                  ],
                ),
              )
            ])));
  }

  Widget member(String member, String name, String desc) {
    return rect(
        Column(
          children: [
            Image.asset('assets/team/$member.png', height: 150),
            TextHeader(
              text: name,
            ),
            TextDesc(
              text: desc,
              color: Colors.grey,
            ),
          ],
        ),
        270,
        4);
  }

  Widget desc(String name, String desc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            TextHeader(
              text: name,
            ),
            TextDesc(
              text: desc,
              color: Colors.grey,
            ),
          ],
        )
      ],
    );
  }

  Widget rect(Widget child, double width, double value) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
            width: width,
            padding: EdgeInsets.all(value),
            color: Colors.white,
            child: child));
  }
}
