import 'package:flutter/material.dart';

import 'package:lenpay/ui/main/notifications.dart';
import 'package:lenpay/ui/main/widget/card_icon.dart';
import 'package:lenpay/ui/main/widget/operations.dart';
import 'package:lenpay/ui/main/widget/offer.dart';
import 'package:lenpay/ui/submain_page/edit_profile.dart';
import 'package:lenpay/widget/card.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leadingWidth: 150,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  letterSpacing: 1,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                children: const [
                  TextSpan(
                    text: "Len",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                  TextSpan(
                    text: "Pay",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfile()),
              );
            },
            icon: Image.asset("assets/images/user.png", width: 20, height: 20),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notifications()),
              );
            },
            icon: Image.asset(
              "assets/images/notification.png",
              width: 20,
              height: 20,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // أضف كود التحديث (Refresh) هنا
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: const [CardBank(), CardIcon(), Offer(), Operations()],
          ),
        ),
      ),
    );
  }
}
