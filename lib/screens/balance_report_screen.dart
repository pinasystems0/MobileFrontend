import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';

class BalanceReportScreen extends StatefulWidget {
  const BalanceReportScreen({super.key});

  @override
  State<BalanceReportScreen> createState() => _BalanceReportScreenState();
}

class _BalanceReportScreenState extends State<BalanceReportScreen> {
  bool isLoading = true;
  String error = '';

  Map<String, dynamic>? user;
  Map<String, dynamic>? transaction;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final token = await SessionService.getAuthToken();

      final res = await http.get(
        Uri.parse("${ApiConstants.authUrl}/api/reports/balance"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(res.body);

      if (res.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed');
      }

      setState(() {
        user = data['data']['user'];
        transaction = data['data']['transaction'];
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatNumber(num n) {
    return n.toStringAsFixed(2);
  }

  String formatDate(String iso) {
    final d = DateTime.parse(iso);
    return "${d.day}-${d.month}-${d.year}";
  }

  String formatTime(String iso) {
    final d = DateTime.parse(iso);
    return "${d.hour}:${d.minute}";
  }

  void showBuyDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        body: Center(child: Text(error)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Balance Report")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔹 CARDS
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Text("Current Balance"),
                          const SizedBox(height: 8),
                          Text(
                            formatNumber(user?['balance'] ?? 0),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Text("Account"),
                          const SizedBox(height: 8),
                          Text(user?['name'] ?? ''),
                          Text(user?['email'] ?? '', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// BUY BUTTON
            ElevatedButton(
              onPressed: showBuyDialog,
              child: const Text("Buy Credits"),
            ),

            const SizedBox(height: 20),

            /// 🔹 TABLE
            Expanded(
              child: transaction == null
                  ? const Center(child: Text("No transactions yet"))
                  : Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text("Txn ID: #${transaction!['transaction_id']}"),
                            Text("Date: ${formatDate(transaction!['transaction_datetime'])}"),
                            Text("Time: ${formatTime(transaction!['transaction_datetime'])}"),
                            Text("Balance: ${formatNumber(transaction!['balance'])}"),
                            Text("Function: ${transaction!['functionality']}"),

                            if (transaction!['credit'] > 0)
                              Text("+${transaction!['credit']}"),

                            if (transaction!['debit'] > 0)
                              Text("-${transaction!['debit']}"),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}