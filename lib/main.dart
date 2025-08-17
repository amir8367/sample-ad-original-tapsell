 import 'package:flutter/material.dart';
import 'package:tapsell_plus/tapsell_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TapsellPlus.instance.initialize('stahdibipprbjgjkcqsfbkojamsajbrttnlirhrgjaegttjfjcdotbbcmtphpsihiilgdq');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? responseId; // شناسه تبلیغی که گرفتیم

  void loadAd() async {
    // درخواست تبلیغ
    responseId = await TapsellPlus.instance
        .requestRewardedVideoAd("688a18c01222dc68586555a7");
    setState(() {}); // بروز رسانی صفحه
  }

  void showAd() {
    if (responseId != null) {
      TapsellPlus.instance.showRewardedVideoAd(responseId!,
          onOpened: (map) {
            print("تبلیغ باز شد");
          }, onError: (map) {
            print("خطا در نمایش تبلیغ");
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تبلیغات تپسل ساده")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: loadAd,
              child: Text("درخواست تبلیغ"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: showAd,
              child: Icon(
                Icons.slideshow,color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}