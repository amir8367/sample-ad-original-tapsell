// lie_detector_flutter_main.dart // اپلیکیشن "دروغ‌سنج" — یک فایل کامل Flutter // توضیحات کوتاه: // - جایگزین کنید: TAPSELL_KEY، BANNER_ZONE_ID، REWARDED_ZONE_ID // - dependencies مورد نیاز در pubspec.yaml: //   tapsell_plus: ^1.0.0 //   connectivity_plus: ^4.0.0 // - این کد برای اندروید/آی‌او‌اس نوشته شده (از dart:io برای بررسی اینترنت استفاده می‌شود)

import 'dart:async'; import 'dart:io'; import 'dart:math';

import 'package:flutter/material.dart'; import 'package:connectivity_plus/connectivity_plus.dart'; import 'package:tapsell_plus/tapsell_plus.dart';

void main() async { WidgetsFlutterBinding.ensureInitialized();

const String TAPSELL_KEY = 'nidhnjdiqidktemidibsjiebfocrhbgktjmccsqktscmittkobkbooqnjlrnnhhtheccgn';

await TapsellPlus.instance.initialize(TAPSELL_KEY); runApp(LieDetectorApp()); }

class LieDetectorApp extends StatelessWidget { @override Widget build(BuildContext context) { return MaterialApp( debugShowCheckedModeBanner: false, title: 'دروغ‌سنج', theme: ThemeData( primarySwatch: Colors.red, fontFamily: 'IRANSans', ), home: StartPage(), ); } }

class StartPage extends StatefulWidget { @override _StartPageState createState() => _StartPageState(); }

class _StartPageState extends State<StartPage> with SingleTickerProviderStateMixin { 
final String bannerZoneId = '68a21cc3e6b8427db138ac02'; final String rewardedZoneId = '68a21c01e6b8427db138ac01'; // ==============================================

late AnimationController _pulseController; bool _connected = false; bool _bannerRequested = false; Timer? _retryTimer;

@override void initState() { super.initState(); _pulseController = AnimationController( vsync: this, duration: Duration(milliseconds: 1200), lowerBound: 0.95, upperBound: 1.06, )..repeat(reverse: true);

_checkInternetAndInit();

}

@override void dispose() { _pulseController.dispose(); _retryTimer?.cancel(); super.dispose(); }

Future<void> _checkInternetAndInit() async { final ok = await _hasInternet(); setState(() => _connected = ok); if (ok) { _loadBannerIfNeeded(); } }

Future<bool> _hasInternet() async { final connectivityResult = await Connectivity().checkConnectivity(); if (connectivityResult == ConnectivityResult.none) return false; try { final result = await InternetAddress.lookup('example.com').timeout(Duration(seconds: 5)); return result.isNotEmpty && result[0].rawAddress.isNotEmpty; } catch () { return false; } }

void _loadBannerIfNeeded() { if (_bannerRequested) return; if (bannerZoneId == '68a21cc3e6b8427db138ac02') {  setState(() => _bannerRequested = true); return; }

try {
  TapsellPlus.instance.showBannerAd(
    zoneId: bannerZoneId,
    bannerSize: TapsellBannerSize.BANNER_320x50,
    onAdOpened: () => print('Banner opened'),
    onAdClosed: () => print('Banner closed'),
    onError: (err) => print('Banner error: \$err'),
    onNoAdAvailable: () => print('Banner not available'),
  );
  setState(() => _bannerRequested = true);
} catch (e) {
  print('banner load exception: \$e');
  setState(() => _bannerRequested = true);
}

}

Future<bool> _showRewardedAd() async { if (rewardedZoneId == '68a21c01e6b8427db138ac01') return false;

final completer = Completer<bool>();

try {
  TapsellPlus.instance.showRewardedVideo(
    zoneId: rewardedZoneId,
    onRewarded: (reward) {
      // کاربر تبلیغ رو دید؛ اجازه ادامه
      if (!completer.isCompleted) completer.complete(true);
    },
    onError: (err) {
      if (!completer.isCompleted) completer.complete(false);
    },
    onNoAdAvailable: () {
      if (!completer.isCompleted) completer.complete(false);
    },
  );

  // safety timeout: اگر در 15 ثانیه پاسخی نیومد، اعلام ناکامی
  Future.delayed(Duration(seconds: 15), () {
    if (!completer.isCompleted) completer.complete(false);
  });

  return await completer.future;
} catch (e) {
  print('showRewarded exception: \$e');
  if (!completer.isCompleted) completer.complete(false);
  return await completer.future;
}

}

void _onStartPressed() async { final ok = await _hasInternet(); if (!ok) { _showNoInternetDialog(); return; }

// نمایش صفحه لودینگ کوچک
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => Center(child: CircularProgressIndicator()),
);

final adOk = await _showRewardedAd();

Navigator.of(context).pop(); // بستن لودر

if (!adOk) {
  // تبلیغ در دسترس نبود یا خطا
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('تبلیغ در دسترس نیست'),
      content: Text('تبلیغ جایزه‌دار در حال حاضر در دسترس نیست. لطفاً بعدا تلاش کنید.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('باشه'))
      ],
    ),
  );
  return;
}

// اگر تبلیغ موفق بود، به صفحه وارد کردن جمله برو
Navigator.of(context).push(MaterialPageRoute(builder: (_) => InputPage(rewardedZoneId: rewardedZoneId)));

}

void showNoInternetDialog() { showDialog( context: context, barrierDismissible: false, builder: () => AlertDialog( title: Text('نیاز به اینترنت'), content: Text('برای استفاده از اپ نیاز به اتصال به اینترنت و توانایی نمایش تبلیغات است.'), actions: [ TextButton( onPressed: () async { Navigator.of(context).pop(); await _checkInternetAndInit(); }, child: Text('تلاش مجدد'), ), ], ), ); }

@override Widget build(BuildContext context) { return Scaffold( backgroundColor: Colors.grey[100], body: SafeArea( child: Column( children: [ Expanded( child: Center( child: ScaleTransition( scale: _pulseController, child: GestureDetector( onTap: _connected ? _onStartPressed : _showNoInternetDialog, child: Container( width: 220, height: 80, decoration: BoxDecoration( color: Colors.red, borderRadius: BorderRadius.circular(18), boxShadow: [ BoxShadow( color: Colors.black26, blurRadius: 12, offset: Offset(0, 6), ), BoxShadow( color: Colors.red.withOpacity(0.2), blurRadius: 24, spreadRadius: 1, ), ], ), child: Center( child: Text( 'شروع', style: TextStyle( color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 8, color: Colors.black26, offset: Offset(0, 4))], ), ), ), ), ), ), ), ),

// فضای تبلیغ بنری پایین صفحه
        Container(
          height: 60,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Center(
            child: Text(
              _bannerRequested ? 'بنر تپسل (نمایش توسط SDK در اندروید/آی‌اواس)' : 'بنر (ZONE_ID را جایگزین کنید)',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    ),
  ),
);

} }

class InputPage extends StatefulWidget { final String rewardedZoneId; InputPage({required this.rewardedZoneId});

@override _InputPageState createState() => _InputPageState(); }

class _InputPageState extends State<InputPage> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _processing = false;

  // ✅ نام متد اصلاح شد: _hasInternet
  Future<bool> _hasInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return false;
    try {
      final result = await InternetAddress.lookup('example.com').timeout(Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _showRewardedAd() async {
    final zone = widget.rewardedZoneId;
    if (zone == 'YOUR_REWARDED_ZONE_ID') return false;

    final completer = Completer<bool>();
    try {
      TapsellPlus.instance.showRewardedVideo(
        zoneId: zone,
        onRewarded: (reward) {
          if (!completer.isCompleted) completer.complete(true);
        },
        onError: (err) {
          if (!completer.isCompleted) completer.complete(false);
        },
        onNoAdAvailable: () {
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      Future.delayed(Duration(seconds: 15), () {
        if (!completer.isCompleted) completer.complete(false);
      });

      return await completer.future;
    } catch (e) {
      print('rewarded show error: $e');
      if (!completer.isCompleted) completer.complete(false);
      return await completer.future;
    }
  }

  void _onNextPressed() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('لطفاً یک جمله وارد کنید')));
      return;
    }

    setState(() => _processing = true);

    final okInternet = await _hasInternet();
    if (!okInternet) {
      setState(() => _processing = false);
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('نیاز به اینترنت'),
          content: Text('برای نمایش تبلیغ نیاز به اینترنت است.'),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('باشه'))],
        ),
      );
      return;
    }

    // لودر
    showDialog(context: context, barrierDismissible: false, builder: (_) => Center(child: CircularProgressIndicator()));

    final adOk = await _showRewardedAd();

    Navigator.of(context).pop(); // بستن لودر

    setState(() => _processing = false);

    if (!adOk) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('تبلیغ موجود نیست'),
          content: Text('تبلیغ جایزه‌دار در دسترس نیست، لطفاً بعداً تلاش کنید.'),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('باشه'))],
        ),
      );
      return;
    }

    // تصمیم شانسی
    final isCorrect = Random().nextBool();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ResultPage(isCorrect: isCorrect)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('جمله را وارد کنید')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'مثال: دیروز به مدرسه نرفتم',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                enabled: !_processing,
              ),
            ),
            SizedBox(height: 18),
            ElevatedButton(
              onPressed: _processing ? null : _onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                elevation: 8,
                shadowColor: Colors.black45,
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('بعدی', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}


