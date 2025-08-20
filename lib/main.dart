import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tapsell_plus/tapsell_plus.dart';

void main() {
  runApp(const LieDetectorApp());
}

class LieDetectorApp extends StatelessWidget {
  const LieDetectorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: const StartPage(),
    );
  }
}

// ---------------- صفحه شروع ----------------
class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  void initState() {
    super.initState();
    // Init Tapsell SDK
    TapsellPlus.instance.initialize(
        "nidhnjdiqidktemidibsjiebfocrhbgktjmccsqktscmittkobkbooqnjlrnnhhtheccgn");
  }

  void _showRewardedAd() async {
    String zoneId = "68a21c01e6b8427db138ac01";

    TapsellPlus.instance
        .requestAd(zoneId, TapsellPlusAdRequestOptions())
        .then((responseId) {
      TapsellPlus.instance.showAd(responseId,
          onOpened: () {
            debugPrint("Ad opened");
          },
          onClosed: (bool completed) {
            if (completed) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckPage()),
              );
            }
          },
          onError: (message) {
            debugPrint("Error: $message");
          });
    }).catchError((e) {
      debugPrint("RequestAd error: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: GestureDetector(
              onTap: _showRewardedAd,
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent,
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "شروع",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          const TapsellPlusBanner(
            zoneId: "68a21cc3e6b8427db138ac02",
            bannerType: TapsellPlusBannerType.BANNER_320x50,
          ),
        ],
      ),
    );
  }
}

// ---------------- صفحه بررسی ----------------
class CheckPage extends StatelessWidget {
  const CheckPage({Key? key}) : super(key: key);

  void _goToResult(BuildContext context) {
    bool isTrue = Random().nextBool();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultPage(isTrue: isTrue)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "مثال: دیروز من به مدرسه نرفتم",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _goToResult(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "بررسی",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const Spacer(),
          const TapsellPlusBanner(
            zoneId: "68a21cc3e6b8427db138ac02",
            bannerType: TapsellPlusBannerType.BANNER_320x50,
          ),
        ],
      ),
    );
  }
}

// ---------------- صفحه نتیجه ----------------
class ResultPage extends StatelessWidget {
  final bool isTrue;
  const ResultPage({Key? key, required this.isTrue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: isTrue ? Colors.lime : Colors.red,
        child: Center(
          child: Text(
            isTrue ? "راست" : "دروغ بزرگ",
            style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 6,
                  color: Colors.black38,
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const TapsellPlusBanner(
        zoneId: "68a21cc3e6b8427db138ac02",
        bannerType: TapsellPlusBannerType.BANNER_320x50,
      ),
    );
  }
}