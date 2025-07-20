import 'package:babytracker/bottlePage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Bottle.dart';
import 'bottleDetails.dart';
import 'firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("\n\nConnected to Firebase App ${app.options.projectId}\n\n");

  runApp(const BottleHistoryList());
}

class BottleHistoryList extends StatelessWidget {
  const BottleHistoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BottleModel(),
      child: MaterialApp(
        title: 'History List',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const MyHomePage(title: 'History List'),
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
  List<Bottle> displayedItems = [];

  @override
  void initState() {
    super.initState();
    final bottleModel = Provider.of<BottleModel>(context, listen: false);
    displayedItems = bottleModel.items;
  }

  void filterItems(String query) {
    final bottleModel = Provider.of<BottleModel>(context, listen: false);
    final List<Bottle> allItems = bottleModel.items;
    setState(() {
      displayedItems = allItems.where((bottle) {
        return (query == null || bottle.amount.toString().contains(query)) ||
            (query != null &&
                DateFormat('yyyy-MM-dd hh:mm a').format(bottle.Time).contains(query));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BottleModel>(
      builder: (context, bottleModel, _) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const BottlePage();
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
              MaterialPageRoute(builder: (context) => const BottlePage()),
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
              if (bottleModel.loading)
                const CircularProgressIndicator()
              else
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (_, index) {
                      var bottle = displayedItems[index];
                      return Dismissible(
                        key: ValueKey<String>(bottle.id),
                        direction: DismissDirection.startToEnd,
                        confirmDismiss: (DismissDirection direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: const Text('Are you sure you want to delete this item?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('CANCEL'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
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
                              bottleModel.delete(bottle.id);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Item deleted.'),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  onPressed: () {
                                    setState(() {
                                      //
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
                              Text(bottle.amount.toString() + bottle.measure.toString()),
                              const Spacer(),
                              Text(
                                "Date: ${DateFormat('yyyy-MM-dd hh:mm a').format(bottle.Time)}",
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return BottleDetails(id: bottle.id);
                                },
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
