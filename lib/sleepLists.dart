import 'package:babytracker/sleepDetails.dart';
import 'package:babytracker/sleepPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'sleep.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("\n\nConnected to Firebase App\n\n");

  runApp(const SleepList());
}

class SleepList extends StatelessWidget {
  const SleepList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SleepModel(),
      child: MaterialApp(
        title: 'Baby Tracker',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const MyHomePage(title: 'Sleep History'),
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
  List<Sleep> displayedItems = [];

  @override
  void initState() {
    super.initState();
    final sleepModel = Provider.of<SleepModel>(context, listen: false);
    displayedItems = sleepModel.items;
  }

  void filterItems(String query) {
    final sleepModel = Provider.of<SleepModel>(context, listen: false);
    final List<Sleep> allItems = sleepModel.items;
    setState(() {
      displayedItems = allItems.where((sleep) {
        return (query != null &&
                DateFormat('yyyy-MM-dd hh:mm a')
                    .format(sleep.timeSlept)
                    .contains(query)) ||
            (query != null &&
                DateFormat('yyyy-MM-dd hh:mm a')
                    .format(sleep.timeWalkup)
                    .contains(query));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepModel>(
      builder: (_, sleepModel, __) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const SleepPage();
                },
              );
            },
          ),
          title: Text(widget.title),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SleepPage()),
            );
          },
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: filterItems,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                  ),
                ),
              ),
              if (sleepModel.loading)
                const CircularProgressIndicator()
              else
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (_, index) {
                      final sleep = displayedItems[index];
                      return Dismissible(
                        key: ValueKey<String>(sleep.id),
                        direction: DismissDirection.startToEnd,
                        confirmDismiss: (DismissDirection direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: const Text(
                                    'Are you sure you want to delete this item?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('CANCEL'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('DELETE'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (DismissDirection direction) {
                          if (direction == DismissDirection.startToEnd) {
                            setState(() {
                              sleepModel.delete(sleep.id);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Item deleted.'),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  onPressed: () {
                                    setState(() {
                                      // Add logic to undo the deletion here
                                    });
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: ListTile(
                          title: Row(
                            children: [
                              Text(
                                'TimeSlept: ${DateFormat('yyyy-MM-dd hh:mm a').format(sleep.timeSlept)}',
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SleepDetails(id: sleep.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    itemCount: displayedItems.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
