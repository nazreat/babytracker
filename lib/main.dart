import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'feedPage.dart';
import 'sleepPage.dart';
import 'medicinePage.dart';
import 'nappyChangePage.dart';

/// Pastel‑pink on dark backdrop
const Color kDarkBg1 = Color(0xFF2A2A2A);
const Color kDarkBg2 = Color(0xFF1F1F1F);
const Color kLightPink = Color(0xFFFFB6C1);
const Color kDeepPink = Color(0xFFFF69B4);

/// Dummy data
final List<double> feedCounts = [1, 2, 1, 3, 2, 1, 0]; // feeds per hour
final String nextEvent = 'Feed at 12:00 PM';
final List<String> recentEvents = [
  'Fed at 10:15 AM',
  'Nap 9:00–10:20 AM',
  'Medicine at 8:00 AM',
  'Nappy change at 7:30 AM',
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabyTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: kDarkBg1,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const _Dashboard(),
    const FeedPage(),
    const SleepPage(),
    const MedicinePage(),
    const NappyChangePage(),
  ];

  static const _labels = ['Home', 'Feed', 'Sleep', 'Medicine', 'Nappy'];
  static const _icons = [
    Icons.home,
    Icons.baby_changing_station,
    Icons.nights_stay,
    Icons.medical_services,
    Icons.child_care,
  ];

  void _onItemTapped(int idx) => setState(() => _selectedIndex = idx);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: _selectedIndex == 0
            ? const Text('BabyTracker')
            : Text(_labels[_selectedIndex]),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kDarkBg1,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kDeepPink,
        unselectedItemColor: Colors.white54,
        items: List.generate(
            _labels.length,
            (i) => BottomNavigationBarItem(
                  icon: Icon(_icons[i]),
                  label: _labels[i],
                )),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// Updated dashboard with Upcoming Alert, Sparkline, and Timeline
class _Dashboard extends StatelessWidget {
  const _Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Background gradient
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kDarkBg1, kDarkBg2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      // Bubbles
      Positioned(
        top: -60,
        left: -60,
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kLightPink.withOpacity(0.2),
          ),
        ),
      ),
      Positioned(
        bottom: -100,
        right: -100,
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kDeepPink.withOpacity(0.15),
          ),
        ),
      ),
      // Content
      Padding(
        padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 32, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) Upcoming Alert card
            Card(
              color: kDarkBg2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.notifications, color: kLightPink),
                title: const Text('Next Event',
                    style: TextStyle(color: Colors.white)),
                subtitle: Text(nextEvent,
                    style: const TextStyle(color: Colors.white70)),
              ),
            ),

            const SizedBox(height: 16),

            // 2) Progress Chart sparkline
            const Text('Today’s Feeds',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: feedCounts.map((v) {
                  // map value to bar height
                  final barHeight = v * 15;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // 3) Recent Activity timeline
            const Text('Recent Activity',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: recentEvents.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Colors.white12),
                itemBuilder: (context, i) {
                  final txt = recentEvents[i];
                  IconData icon;
                  if (txt.startsWith('Fed'))
                    icon = Icons.local_drink;
                  else if (txt.startsWith('Nap'))
                    icon = Icons.nights_stay;
                  else if (txt.startsWith('Medicine'))
                    icon = Icons.medical_services;
                  else
                    icon = Icons.child_care;

                  return ListTile(
                    leading: Icon(icon, color: kLightPink),
                    title:
                        Text(txt, style: const TextStyle(color: Colors.white)),
                    dense: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
