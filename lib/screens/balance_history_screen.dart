import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';

class BalanceHistoryScreen extends StatefulWidget {
  const BalanceHistoryScreen({super.key});

  @override
  State<BalanceHistoryScreen> createState() => _BalanceHistoryScreenState();
}

class _BalanceHistoryScreenState extends State<BalanceHistoryScreen> {
  bool loading = true;
  String error = '';

  int page = 1;
  int totalPages = 1;

  Map<String, dynamic>? user;
  List rows = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => loading = true);

    try {
      final token = await SessionService.getAuthToken();

      final res = await http.get(
        Uri.parse("${ApiConstants.authUrl}/api/reports/balance-history?page=$page&limit=10"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      if (res.statusCode != 200) throw Exception(data['message']);

      setState(() {
        user = data['data']['user'];
        rows = data['data']['rows'];
        totalPages = data['data']['pagination']['totalPages'];
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  String fmt(num n) => n.toStringAsFixed(2);

  String fmtDate(String iso) {
    final d = DateTime.parse(iso);
    return "${d.day}-${d.month}-${d.year}";
  }

  String fmtTime(String iso) {
    final d = DateTime.parse(iso);
    return "${d.hour}:${d.minute}";
  }

  void showBuyDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Buy Credits"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Enter credits"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final credits = int.tryParse(controller.text) ?? 0;
              if (credits <= 0) return;

              final token = await SessionService.getAuthToken();

              await http.post(
                Uri.parse("${ApiConstants.authUrl}/api/credits/buy"),
                headers: {
                  "Authorization": "Bearer $token",
                  "Content-Type": "application/json",
                },
                body: jsonEncode({"credits": credits}),
              );

              Navigator.pop(context);
              fetchData();
            },
            child: const Text("Buy"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error.isNotEmpty) {
      return Scaffold(body: Center(child: Text(error)));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Balance History")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

            /// 🔹 CARDS
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          const Text("Current Balance"),
                          Text(fmt(user?['currentBalance'] ?? 0),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          const Text("Total Records"),
                          Text("${rows.length}"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: showBuyDialog,
              child: const Text("💳 Buy Credits"),
            ),

            const SizedBox(height: 10),

            /// 🔹 LIST
            Expanded(
              child: rows.isEmpty
                  ? const Center(child: Text("No data"))
                  : ListView.builder(
                      itemCount: rows.length,
                      itemBuilder: (_, i) {
                        final tx = rows[i];

                        return Card(
                          child: ListTile(
                            title: Text("#${tx['transaction_id']}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${fmtDate(tx['transaction_datetime'])} ${fmtTime(tx['transaction_datetime'])}"),
                                Text(tx['functionality']),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(fmt(tx['balance'])),
                                if (tx['credit'] > 0)
                                  Text("+${tx['credit']}", style: const TextStyle(color: Colors.green)),
                                if (tx['debit'] > 0)
                                  Text("-${tx['debit']}", style: const TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            /// 🔹 PAGINATION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: page > 1
                      ? () {
                          page--;
                          fetchData();
                        }
                      : null,
                  child: const Text("Prev"),
                ),
                Text("Page $page / $totalPages"),
                ElevatedButton(
                  onPressed: page < totalPages
                      ? () {
                          page++;
                          fetchData();
                        }
                      : null,
                  child: const Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}