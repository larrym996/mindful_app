import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mindful_app/screens/quotes_list_screen.dart';
import 'package:mindful_app/screens/settings_screen.dart';
import 'package:nsd/nsd.dart';
import 'package:url_launcher/url_launcher.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {

  List<String> seenPrinters = [];

  List<String> printers = List<String>.empty(growable: true);

  @override
  void initState() {
    super.initState();
  }

  Future search() async {
      const String name = '_ipp._tcp'; // Epson and HP answer to _ipp._tcp.local or _printer._tcp.local

      final discovery = await startDiscovery(name);
      discovery.addServiceListener((service, status) {
      if (status == ServiceStatus.found) {
        if (!seenPrinters.contains(service.name)) {
          seenPrinters.add(service.name!);
          printers.add('${service.name}');
        }        // Stop after 60 seconds
        Timer(const Duration(seconds: 60), () async {
          try {
            await stopDiscovery(discovery);
          } catch (_) {}
        });
     }
    });
  }

  Future<void> _launchUrl(String amazonUrl) async {
  final Uri url = Uri.parse('https://www.amazon.com/s?k=$amazonUrl');
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $amazonUrl');
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindful Quote'),
        actions: [
          IconButton(onPressed: () {search(); setState((){} );}, icon: const Icon(Icons.search)),
          IconButton(onPressed: _gotoSettings, icon: const Icon(Icons.settings)),
          IconButton(onPressed: _gotoList, icon: const Icon(Icons.list)),
        ],
      ),
      body: FutureBuilder(
        future: search(),
        builder: (context, snapshot) {
           if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if(snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if(printers.isEmpty) {
            return const Center(child: Text('Click the magnifying icon to find printers.', style: TextStyle(fontSize: 24, color: Colors.black54),));
          }
          else {
            return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            itemCount: printers.length,
            itemBuilder: (context, index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => _launchUrl(printers[index]),
                  borderRadius: BorderRadius.circular(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.print_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  printers[index],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Buy supplies on Amazon (Commissions earned)',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.open_in_new_rounded,
                            color: Colors.white24,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          );
          }
        }
      )
    ); }

  void _gotoSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) => const SettingsScreen()) 
    );
  }
  void _gotoList() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) => const QuotesListScreen()) 
    );
  }
}