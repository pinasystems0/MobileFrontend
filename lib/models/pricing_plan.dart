import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  BILLING OPTION
// ─────────────────────────────────────────────
class BillingOption {
  final String label; // e.g. "Monthly", "Yearly"
  final String price; // e.g. "₹500", "₹5,000"
  final String billingCycle; // e.g. "Month", "Year"

  const BillingOption({
    required this.label,
    required this.price,
    required this.billingCycle,
  });

  String get displayPrice => '$price / $billingCycle';
}

// ─────────────────────────────────────────────
//  PRICING PLAN MODEL
// ─────────────────────────────────────────────
class PricingPlan {
  final String id;
  final String name;
  final String tagline;
  String validity;
  String credits;
  final Color accentColor;
  final Color bgColor;
  final IconData icon;
  final List<String> features;
  final bool isPopular;

  /// Billing options (for plans with multiple options like Individual).
  final List<BillingOption> billingOptions;

  /// Index of the currently selected billing option.
  int selectedBillingIndex;

  /// For plans with a single fixed price (e.g. Academy, Organisation).
  /// Used instead of billingOptions when there's no choice.
  String _singlePrice;
  String _singleBillingCycle;

  PricingPlan({
    required this.id,
    required this.name,
    required this.tagline,
    required this.validity,
    required this.credits,
    String price = '',
    String billingCycle = '',
    this.billingOptions = const [],
    this.selectedBillingIndex = 0,
    required this.accentColor,
    required this.bgColor,
    required this.icon,
    required this.features,
    this.isPopular = false,
  })  : _singlePrice = price,
        _singleBillingCycle = billingCycle;

  /// The raw price string of the currently selected option.
  String get price {
    if (billingOptions.isNotEmpty) {
      return billingOptions[selectedBillingIndex].price;
    }
    return _singlePrice;
  }

  set price(String val) => _singlePrice = val;

  /// The billing cycle string of the currently selected option.
  String get billingCycle {
    if (billingOptions.isNotEmpty) {
      return billingOptions[selectedBillingIndex].billingCycle;
    }
    return _singleBillingCycle;
  }

  set billingCycle(String val) => _singleBillingCycle = val;

  /// Returns the price formatted with billing cycle when applicable.
  /// Examples:
  ///   Free Trial   → "FREE"
  ///   Individual   → "₹500 / Month"  or  "₹5,000 / Year"
  ///   Academy      → "₹5,000 / Month"
  ///   Organisation → "₹10,000 / Month"
  String get displayPrice {
    final p = price;
    final cycle = billingCycle;
    // For free / contact-us plans, don't append billing cycle
    if (p == 'FREE' || p == 'Contact Us') return p;
    if (cycle.isEmpty) return p;
    return '$p / $cycle';
  }
}

