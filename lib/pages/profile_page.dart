import 'package:flutter/material.dart';
import 'package:healthink/database/database_helper.dart';
import 'package:healthink/widgets/text_header.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, ProfileLimiter> profiles;
  final ProfileLimiter? limiter;
  const ProfilePage({super.key, required this.limiter, required this.profiles});

  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final formKey = GlobalKey<FormState>();
  late ProfileLimiter? limiter;
  late TextEditingController profile;
  late TextEditingController calories;
  late TextEditingController protein;
  late TextEditingController carbs;
  late TextEditingController fats;
  late TextEditingController iron;
  late TextEditingController zinc;
  late TextEditingController b12;
  late TextEditingController price;

  @override
  void initState() {
    limiter = widget.limiter;
    profile = TextEditingController(
        text: (limiter == null) ? 'Profile' : limiter?.profile);
    calories = TextEditingController(text: getValue(2175, limiter?.calories));
    protein = TextEditingController(text: getValue(68, limiter?.protein));
    carbs = TextEditingController(text: getValue(339.8, limiter?.carbs));
    fats = TextEditingController(text: getValue(60.4, limiter?.fats));
    iron = TextEditingController(text: getValue(19.5, limiter?.iron));
    zinc = TextEditingController(text: getValue(5.5, limiter?.zinc));
    b12 = TextEditingController(text: getValue(2.4, limiter?.b12));
    price = TextEditingController(text: getValue(500, limiter?.price));
    super.initState();
  }

  String? getValue(double def, double? value) {
    return (limiter == null) ? def.toString() : value!.toStringAsFixed(1);
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
        bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8),
            child: FloatingActionButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  String profileText = profile.text.trimLeft();
                  ProfileLimiter limiter = ProfileLimiter(
                      profile: profileText,
                      calories: double.parse(calories.text),
                      protein: double.parse(protein.text),
                      carbs: double.parse(carbs.text),
                      fats: double.parse(fats.text),
                      iron: double.parse(iron.text),
                      zinc: double.parse(zinc.text),
                      b12: double.parse(b12.text),
                      price: double.parse(price.text));
                  if (this.limiter == null) {
                    DatabaseHelper.instance.addProfile(limiter);
                  } else {
                    DatabaseHelper.instance.updateProfile(profileText, limiter);
                  }
                  widget.profiles[profileText] = limiter;
                  Navigator.pop(context);
                }
              },
              backgroundColor: Colors.green,
              child: const Center(
                child: TextHeader(text: 'Save', color: Colors.white),
              ),
            )),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextHeader(
                        text: (limiter == null)
                            ? "Add New Profile"
                            : "Edit Profile",
                        color: Colors.green,
                      ),
                      form(profile, "Text", 'Profile Name', (value) {
                        if (value!.trimLeft().isEmpty) {
                          return "Profile name is empty";
                        }
                        if ((limiter == null &&
                                widget.profiles.containsKey(value)) ||
                            (limiter != null) &&
                                widget.profiles.containsKey(value) &&
                                limiter?.profile != value) {
                          return "Profile already exists";
                        }
                        if (!RegExp(r'^[a-z A-Z 0-9 ()]+$').hasMatch(value)) {
                          return "Invalid profile name";
                        }
                        if (value.length > 30) {
                          return "Profile name length is too long";
                        }
                        return null;
                      }, (limiter == null), TextInputType.text),
                      const SizedBox(height: 20),
                      numberForm(calories, 'Calories (kcal)'),
                      numberForm(protein, 'Protein (g)'),
                      numberForm(carbs, 'Carbohydrates (g)'),
                      numberForm(fats, 'Fats (g)'),
                      const SizedBox(height: 20),
                      numberForm(iron, 'Iron (mg)'),
                      numberForm(zinc, 'Zinc (mg)'),
                      numberForm(b12, 'Vitamin B12 (μg)'),
                      const SizedBox(height: 20),
                      numberForm(price, 'Price (₱)'),
                      const SizedBox(height: 30),
                      const SizedBox(height: 10),
                    ],
                  )),
            )));
  }

  Widget numberForm(TextEditingController controller, String labelText) {
    return form(controller, "Number", labelText, (value) {
      double? number = double.tryParse(value!);
      if (number == null) return "Invalid number";
      if (number <= 0) return "Number is below 0";
      if (number > 5000) return "Number is above 5000";

      return null;
    }, true, TextInputType.number);
  }

  Widget form(
      TextEditingController controller,
      String hintText,
      String labelText,
      String? Function(String?)? validator,
      bool enabled,
      TextInputType textInputType) {
    return TextFormField(
      selectionControls: EmptyTextSelectionControls(),
      controller: controller,
      cursorColor: Colors.lightGreen,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        enabled: enabled,
        labelStyle: const TextStyle(
            color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
        border: const UnderlineInputBorder(),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.lightGreen),
        ),
      ),
      validator: validator,
      keyboardType: textInputType,
    );
  }
}
