import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  bool loading = true;
  String error = '';

  int page = 1;
  int totalPages = 1;

  String type = "all";
  String functionality = "";

  Map<String, dynamic>? user;
  Map<String, dynamic>? summary;
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

      final query = {
        "page": "$page",
        "limit": "10",
      };

      if (type != "all") query["type"] = type;
      if (functionality.isNotEmpty) query["functionality"] = functionality;

      final uri = Uri.parse("${ApiConstants.authUrl}/api/reports/transaction-history")
          .replace(queryParameters: query);

      final res = await http.get(uri, headers: {
        "Authorization": "Bearer $token",
      });

      final data = jsonDecode(res.body);

      if (res.statusCode != 200) throw Exception(data['message']);

      setState(() {
        user = data['data']['user'];
        summary = data['data']['summary'];
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
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
      appBar: AppBar(title: const Text("Transaction History")),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [

            /// 🔹 SUMMARY
            Row(
              children: [
                Expanded(child: Card(child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(children: [
                    const Text("Balance"),
                    Text(fmt(user?['currentBalance'] ?? 0))
                  ]),
                ))),

                Expanded(child: Card(child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(children: [
                    const Text("Credits"),
                    Text("+${fmt(summary?['totalCredit'] ?? 0)}", style: const TextStyle(color: Colors.green))
                  ]),
                ))),

                Expanded(child: Card(child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(children: [
                    const Text("Debits"),
                    Text("-${fmt(summary?['totalDebit'] ?? 0)}", style: const TextStyle(color: Colors.red))
                  ]),
                ))),
              ],
            ),

            const SizedBox(height: 10),

            /// 🔹 FILTERS
            Row(
              children: [
                DropdownButton<String>(
                  value: type,
                  items: const [
                    DropdownMenuItem(value: "all", child: Text("All")),
                    DropdownMenuItem(value: "credit", child: Text("Credit")),
                    DropdownMenuItem(value: "debit", child: Text("Debit")),
                  ],
                  onChanged: (v) {
                    type = v!;
                    page = 1;
                    fetchData();
                  },
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search functionality",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      functionality = v;
                      page = 1;
                      fetchData();
                    },
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.payment),
                  onPressed: showBuyDialog,
                )
              ],
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
                                Text("By: ${tx['modified_by']}", style: const TextStyle(fontSize: 12)),
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