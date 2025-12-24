import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

void main() => runApp(const SpeedUpGlobalUltraApp());

class SpeedUpGlobalUltraApp extends StatelessWidget {
  const SpeedUpGlobalUltraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme: GoogleFonts.orbitronTextTheme(ThemeData.dark().textTheme),
      ),
      home: const GlobalSpeedScreen(),
    );
  }
}

class GlobalSpeedScreen extends StatefulWidget {
  const GlobalSpeedScreen({super.key});

  @override
  State<GlobalSpeedScreen> createState() => _GlobalSpeedScreenState();
}

class _GlobalSpeedScreenState extends State<GlobalSpeedScreen> {
  double _speed = 0.0;
  bool _isTesting = false;
  String _currentLang = 'TH';
  double _progress = 0.0;

  final Map<String, Map<String, String>> _dict = {
    'TH': {'title': 'ความเร็วโลก', 'btn': 'เริ่มทดสอบ', 'status': 'ระบบพร้อม', 'unit': 'Mbps', 'flag': '🇹🇭'},
    'EN': {'title': 'GLOBAL SPEED', 'btn': 'START TEST', 'status': 'READY', 'unit': 'Mbps', 'flag': '🇺🇸'},
    'CN': {'title': '全球速度', 'btn': '开始测试', 'status': '准备就绪', 'unit': 'Mbps', 'flag': '🇨🇳'},
    'JP': {'title': 'グローバル速度', 'btn': 'テスト開始', 'status': '準備完了', 'unit': 'Mbps', 'flag': '🇯🇵'},
    'KR': {'title': '글ือ벌 속도', 'btn': '테스트 시작', 'status': '준비 완료', 'unit': 'Mbps', 'flag': '🇰🇷'},
    'FR': {'title': 'VITESSE GLOBALE', 'btn': 'LANCER', 'status': 'PRÊT', 'unit': 'Mbps', 'flag': '🇫🇷'},
  };

  // --- ส่วนที่แก้ไข: ปรับปรุงระบบวัดความเร็วให้ทำงานได้จริง ---
  Future<void> _startUltraTest() async {
    setState(() { 
      _isTesting = true; 
      _speed = 0.0; 
      _progress = 0.0; 
    });

    try {
      final stopwatch = Stopwatch()..start();
      
      // ใช้ไฟล์ขนาด 10MB จาก Cloudflare เพื่อให้วัดค่าได้แม่นยำและเห็นตัวเลขวิ่งจริงๆ
      final response = await http.get(Uri.parse('https://speed.cloudflare.com/__down?bytes=10485760'))
          .timeout(const Duration(seconds: 30));
          
      stopwatch.stop();

      if (response.statusCode == 200) {
        // คำนวณความเร็ว: (จำนวนบิต / เวลาที่ใช้เป็นวินาที) / 1 ล้าน = Mbps
        double bits = response.bodyBytes.length * 8.0;
        double time = stopwatch.elapsedMilliseconds / 1000.0;
        double mbps = (bits / time) / (1024 * 1024);

        // สร้างแอนิเมชันให้ตัวเลขและวงกลมวิ่งจนถึงค่าที่วัดได้
        for (int i = 0; i <= 100; i++) {
          await Future.delayed(const Duration(milliseconds: 15));
          if (!mounted) return;
          setState(() {
            _progress = i / 100;
            _speed = mbps * (i / 100); 
          });
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
      // หากเกิดข้อผิดพลาด ให้ Reset ค่าเป็น 0
      setState(() => _speed = 0.0);
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var lang = _dict[_currentLang]!;
    return Scaffold(
      backgroundColor: const Color(0xFF010813),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15, top: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/logo.png', 
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.cyanAccent.withOpacity(0.1),
                child: const Center(child: Text("AR", style: TextStyle(fontSize: 10, color: Colors.cyanAccent))),
              ),
            ),
          ),
        ),
        actions: [
          DropdownButton<String>(
            value: _currentLang,
            dropdownColor: const Color(0xFF0A192F),
            underline: const SizedBox(),
            items: _dict.keys.map((String key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text("${_dict[key]!['flag']} $key", style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (val) => setState(() => _currentLang = val!),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(lang['title']!, style: GoogleFonts.blackOpsOne(fontSize: 26, color: Colors.cyanAccent, letterSpacing: 2)),
            
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.cyanAccent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "VER: ARMisses-ULTRA",
                style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.black),
              ),
            ),
            
            const Spacer(),
            
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 300, height: 300,
                  child: CircularProgressIndicator(
                    value: _isTesting ? null : _progress,
                    strokeWidth: 12,
                    color: Colors.cyanAccent,
                    backgroundColor: Colors.white10,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // แสดงตัวเลขความเร็วทศนิยม 1 ตำแหน่ง
                    Text(_speed.toStringAsFixed(1), style: const TextStyle(fontSize: 85, fontWeight: FontWeight.bold)),
                    Text(lang['unit']!, style: const TextStyle(fontSize: 20, color: Colors.cyanAccent, letterSpacing: 3)),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            Text(_isTesting ? "TESTING..." : lang['status']!, style: const TextStyle(color: Colors.white38, letterSpacing: 2)),
            const Spacer(),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: GestureDetector(
                onTap: _isTesting ? null : _startUltraTest,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _isTesting ? Colors.white10 : Colors.cyanAccent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      if (!_isTesting) BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _isTesting ? "PROCESSING..." : lang['btn']!,
                      style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}