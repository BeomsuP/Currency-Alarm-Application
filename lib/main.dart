import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Rate',
      theme: ThemeData(useMaterial3: true),
      home: const RateScreen(),
    );
  }
}

class RateScreen extends StatefulWidget {
  const RateScreen({super.key});

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  late Future<_RateResult> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchUsdKrw();
  }

  Future<_RateResult> fetchUsdKrw() async {
    final uri = Uri.parse('https://agsscyshnh.execute-api.ca-central-1.amazonaws.com/prod/rate/usd-krw');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
   final krw = data['rate'];
if (krw is! num) throw Exception('rate not found');


    if (krw is! num) throw Exception('KRW rate not found');

    return _RateResult(
      rate: krw.toDouble(),
      asOf: DateTime.now(),
    );
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('USD → KRW')),
      body: Center(
        child: FutureBuilder<_RateResult>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }
            if (snap.hasError) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${snap.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() => _future = fetchUsdKrw()),
                    child: const Text('Retry'),
                  ),
                ],
              );
            }

            final result = snap.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '1 USD = ${result.rate.toStringAsFixed(2)} KRW',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  'Updated: ${result.asOf}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() => _future = fetchUsdKrw()),
                  child: const Text('Refresh'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RateResult {
  final double rate;
  final DateTime asOf;

  _RateResult({required this.rate, required this.asOf});
}

