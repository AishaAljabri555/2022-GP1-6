import 'dart:async';

import 'package:flutter/material.dart';
import 'package:untitled_design/app/modules/user/screens/categories.dart';

import '../../../../styles/styles.dart';
import '../../../../widgets/widgets.dart';

class SendCircumstances extends StatefulWidget {
  const SendCircumstances({Key? key}) : super(key: key);

  @override
  State<SendCircumstances> createState() => _SendCircumstancesState();
}

class _SendCircumstancesState extends State<SendCircumstances> {
  int _start = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomColors.backgroundColor,
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            'Help Me',
            style: TextStyle(
              color: CustomColors.pageNameAndBorderColor,
              fontWeight: FontWeight.bold,
              fontFamily: CustomFonts.sitkaFonts,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.s16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Your location and situation will be sent to your contacts within',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: CustomFonts.sitkaFonts,
                  color: CustomColors.pageContentColor1,
                  fontSize: Sizes.sPageContent,
                ),
              ),
              const SizedBox(height: Sizes.s24),
              Text('00:0$_start'),
              const SizedBox(height: Sizes.s24),
              CustomElevatedButton(
                height: Sizes.s40,
                width: Sizes.s96,
                onPressed: () => Navigator.pop(context),
                title: 'Cancel',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startTimer() {
    const sec = Duration(seconds: 1);
    _timer = Timer.periodic(
      sec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Categories(text: 'Help Me'),
            ),
          );
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }
}
