import 'package:babytracker/medicinePage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Medicine.dart';
import 'medicine_details.dart';

// Theme colors matching MainPage
const Color kDarkBg1 = Color(0xFF2A2A2A);
const Color kDarkBg2 = Color(0xFF1F1F1F);
const Color kLightPink = Color(0xFFFFB6C1);
const Color kDeepPink = Color(0xFFFF69B4);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("\n\nConnected to Firebase App ${app.options.projectId}\n\n");

  runApp(const MedicineHistroyList());
}

class MedicineHistroyList extends StatelessWidget {
  const MedicineHistroyList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MedicineModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'History List',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: kDarkBg1,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            foregroundColor: Colors.white,
          ),
        ),
        home: const MyHomePage(title: 'Medicine History'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController searchController = TextEditingController();
  List<Medicine> displayedItems = [];

  @override
  void initState() {
    super.initState();
    final medicineModel = Provider.of<MedicineModel>(context, listen: false);
    displayedItems = medicineModel.items;
  }

  void filterItems(String query) {
    final medicineModel = Provider.of<MedicineModel>(context, listen: false);
    final allItems = medicineModel.items;
    setState(() {
      displayedItems = allItems.where((medicine) {
        return (query.isEmpty || medicine.amount.toString().contains(query)) ||
            DateFormat('yyyy-MM-dd hh:mm a')
                .format(medicine.Time)
                .contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final medicineModel = Provider.of<MedicineModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: kLightPink,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MedicinePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: filterItems,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: kDarkBg2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (medicineModel.loading)
            const CircularProgressIndicator()
          else
            Expanded(
              child: ListView.builder(
                itemCount: displayedItems.length,
                itemBuilder: (context, index) {
                  final medicine = displayedItems[index];
                  return Dismissible(
                    key: ValueKey<String>(medicine.id),
                    direction: DismissDirection.startToEnd,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: const Text(
                              'Are you sure you want to delete this item?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('DELETE'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) {
                      medicineModel.delete(medicine.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Item deleted.'),
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () {
                              // You could implement undo logic here
                            },
                          ),
                        ),
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kDarkBg2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(
                              '${medicine.amount} ${medicine.measure}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('yyyy-MM-dd hh:mm a')
                                  .format(medicine.Time),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MedicineDetails(id: medicine.id),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
