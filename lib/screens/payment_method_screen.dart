import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pina/ui_template/utils/template_theme.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:http/http.dart' as http;
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';

class PaymentMethodScreen extends StatefulWidget {
  final dynamic plan;

  const PaymentMethodScreen({
    super.key,
    required this.plan,
  });

  @override
  State<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState
    extends State<PaymentMethodScreen> {
  String selectedMethod = "google";
  
  // Step 1: Add InAppPurchase instance
  final InAppPurchase _iap = InAppPurchase.instance;
  
  // Step 1: Define product IDs
  static const Set<String> _productIds = {
    'individual_monthly',
    'academy_monthly',
  };

  @override
  void initState() {
    super.initState();

    print('PAYMENT_SCREEN STEP1 initState: attaching purchaseStream listener');

    _iap.purchaseStream.listen((purchases) async {
      print('PAYMENT_SCREEN STEP1 purchaseStream fired: count=${purchases.length} purchases=$purchases');

      for (final purchase in purchases) {

        print('PAYMENT_SCREEN STEP2 purchase status check: productID=${purchase.productID} status=${purchase.status} pendingComplete=${purchase.pendingCompletePurchase}');

        if (purchase.status == PurchaseStatus.purchased) {
          print('PAYMENT_SCREEN STEP2 PurchaseStatus became purchased: productId=${purchase.productID}');

          await billingSuccess(
            purchase.productID,
            purchase.purchaseID,
          );

          if (purchase.pendingCompletePurchase) {
            print('PAYMENT_SCREEN purchase pendingCompletePurchase=true => completing purchase');
            await _iap.completePurchase(
              purchase,
            );
          } else {
            print('PAYMENT_SCREEN purchase pendingCompletePurchase=false => not completing purchase');
          }
        }
      }
    });
  }


  Future<void> billingSuccess(String productId, String? purchaseToken) async {
    print('PAYMENT_SCREEN STEP3 billingSuccess() entered productId=$productId');

    final url = "${ApiConstants.authUrl}/api/billing/success";
    print('PAYMENT_SCREEN STEP5 URL being called: $url');

    final headers = await SessionService.authHeaders(
      includeJsonContentType: true,
    );
    print('PAYMENT_SCREEN STEP6 headers being sent: $headers');

    final hasAuth = headers.containsKey('Authorization') && headers['Authorization']!.isNotEmpty;
    print('PAYMENT_SCREEN STEP7 Is Authorization header present? $hasAuth');

    if (purchaseToken == null || purchaseToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing purchase token. Please try again.'),
        ),
      );
      return;
    }

    final bodyMap = {
      "productId": productId,
      "purchaseToken": purchaseToken,
    };

    print('PAYMENT_SCREEN STEP4 productId value received: ${bodyMap["productId"]}');
    print('PAYMENT_SCREEN STEP4 purchaseToken value received: ${bodyMap["purchaseToken"]}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(bodyMap),
      );

      print('PAYMENT_SCREEN STEP8 HTTP status code returned: ${response.statusCode}');
      print('PAYMENT_SCREEN STEP9 response body returned: ${response.body}');

      return;
    } catch (e) {
      print('PAYMENT_SCREEN billingSuccess http.post threw error: $e');
      rethrow;
    }
  }


  // Step 2: Add purchase method with your specified format
  Future<void> _startGooglePurchase() async {
    final bool available = await _iap.isAvailable();

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Google Play Billing not available"),
        ),
      );
      return;
    }

    final response =
        await _iap.queryProductDetails(_productIds);

    if (response.productDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Subscription not found in Play Console",
          ),
        ),
      );
      return;
    }

    final selectedProductId =
        widget.plan.id == 'individual'
            ? 'individual_monthly'
            : widget.plan.id == 'academy'
                ? 'academy_monthly'
                : null;

    if (selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid plan selected. Please go back and choose a valid plan.'),
        ),
      );
      return;
    }

    final product = response.productDetails.firstWhere(
      (p) => p.id == selectedProductId,
    );


    // Using your specified format
    final purchaseParam =
        PurchaseParam(productDetails: product);

    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOrganisation =
        widget.plan.id == "organisation";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TemplateBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              children: [
                // HEADER
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: TemplateTheme.glassPanel(
                          color: Colors.white,
                          opacity: 0.92,
                          radius: 16,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Choose Payment",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color:
                                  TemplateTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Secure & encrypted checkout",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  TemplateTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // BODY
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // PLAN SUMMARY CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration:
                              TemplateTheme.glassPanel(
                            color: Colors.white,
                            opacity: 0.92,
                            radius: 28,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.all(
                                            12),
                                    decoration: BoxDecoration(
                                      color: widget
                                          .plan.accentColor,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  16),
                                    ),
                                    child: Icon(
                                      widget.plan.icon,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          widget.plan.name
                                              .toUpperCase(),
                                          style:
                                              TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                                FontWeight
                                                    .w800,
                                            color: widget
                                                .plan
                                                .accentColor,
                                          ),
                                        ),

                                        const SizedBox(
                                            height: 3),

                                        Text(
                                          widget.plan
                                              .tagline,
                                          style:
                                              const TextStyle(
                                            fontSize: 11.5,
                                            height: 1.4,
                                            color:
                                                TemplateTheme
                                                    .textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              Row(
                                children: [
                                  Expanded(
                                    child: _infoCard(
                                      title:
                                          "VALIDITY",
                                      value: widget
                                          .plan
                                          .validity,
                                    ),
                                  ),

                                  const SizedBox(
                                      width: 10),

                                  Expanded(
                                    child: _infoCard(
                                      title:
                                          "CREDITS",
                                      value: widget
                                          .plan
                                          .credits,
                                    ),
                                  ),

                                  const SizedBox(
                                      width: 10),

                                  Expanded(
                                    child: _infoCard(
                                      title:
                                          "PRICE",
                                      value: widget
                                          .plan
                                          .price,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        Align(
                          alignment:
                              Alignment.centerLeft,
                          child: Text(
                            "Payment Methods",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w800,
                              color: widget
                                  .plan.accentColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // GOOGLE BILLING
                        if (!isOrganisation)
                          _paymentCard(
                            id: "google",
                            icon:
                                Icons.play_circle_fill_rounded,
                            title:
                                "Google Play Billing",
                            subtitle:
                                "Recommended for Android users",
                            points: [
                              "Fast & secure checkout",
                              "Subscription management",
                              "Trusted Google payment",
                            ],
                          ),

                        if (!isOrganisation)
                          const SizedBox(height: 16),

                        // PAYMENT GATEWAY
                        _paymentCard(
                          id: "gateway",
                          icon:
                              Icons.account_balance_wallet_rounded,
                          title: "Payment Gateway",
                          subtitle:
                              "UPI • Cards • Net Banking",
                          points: [
                            "Instant payment activation",
                            "Supports multiple methods",
                            "Secure encrypted payment",
                          ],
                        ),

                        const SizedBox(height: 26),

                        // SECURITY INFO
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(14),
                          decoration:
                              TemplateTheme.glassPanel(
                            color: Colors.white,
                            opacity: 0.88,
                            radius: 18,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                color: widget
                                    .plan.accentColor,
                              ),

                              const SizedBox(width: 10),

                              const Expanded(
                                child: Text(
                                  "All transactions are secured with encrypted payment protection.",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    height: 1.5,
                                    color:
                                        TemplateTheme
                                            .textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // CONTINUE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      // Step 3: Replace with actual purchase method
                      if (selectedMethod == "google") {
                        _startGooglePurchase();
                      } else {
                        print("PAYMENT GATEWAY");
                      }
                    },
                    style:
                        TemplateTheme.softButtonStyle(
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.plan.price ==
                                  "FREE"
                              ? "Get Started"
                              : "Continue Payment",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(width: 8),

                        const Icon(
                          Icons
                              .arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // INFO CARD
  Widget _infoCard({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: widget.plan.accentColor
            .withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: widget.plan.accentColor,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: TemplateTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // PAYMENT CARD
  Widget _paymentCard({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> points,
  }) {
    final bool selected =
        selectedMethod == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = id;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: TemplateTheme.glassPanel(
          color: Colors.white,
          opacity: 0.94,
          radius: 24,
          borderColor: selected
              ? widget.plan.accentColor
              : Colors.white.withOpacity(0.6),
        ),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 250),
                  padding:
                      const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected
                        ? widget.plan.accentColor
                        : Colors.white,
                    borderRadius:
                        BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: selected
                            ? widget.plan.accentColor
                                .withOpacity(0.22)
                            : Colors.black
                                .withOpacity(0.04),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: selected
                        ? Colors.white
                        : widget.plan.accentColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              TemplateTheme
                                  .textPrimary,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color:
                              TemplateTheme
                                  .textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 250),
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? widget
                              .plan.accentColor
                          : Colors.grey
                              .shade400,
                      width: 2,
                    ),
                    color: selected
                        ? widget
                            .plan.accentColor
                        : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 16),

            ...points.map(
              (e) => Padding(
                padding:
                    const EdgeInsets.only(
                        bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 15,
                      color:
                          widget.plan.accentColor,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color:
                              TemplateTheme
                                  .textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}