import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tapsell_plus/tapsell_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // مقداردهی اولیه تپسل
  await TapsellPlus.instance.initialize(
    "nidhnjdiqidktemidibsjiebfocrhbgktjmccsqktscmittkobkbooqnjlrnnhhtheccgn", // AppKey
  );

  runApp(const LieDetectorApp());
}

class LieDetectorApp extends StatelessWidget {
  const LieDetectorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  String? responseId;

  void _loadAdAndStart() async {
    // درخواست تبلیغ جایزه‌دار
    responseId = await TapsellPlus.instance.requestRewardedVideoAd(
      "68a21c01e6b8427db138ac01", // Zone ID جایزه‌دار
    );

    if (responseId != null) {
      TapsellPlus.instance.showRewardedVideoAd(
        responseId!,
        onOpened: (map) => print("Ad opened"),
        onClosed: (map) {
          print("Ad closed: $map");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CheckPage()),
          );
        },
        onError: (map) {
          print("Ad error: $map");
          // اگه تبلیغ نیومد مستقیم بره
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CheckPage()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: _loadAdAndStart,
          child: Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent,
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "شروع",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),

      // --- تبلیغ بنری پایین صفحه ---
      bottomNavigationBar: SizedBox(
        height: 60,
        child: FutureBuilder<Widget>(
          future: TapsellPlus.instance.showStandardBannerAd(
            "68a21cc3e6b8427db138ac02", // Zone ID بنری
            TapsellPlusBannerType.BANNER_320x50,
            TapsellPlusHorizontalGravity.BOTTOM,
            TapsellPlusVerticalGravity.CENTER,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return snapshot.data!;
            }
            return const SizedBox(); // تا وقتی نیومده چیزی نشون نده
          },
        ),
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
                boxShadow: const [
                  BoxShadow(
                    color: Colors.redAccent,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
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
        ],
      ),

      // تبلیغ بنری پایین
      bottomNavigationBar: SizedBox(
        height: 60,
        child: FutureBuilder<Widget>(
          future: TapsellPlus.instance.showStandardBannerAd(
            "68a21cc3e6b8427db138ac02",
            TapsellPlusBannerType.BANNER_320x50,
            TapsellPlusHorizontalGravity.BOTTOM,
            TapsellPlusVerticalGravity.CENTER,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return snapshot.data!;
            }
            return const SizedBox();
          },
        ),
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
      backgroundColor: isTrue ? Colors.green : Colors.red,
      body: Center(
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

      // تبلیغ بنری پایین
      bottomNavigationBar: SizedBox(
        height: 60,
        child: FutureBuilder<Widget>(
          future: TapsellPlus.instance.showStandardBannerAd(
            "68a21cc3e6b8427db138ac02",
            TapsellPlusBannerType.BANNER_320x50,
            TapsellPlusHorizontalGravity.BOTTOM,
            TapsellPlusVerticalGravity.CENTER,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return snapshot.data!;
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}