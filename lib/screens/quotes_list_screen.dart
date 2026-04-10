import 'package:flutter/material.dart';
import 'package:mindful_app/data/db_helper.dart';
import 'package:mindful_app/data/quote.dart';


class QuotesListScreen extends StatelessWidget {
  const QuotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Quotes')),
      body: FutureBuilder<List<Quote>>(
        future: getQuotes(),
        builder: (context, snapshot) {
          final List<Dismissible> listTiles = [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No quotes saved yet.'));
          } else {
            for (Quote quote in snapshot.data!)
            {
              listTiles.add(Dismissible(
                key: Key(quote.id.toString()),
                onDismissed: (_) {
                  DBHelper helper = DBHelper();
                  helper.deleteQuote(quote.id!);
                },
                child: ListTile(
                    title: Text(quote.text),
                    subtitle: Text(quote.author),
                  ),
              ));
            }
            return ListView(children: listTiles,);
          }
        },
      ),
    );
  }

  Future<List<Quote>> getQuotes() async {
    DBHelper helper = DBHelper();
    return await helper.getQuotes();
  }
}