import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'feed.dart';
import 'feedingDetails.dart';

/// Your main page colors
const Color kDarkBg1 = Color(0xFF2A2A2A);
const Color kDarkBg2 = Color(0xFF1F1F1F);
const Color kLightPink = Color(0xFFFFB6C1);
const Color kDeepPink = Color(0xFFFF69B4);

class FeedingHistoryList extends StatelessWidget {
  const FeedingHistoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedModel(),
      child: const _FeedingHistoryView(),
    );
  }
}

class _FeedingHistoryView extends StatefulWidget {
  const _FeedingHistoryView();

  @override
  State<_FeedingHistoryView> createState() => _FeedingHistoryViewState();
}

class _FeedingHistoryViewState extends State<_FeedingHistoryView> {
  List<Feed> _displayed = [];

  @override
  void initState() {
    super.initState();
    final model = Provider.of<FeedModel>(context, listen: false);
    _displayed = model.items;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedModel>(builder: (context, model, _) {
      return Scaffold(
        backgroundColor: kDarkBg1,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: kLightPink,
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('History', style: TextStyle(color: Colors.white)),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 239, 52, 145),
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const FeedDetails(id: null)),
            );
          },
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: model.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemCount: _displayed.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white12),
                  itemBuilder: (context, i) {
                    final f = _displayed[i];
                    final timeTxt =
                        DateFormat('yyyy-MM-dd hh:mm a').format(f.Time);
                    final subTxt =
                        '${f.selectedOption} • ${_formatDuration(f.elapsedTime)}';

                    return Dismissible(
                      key: ValueKey(f.id),
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async => await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: const Text('Delete this feed entry?'),
                          actions: [
                            TextButton(
                              child: const Text('CANCEL'),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            TextButton(
                              child: const Text('DELETE'),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        ),
                      ),
                      onDismissed: (_) async {
                        await model.delete(f.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Deleted'),
                              backgroundColor: Colors.red),
                        );
                      },
                      child: ListTile(
                        tileColor: kDarkBg2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(timeTxt,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(subTxt,
                            style: const TextStyle(color: Colors.white70)),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FeedDetails(id: f.id),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      );
    });
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${h}h ${m}m ${s}s';
  }
}
