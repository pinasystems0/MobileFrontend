import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class ToolManagerScreen extends StatefulWidget {
  final int requiredCredits;

  const ToolManagerScreen({
    super.key,
    required this.requiredCredits,
  });

  @override
  State<ToolManagerScreen> createState() => ToolManagerScreenState();
}

class ToolManagerScreenState extends State<ToolManagerScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  
  int balance = 0;
  bool initializing = true;
  bool loading = false;
  bool refreshing = false;

  String creditsToBuy = "";

  @override
  void initState() {
    super.initState();

    print('TOOLMANAGER STEP1 initState: attaching purchaseStream listener');

    fetchBalance();

    _iap.purchaseStream.listen((purchases) async {
      print('TOOLMANAGER STEP1 purchaseStream fired: count=${purchases.length} purchases=$purchases');

      for (final purchase in purchases) {

        print('TOOLMANAGER STEP2 purchase status check: productID=${purchase.productID} status=${purchase.status} pendingComplete=${purchase.pendingCompletePurchase}');

        if (purchase.status == PurchaseStatus.purchased) {
          print('TOOLMANAGER STEP2 PurchaseStatus became purchased: productId=${purchase.productID}');

          await billingSuccess(
            purchase.productID,
          );

          if (purchase.pendingCompletePurchase) {
            print('TOOLMANAGER purchase pendingCompletePurchase=true => completing purchase');
            await _iap.completePurchase(
              purchase,
            );
          } else {
            print('TOOLMANAGER purchase pendingCompletePurchase=false => not completing purchase');
          }

          print('TOOLMANAGER after billingSuccess => fetchBalance()');
          await fetchBalance();
        }
      }
    });
  }


  Future<void> billingSuccess(
    String productId,
  ) async {

    print('TOOLMANAGER STEP3 billingSuccess() entered productId=$productId');

    final url = "${ApiConstants.authUrl}/api/billing/success";
    print('TOOLMANAGER STEP5 URL being called: $url');

    final headers = await SessionService.authHeaders(
      includeJsonContentType: true,
    );
    print('TOOLMANAGER STEP6 headers being sent: $headers');

    final hasAuth = headers.containsKey('Authorization') && headers['Authorization']!.isNotEmpty;
    print('TOOLMANAGER STEP7 Is Authorization header present? $hasAuth');

    final bodyMap = {
      "productId": productId,
    };

    print('TOOLMANAGER STEP4 productId value received: ${bodyMap["productId"]}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(bodyMap),
      );

      print('TOOLMANAGER STEP8 HTTP status code returned: ${response.statusCode}');
      print('TOOLMANAGER STEP9 response body returned: ${response.body}');
      return;
    } catch (e) {
      print('TOOLMANAGER billingSuccess http.post threw error: $e');
      rethrow;
    }
  }


  // 🔥 FETCH BALANCE (same as web)
  Future<void> fetchBalance({bool showError = false}) async {
    try {
      final userId = await SessionService.getUserId();

      if (userId == null) {
        setState(() => initializing = false);
        return;
      }

      setState(() => refreshing = true);

      final res = await http.get(
        Uri.parse("${ApiConstants.authUrl}/api/credits/session"),
        headers: await SessionService.authHeaders(),
      );

      final json = jsonDecode(res.body);

      if (res.statusCode == 200 && json['success'] == true) {
        setState(() {
          balance = json['sessionUser']['balance'] ?? 0;
        });
      } else {
        if (showError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(json['message'] ?? "Failed to fetch balance")),
          );
        }
      }
    } catch (e) {
      if (showError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error fetching balance")),
        );
      }
    } finally {
      setState(() {
        refreshing = false;
        initializing = false;
      });
    }
  }

  // 🔥 GOOGLE PLAY BILLING
  Future<void> openCreditBilling() async {
    print("BBBBBBBBBBBB BILLING CLICKED");
    final bool available = await _iap.isAvailable();

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Google Play Billing not available"),
        ),
      );
      return;
    }

    final response = await _iap.queryProductDetails({
     'buy100',
    });

    if (response.productDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("buy100 not found"),
        ),
      );
      return;
    }

    final product = response.productDetails.first;

    final purchaseParam = PurchaseParam(
      productDetails: product,
    );

    await _iap.buyConsumable(
      purchaseParam: purchaseParam,
    );
  }

  // 🔥 BUY DIALOG (kept but not used currently)
  Future<void> showBuyDialog() async {
    int? credits;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Buy Credits"),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Enter credits",
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              credits = int.tryParse(val);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (credits != null && credits! > 0) {
                  Navigator.pop(context);
                  // Old buyCredits removed - now using billingSuccess flow
                }
              },
              child: const Text("Pay"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInsufficient = balance < widget.requiredCredits;

    return Column(
      children: [
        // White credit row
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  initializing
                      ? "Loading..."
                      : "Credits: $balance | Need: ${widget.requiredCredits}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: refreshing
                    ? null
                    : () => fetchBalance(showError: true),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Warning and Buy button in same row
        if (!initializing && isInsufficient)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[700], size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        "Need more credits",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    openCreditBilling();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: loading ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ) : const Text("Buy Credits"),
                ),
              ),
            ],
          )
        else if (!initializing && !isInsufficient)
          Row(
            children: [
              const Expanded(child: SizedBox()),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    openCreditBilling();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: loading ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ) : const Text("Buy Credits"),
                ),
              ),
            ],
          ),
      ],
    );
  }
}