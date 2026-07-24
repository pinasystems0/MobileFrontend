// import 'package:flutter/material.dart';
// import 'package:pina/models/pricing_plan.dart';
// import 'package:pina/ui_template/utils/template_theme.dart';

// class CheckoutScreen extends StatefulWidget {
//   final PricingPlan plan;

//   const CheckoutScreen({
//     super.key,
//     required this.plan,
//   });

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   // ── Coupon State ──
//   final TextEditingController _couponController = TextEditingController();
//   String? _appliedCoupon;
//   double _discountPercent = 0.0;
//   bool _isApplyingCoupon = false;

//   // ── Billing Details Controllers ──
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _gstController = TextEditingController();

//   // ── Terms & Conditions ──
//   bool _acceptTerms = false;

//   @override
//   void dispose() {
//     _couponController.dispose();
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _gstController.dispose();
//     super.dispose();
//   }

//   double get _parsedPrice {
//     final priceStr = widget.plan.price.replaceAll('₹', '').replaceAll(',', '').trim();
//     final parsed = double.tryParse(priceStr);
//     return parsed ?? 0.0;
//   }

//   double get _discountAmount => _parsedPrice * (_discountPercent / 100);
//   double get _totalPrice => _parsedPrice - _discountAmount;

//   void _applyCoupon() {
//     final code = _couponController.text.trim().toUpperCase();
//     if (code.isEmpty) return;

//     setState(() {
//       _isApplyingCoupon = true;
//     });

//     // Simulate API call delay
//     Future.delayed(const Duration(milliseconds: 800), () {
//       if (!mounted) return;
//       setState(() {
//         _isApplyingCoupon = false;
//         // Demo coupon codes
//         if (code == 'SAVE10') {
//           _appliedCoupon = code;
//           _discountPercent = 10.0;
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Coupon applied! 10% discount'),
//               backgroundColor: Colors.green,
//               duration: Duration(seconds: 2),
//             ),
//           );
//         } else if (code == 'SAVE20') {
//           _appliedCoupon = code;
//           _discountPercent = 20.0;
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Coupon applied! 20% discount'),
//               backgroundColor: Colors.green,
//               duration: Duration(seconds: 2),
//             ),
//           );
//         } else {
//           _appliedCoupon = null;
//           _discountPercent = 0.0;
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Invalid coupon code'),
//               backgroundColor: Colors.redAccent,
//               duration: Duration(seconds: 2),
//             ),
//           );
//         }
//       });
//     });
//   }

//   void _removeCoupon() {
//     setState(() {
//       _appliedCoupon = null;
//       _discountPercent = 0.0;
//       _couponController.clear();
//     });
//   }

//   void _onProceedToPayment() {
//     if (!_acceptTerms) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please accept the Terms & Conditions to proceed.'),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//       return;
//     }

//     // TODO: Implement payment integration later.
//     // This will connect to the payment gateway in a future update.
//     // No Google Play Billing calls are made from here.
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Payment integration coming soon.'),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   bool get _canProceed => _acceptTerms;

//   @override
//   Widget build(BuildContext context) {
//     final plan = widget.plan;
//     final hasPrice = _parsedPrice > 0;

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: TemplateBackdrop(
//         child: SafeArea(
//           child: Column(
//             children: [
//               // ── HEADER ──────────────────────────
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
//                 child: Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: TemplateTheme.glassPanel(
//                           color: Colors.white,
//                           opacity: 0.92,
//                           radius: 16,
//                         ),
//                         child: const Icon(
//                           Icons.arrow_back_ios_new_rounded,
//                           size: 18,
//                           color: TemplateTheme.textPrimary,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     const Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Checkout",
//                             style: TextStyle(
//                               fontFamily: 'Poppins',
//                               fontSize: 20,
//                               fontWeight: FontWeight.w700,
//                               color: TemplateTheme.textPrimary,
//                             ),
//                           ),
//                           SizedBox(height: 2),
//                           Text(
//                             "Review & confirm your subscription",
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: TemplateTheme.textMuted,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 8),

//               // ── SCROLLABLE BODY ──────────────────
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ── 1. REVIEW YOUR SELECTED PLAN ──
//                       _buildSectionTitle("Review Your Selected Plan", plan.accentColor),
//                       const SizedBox(height: 8),
//                       _buildPlanCard(plan),

//                       const SizedBox(height: 20),

//                       // ── 2. BENEFITS ──
//                       _buildSectionTitle("Benefits", plan.accentColor),
//                       const SizedBox(height: 8),
//                       _buildBenefitsList(plan),

//                       const SizedBox(height: 20),

//                       // ── 3. PAYMENT SUMMARY ──
//                       if (hasPrice) ...[
//                         _buildSectionTitle("Payment Summary", plan.accentColor),
//                         const SizedBox(height: 8),
//                         _buildPaymentSummary(plan),

//                         const SizedBox(height: 20),

//                         // ── 4. COUPON CODE ──
//                         _buildSectionTitle("Coupon Code", plan.accentColor),
//                         const SizedBox(height: 8),
//                         _buildCouponSection(plan),

//                         const SizedBox(height: 20),

//                         // ── 5. BILLING DETAILS ──
//                         _buildSectionTitle("Billing Details", plan.accentColor),
//                         const SizedBox(height: 8),
//                         _buildBillingDetails(plan),

//                         const SizedBox(height: 20),
//                       ],

//                       // ── 6. TERMS & CONDITIONS ──
//                       _buildTermsSection(plan),

//                       const SizedBox(height: 100), // space for bottom bar
//                     ],
//                   ),
//                 ),
//               ),

//               // ── STICKY BOTTOM BAR ──
//               if (hasPrice) _buildBottomBar(plan),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────
//   //  SECTION TITLE
//   // ─────────────────────────────────────────────
//   Widget _buildSectionTitle(String title, Color accentColor) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w800,
//             color: accentColor,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Container(
//           height: 2,
//           width: 36,
//           decoration: BoxDecoration(
//             color: accentColor,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//       ],
//     );
//   }

//   // ─────────────────────────────────────────────
//   //  PLAN CARD
//   // ─────────────────────────────────────────────
//   Widget _buildPlanCard(PricingPlan plan) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: TemplateTheme.glassPanel(
//         color: Colors.white,
//         opacity: 0.92,
//         radius: 28,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: plan.accentColor,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Icon(plan.icon, color: Colors.white, size: 24),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       plan.name.toUpperCase(),
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w800,
//                         color: plan.accentColor,
//                       ),
//                     ),
//                     const SizedBox(height: 3),
//                     Text(
//                       plan.tagline,
//                       style: const TextStyle(
//                         fontSize: 11.5,
//                         height: 1.4,
//                         color: TemplateTheme.textMuted,
//                       ),
//                     ),
//                     // Show selected billing cycle label
//                     if (plan.billingOptions.isNotEmpty) ...[
//                       const SizedBox(height: 4),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: plan.accentColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Text(
//                           plan.billingOptions[plan.selectedBillingIndex].label,
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w700,
//                             color: plan.accentColor,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 18),
//           Row(
//             children: [
//               Expanded(child: _infoCard(title: "VALIDITY", value: plan.validity, accentColor: plan.accentColor)),
//               const SizedBox(width: 10),
//               Expanded(child: _infoCard(title: "CREDITS", value: plan.credits, accentColor: plan.accentColor)),
//               const SizedBox(width: 10),
//               Expanded(child: _infoCard(title: "PRICE", value: plan.displayPrice, accentColor: plan.accentColor)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _infoCard({required String title, required String value, required Color accentColor}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
//       decoration: BoxDecoration(
//         color: accentColor.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         children: [
//           Text(
//             value,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w800,
//               color: accentColor,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 9.5,
//               fontWeight: FontWeight.w700,
//               color: TemplateTheme.textMuted,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────
//   //  BENEFITS LIST
//   // ─────────────────────────────────────────────
//   Widget _buildBenefitsList(PricingPlan plan) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: TemplateTheme.glassPanel(
//         color: Colors.white,
//         opacity: 0.92,
//         radius: 28,
//       ),
//       child: Column(
//         children: plan.features.map((feature) {
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 10),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   margin: const EdgeInsets.only(top: 2),
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: plan.accentColor,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.check, size: 10, color: Colors.white),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     feature,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: Color(0xFF333355),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────
//   //  PAYMENT SUMMARY
//   // ─────────────────────────────────────────────
//   Widget _buildPaymentSummary(PricingPlan plan) {
//     final hasDiscount = _discountPercent > 0;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: TemplateTheme.glassPanel(
//         color: Colors.white,
//         opacity: 0.92,
//         radius: 28,
//       ),
//       child: Column(
//         children: [
//           _summaryRow("Subtotal", plan.displayPrice, plan.accentColor),
//           if (hasDiscount) ...[
//             const SizedBox(height: 10),
//             _summaryRow(
//               "Discount (${_discountPercent.toStringAsFixed(0)}%)",
//               "-₹${_discountAmount.toStringAsFixed(0)}",
//               Colors.green,
//             ),
//           ],
//           const Divider(height: 24, thickness: 1, color: Color(0xFFEEEEF5)),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Total",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w800,
//                   color: plan.accentColor,
//                 ),
//               ),
//               Text(
//                 _totalPrice > 0 ? "₹${_totalPrice.toStringAsFixed(0)}" : "FREE",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w800,
//                   color: plan.accentColor,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _summaryRow(String label, String value, Color color) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 13,
//             color: TemplateTheme.textMuted,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w700,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }

//   // ─────────────────────────────────────────────
//   //  COUPON CODE
//   // ─────────────────────────────────────────────
//   Widget _buildCouponSection(PricingPlan plan) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: TemplateTheme.glassPanel(
//         color: Colors.white,
//         opacity: 0.92,
//         radius: 28,
//       ),
//       child: Column(
//         children: [
//           if (_appliedCoupon != null) ...[
//             Row(
//               children: [
//                 Icon(Icons.check_circle_rounded, size: 18, color: Colors.green),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     "Coupon '$_appliedCoupon' applied!",
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: _removeCoupon,
//                   child: Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: Colors.red.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(Icons.close, size: 14, color: Colors.red),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 14),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(color: TemplateTheme.border),
//                   ),
//                   child: TextField(
//                     controller: _couponController,
//                     enabled: _appliedCoupon == null,
//                     decoration: const InputDecoration(
//                       hintText: "Enter coupon code",
//                       hintStyle: TextStyle(fontSize: 13, color: TemplateTheme.textMuted),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(vertical: 14),
//                     ),
//                     style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               SizedBox(
//                 height: 46,
//                 child: ElevatedButton(
//                   onPressed: _appliedCoupon != null || _isApplyingCoupon ? null : _applyCoupon,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: plan.accentColor,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     elevation: 0,
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                   ),
//                   child: _isApplyingCoupon
//                       ? const SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Text(
//                           "Apply",
//                           style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────
//   //  BILLING DETAILS
//   // ─────────────────────────────────────────────
//   Widget _buildBillingDetails(PricingPlan plan) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: TemplateTheme.glassPanel(
//         color: Colors.white,
//         opacity: 0.92,
//         radius: 28,
//       ),
//       child: Column(
//         children: [
//           _billingField(
//             controller: _nameController,
//             label: "Full Name",
//             hint: "Enter your full name",
//             icon: Icons.person_outline_rounded,
//           ),
//           const SizedBox(height: 14),
//           _billingField(
//             controller: _emailController,
//             label: "Email Address",
//             hint: "Enter your email",
//             icon: Icons.email_outlined,
//             keyboardType: TextInputType.emailAddress,
//           ),
//           const SizedBox(height: 14),
//           _billingField(
//             controller: _phoneController,
//             label: "Phone Number",
//             hint: "Enter your phone number",
//             icon: Icons.phone_outlined,
//             keyboardType: TextInputType.phone,
//           ),
//           const SizedBox(height: 14),
//           _billingField(
//             controller: _gstController,
//             label: "GST (Optional)",
//             hint: "Enter GST number if applicable",
//             icon: Icons.receipt_outlined,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _billingField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: TemplateTheme.border),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: TemplateTheme.textMuted),
//           const SizedBox(width: 10),
//           Expanded(
//             child: TextField(
//               controller: controller,
//               keyboardType: keyboardType,
//               decoration: InputDecoration(
//                 labelText: label,
//                 hintText: hint,
//                 hintStyle: const TextStyle(fontSize: 12, color: TemplateTheme.textMuted),
//                 labelStyle: const TextStyle(fontSize: 12, color: TemplateTheme.textMuted),
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//               style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────
//   //  TERMS & CONDITIONS
//   // ─────────────────────────────────────────────
//   Widget _buildTermsSection(PricingPlan plan) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _acceptTerms = !_acceptTerms;
//         });
//       },
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(14),
//         decoration: TemplateTheme.glassPanel(
//           color: Colors.white,
//           opacity: 0.88,
//           radius: 18,
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               margin: const EdgeInsets.only(top: 2),
//               height: 22,
//               width: 22,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: _acceptTerms ? plan.accentColor : Colors.grey.shade400,
//                   width: 2,
//                 ),
//                 color: _acceptTerms ? plan.accentColor : Colors.transparent,
//               ),
//               child: _acceptTerms
//                   ? const Icon(Icons.check, size: 13, color: Colors.white)
//                   : null,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: RichText(
//                 text: TextSpan(
//                   style: const TextStyle(
//                     fontSize: 11.5,
//                     height: 1.5,
//                     color: TemplateTheme.textMuted,
//                   ),
//                   children: [
//                     const TextSpan(
//                       text: "I accept the ",
//                     ),
//                     TextSpan(
//                       text: "Terms & Conditions",
//                       style: TextStyle(
//                         color: plan.accentColor,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     const TextSpan(
//                       text: " and ",
//                     ),
//                     TextSpan(
//                       text: "Privacy Policy",
//                       style: TextStyle(
//                         color: plan.accentColor,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     const TextSpan(
//                       text:
//                           ". By proceeding, you agree to the subscription auto-renewal terms. You can cancel anytime.",
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────
//   //  STICKY BOTTOM BAR
//   // ─────────────────────────────────────────────
//   Widget _buildBottomBar(PricingPlan plan) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.95),
//         border: Border(
//           top: BorderSide(color: TemplateTheme.border.withOpacity(0.5)),
//         ),
//       ),
//       child: Row(
//         children: [
//           // Total Price
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   "Total",
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: TemplateTheme.textMuted,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Row(
//                   children: [
//                     Text(
//                       _totalPrice > 0 ? "₹${_totalPrice.toStringAsFixed(0)}" : "FREE",
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w800,
//                         color: plan.accentColor,
//                       ),
//                     ),
//                     if (_discountPercent > 0) ...[
//                       const SizedBox(width: 8),
//                       Text(
//                         widget.plan.displayPrice,
//                         style: const TextStyle(
//                           fontSize: 13,
//                           decoration: TextDecoration.lineThrough,
//                           color: TemplateTheme.textMuted,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // Proceed to Payment Button
//           SizedBox(
//             height: 50,
//             child: ElevatedButton(
//               onPressed: _canProceed ? _onProceedToPayment : null,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: plan.accentColor,
//                 foregroundColor: Colors.white,
//                 disabledBackgroundColor: Colors.grey.shade300,
//                 disabledForegroundColor: Colors.grey.shade500,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 elevation: 0,
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     "Proceed to Payment",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w700,
//                       fontSize: 14,
//                     ),
//                   ),
//                   SizedBox(width: 6),
//                   Icon(Icons.arrow_forward_rounded, size: 18),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

