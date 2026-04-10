import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'quote.dart';

class DBHelper {
  DatabaseFactory dbFactory = databaseFactoryIo;
  Database? db;
  final _quoteStore = intMapStoreFactory.store('quotes');

  static final DBHelper _instance = DBHelper._internal(); 

  DBHelper._internal();

  factory DBHelper() {
    return _instance;
  }

  Future<Database> get _database async {
    if (db != null) return db!;
    db = await _openDB();
    return db!;
  }   

  Future<Database> _openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'quotes.db');
    final db = await dbFactory.openDatabase(path);
    return db;
  }

    Future<int> insertQuote(Quote quote) async {
    try {
      final Database db = await _database;
      int id = await _quoteStore.add(db, quote.toMap());
      return id;
    } on Exception { 
           return 0;
    }
  }

    Future<List<Quote>> getQuotes() async {
    Database db = await _database;
    final Finder finder = Finder(sortOrders: [SortOrder('q', false)]);
    final quotesSnapshots = await _quoteStore.find(db, finder: finder);
    return quotesSnapshots.map((item) {
      final quote = Quote.fromJson(item.value);
      quote.id = item.key;
      return quote;
    }).toList();
  }

  Future<bool> deleteQuote(int id) async {
    try {
      final Database db = await _database;
      final Finder finder = Finder(filter: Filter.byKey(id));
      int deletedCount = await _quoteStore.delete(db, finder: finder);
      return deletedCount > 0;
    } on Exception {
      return false;
    }
  }
}