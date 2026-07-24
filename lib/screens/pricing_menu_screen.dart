// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:pina/screens/constants.dart';
// import 'package:pina/screens/checkout_screen.dart';
// import 'package:pina/services/session_service.dart';
// import 'package:pina/screens/homescreen.dart';
// import 'package:pina/models/pricing_plan.dart';
// import 'package:url_launcher/url_launcher.dart';

// // ─────────────────────────────────────────────
// //  DEFAULT PLANS
// //  free_trial  → all hardcoded
// //  individual  → all 3 from API
// //  academy     → validity & credits hardcoded, price from API
// //  organisation→ all hardcoded
// // ─────────────────────────────────────────────
// List<PricingPlan> _buildDefaultPlans() => [
//       PricingPlan(
//         id: 'free_trial',
//         name: 'Free Trial',
//         tagline:
//             'Explore the platform and experience the power of AI absolutely FREE.',
//         validity: '30 Days',
//         credits: '1000',
//         price: 'FREE',
//         billingCycle: 'Free',
//         accentColor: const Color(0xFF6C3FE8),
//         bgColor: const Color(0xFFF3EEFF),
//         icon: Icons.card_giftcard_rounded,
//         isPopular: true,
//         features: [
//           'Access to Guest Mode',
//           'Text Generation',
//           'Image Generation',
//           'Audio Generation',
//           'Video Generation',
//           'AI Chat & AI Agents',
//           'Access to Selected AI Tools & Models',
//         ],
//       ),
//       PricingPlan(
//         id: 'individual',
//         name: 'Individual',
//         tagline:
//             'Best-in-class quantized & large language models for professionals.',
//         validity: '30 Days',
//         credits: '2000',
//         billingOptions: const [
//           BillingOption(label: 'Monthly', price: '₹500', billingCycle: 'Month'),
//           BillingOption(label: 'Yearly', price: '₹5,000', billingCycle: 'Year'),
//         ],
//         accentColor: const Color(0xFF1565C0),
//         bgColor: const Color(0xFFE8F0FE),
//         icon: Icons.person_rounded,
//         features: [
//           'Access to Best-in-Class Quantized Models',
//           'Access to Large Language Models (LLMs)',
//           'Specialist AI Tools',
//           'Advanced AI Features',
//           'Premium AI Experience',
//         ],
//       ),
//       PricingPlan(
//         id: 'academy',
//         name: 'Academy',
//         tagline:
//             'For students, teachers, coaching classes & educational institutes.',
//         validity: '30 Days',
//         credits: '3000',
//         price: '₹5,000',
//         billingCycle: 'Month',
//         accentColor: const Color(0xFFE65100),
//         bgColor: const Color(0xFFFFF3E0),
//         icon: Icons.school_rounded,
//         features: [
//           'Covers Syllabus from Standard 1 to 12',
//           'Supports CBSE, State Board, ICSE & ISC',
//           'Generate Educational Content',
//           'Practice Tests & Mock Exams',
//           'AI-generated Exam Papers',
//           'Clear Concepts using AI Chat & Agents',
//           'Smart Learning Assistance',
//           'Subject-wise Learning Support',
//         ],
//       ),
//       PricingPlan(
//         id: 'organisation',
//         name: 'Organisation',
//         tagline:
//             'Drop your query — our Senior CRM team will get in touch with you.',
//         validity: 'Custom',
//         credits: 'Custom',
//         price: '₹10,000',
//         billingCycle: 'Month',
//         accentColor: const Color(0xFF00796B),
//         bgColor: const Color(0xFFE0F2F1),
//         icon: Icons.business_rounded,
//         features: [
//           'Access to Guest Mode',
//           'Text Generation',
//           'Image Generation',
//           'Audio Generation',
//           'Video Generation',
//           'AI Chat & AI Agents',
//           'Access to Selected AI Tools & Models',
//           'Dedicated CRM Support',
//         ],
//       ),
//     ];

// // ─────────────────────────────────────────────
// //  SCREEN
// // ─────────────────────────────────────────────
// class PricingMenuScreen extends StatefulWidget {
//   const PricingMenuScreen({super.key});

//   @override
//   State<PricingMenuScreen> createState() => _PricingMenuScreenState();
// }

// class _PricingMenuScreenState extends State<PricingMenuScreen> {
//   int _selectedIndex = 0;
//   bool _isLoading = true;
//   String? _errorMsg;
//   late List<PricingPlan> _plans;

//   final PageController _pageController = PageController(
//     viewportFraction: 0.88,
//     initialPage: 0,
//   );

//   @override
//   void initState() {
//     super.initState();
//     _plans = _buildDefaultPlans();
//     _fetchPricingData();
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   // ── Fetch pricing data from API (backend values take precedence when available) ──
//   Future<void> _fetchPricingData() async {
//     try {
//       final res = await http
//           .get(
//             Uri.parse('${ApiConstants.authUrl}/api/pricing-master/plans'),
//             headers: {'Content-Type': 'application/json'},
//           )
//           .timeout(const Duration(seconds: 10));

//       if (res.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(res.body);

//         for (final item in data) {
//           final planName =
//               (item['pricing_plan_name'] ?? '').toString().toLowerCase().trim();
//           final priceVal = item['price'] ?? 0;
//           final validityDays = item['validity'] ?? 0;
//           final creditLimit = item['credit_limit'] ?? 0;
//           final cycle = (item['billing_cycle'] ?? '').toString().trim();

//           if (planName.contains('individual')) {
//             // All fields from API when available; fallback to defaults
//             final ind =
//                 _plans.firstWhere((p) => p.id == 'individual');
//             ind.validity =
//                 validityDays == 0 ? 'Custom' : '$validityDays Days';
//             ind.credits = _fmt(creditLimit);
//             ind.price = priceVal == 0 ? 'Contact Us' : '₹$priceVal';
//             if (cycle.isNotEmpty) ind.billingCycle = cycle;
//           } else if (planName.contains('academy')) {
//             // Price from API when available; validity, credits & billingCycle use defaults
//             final acad =
//                 _plans.firstWhere((p) => p.id == 'academy');
//             acad.price = priceVal == 0 ? 'Contact Us' : '₹$priceVal';
//             if (cycle.isNotEmpty) acad.billingCycle = cycle;
//           }
//           // free_trial and organisation → never touched by API
//         }

//         if (mounted) setState(() => _isLoading = false);
//       } else {
//         _setError('Server error (${res.statusCode})');
//       }
//     } catch (_) {
//       _setError('Network error. Please retry.');
//     }
//   }

//   void _setError(String msg) {
//     if (mounted) setState(() { _isLoading = false; _errorMsg = msg; });
//   }

//   String _fmt(dynamic n) {
//     if (n == null || n == 0) return 'Custom';
//     final v = int.tryParse(n.toString()) ?? 0;
//     if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(0)}M';
//     if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
//     return v.toString();
//   }

//   void _onPageChanged(int i) => setState(() => _selectedIndex = i);

//   void _onBillingChanged() {
//     setState(() {});
//   }

//   void _openDetail(PricingPlan plan) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _PlanDetailSheet(
//         plan: plan,
//         onBillingChanged: _onBillingChanged,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F8FC),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded,
//               color: Color(0xFF1A1A2E), size: 20),
//           onPressed: () => Navigator.maybePop(context),
//         ),
//         title: const Column(
//           children: [
//             Text(
//               'Pricing',
//               style: TextStyle(
//                 color: Color(0xFF1A1A2E),
//                 fontWeight: FontWeight.w800,
//                 fontSize: 18,
//                 letterSpacing: -0.3,
//               ),
//             ),
//             Text(
//               'Flexible plans for every learner & professional',
//               style: TextStyle(
//                 color: Color(0xFF888AAA),
//                 fontSize: 11,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined,
//                 color: Color(0xFF1A1A2E)),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // ── Tab row ──────────────────────────
//           _TabRow(
//             plans: _plans,
//             selectedIndex: _selectedIndex,
//             onTap: (i) => _pageController.animateToPage(
//               i,
//               duration: const Duration(milliseconds: 350),
//               curve: Curves.easeInOut,
//             ),
//           ),

//           // ── Cards ─────────────────────────────
//           Expanded(
//             child: _isLoading
//                 ? Center(
//                     child: CircularProgressIndicator(
//                         color: const Color(0xFF6C3FE8)))
//                 : _errorMsg != null
//                     ? Center(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.wifi_off_rounded,
//                                 size: 44, color: Colors.grey),
//                             const SizedBox(height: 10),
//                             Text(_errorMsg!,
//                                 style: const TextStyle(
//                                     color: Colors.redAccent)),
//                             const SizedBox(height: 14),
//                             ElevatedButton.icon(
//                               onPressed: () {
//                                 setState(() {
//                                   _isLoading = true;
//                                   _errorMsg = null;
//                                   _plans = _buildDefaultPlans();
//                                 });
//                                 _fetchPricingData();
//                               },
//                               icon: const Icon(Icons.refresh),
//                               label: const Text('Retry'),
//                             ),
//                           ],
//                         ),
//                       )
//                     : PageView.builder(
//                         controller: _pageController,
//                         onPageChanged: _onPageChanged,
//                         itemCount: _plans.length,
//                         itemBuilder: (_, i) {
//                           final plan = _plans[i];
//                           final isActive = i == _selectedIndex;
//                           return AnimatedScale(
//                             scale: isActive ? 1.0 : 0.95,
//                             duration: const Duration(milliseconds: 300),
//                             curve: Curves.easeOut,
//                             child: _PlanCard(
//                               plan: plan,
//                               isActive: isActive,
//                               onTap: () => _openDetail(plan),
//                               onBillingChanged: _onBillingChanged,
//                             ),
//                           );
//                         },
//                       ),
//           ),

//           // ── Dot indicators ───────────────────
//           Padding(
//             padding: const EdgeInsets.only(top: 6, bottom: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(_plans.length, (i) {
//                 final active = i == _selectedIndex;
//                 return AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   margin: const EdgeInsets.symmetric(horizontal: 4),
//                   width: active ? 20 : 7,
//                   height: 7,
//                   decoration: BoxDecoration(
//                     color: active
//                         ? _plans[_selectedIndex].accentColor
//                         : const Color(0xFFCCCCDD),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 );
//               }),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  TAB ROW
// // ─────────────────────────────────────────────
// class _TabRow extends StatelessWidget {
//   final List<PricingPlan> plans;
//   final int selectedIndex;
//   final ValueChanged<int> onTap;
//   const _TabRow(
//       {required this.plans,
//       required this.selectedIndex,
//       required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: List.generate(plans.length, (i) {
//             final sel = i == selectedIndex;
//             final p = plans[i];
//             return GestureDetector(
//               onTap: () => onTap(i),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 250),
//                 margin: const EdgeInsets.only(right: 8),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: sel ? p.accentColor : p.bgColor,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(p.icon,
//                         size: 15,
//                         color: sel ? Colors.white : p.accentColor),
//                     const SizedBox(width: 5),
//                     Text(p.name,
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700,
//                           color: sel ? Colors.white : p.accentColor,
//                         )),
//                   ],
//                 ),
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  PLAN CARD
// // ─────────────────────────────────────────────
// class _PlanCard extends StatelessWidget {
//   final PricingPlan plan;
//   final bool isActive;
//   final VoidCallback onTap;
//   final VoidCallback onBillingChanged;

//   const _PlanCard({
//     required this.plan,
//     required this.isActive,
//     required this.onTap,
//     required this.onBillingChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Use LayoutBuilder so card fits whatever height it gets
//     return LayoutBuilder(builder: (context, constraints) {
//       return GestureDetector(
//         onTap: onTap,
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color:
//                     plan.accentColor.withOpacity(isActive ? 0.18 : 0.07),
//                 blurRadius: isActive ? 24 : 10,
//                 offset: const Offset(0, 6),
//               ),
//             ],
//             border: Border.all(
//               color: isActive
//                   ? plan.accentColor.withOpacity(0.35)
//                   : Colors.transparent,
//               width: 1.5,
//             ),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ── Coloured header ────────────
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
//                   decoration: BoxDecoration(color: plan.bgColor),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(9),
//                             decoration: BoxDecoration(
//                               color: plan.accentColor,
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(plan.icon,
//                                 color: Colors.white, size: 19),
//                           ),
//                           if (plan.isPopular) ...[
//                             const SizedBox(width: 10),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 10, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: plan.accentColor,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: const Text('POPULAR',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w800,
//                                     letterSpacing: 0.8,
//                                   )),
//                             ),
//                           ],
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         plan.name.toUpperCase(),
//                         style: TextStyle(
//                           color: plan.accentColor,
//                           fontSize: 19,
//                           fontWeight: FontWeight.w900,
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                       const SizedBox(height: 3),
//                       Text(
//                         plan.tagline,
//                         style: const TextStyle(
//                           color: Color(0xFF555577),
//                           fontSize: 11.5,
//                           height: 1.4,
//                         ),
//                       ),
//                       // ── Billing toggle (Individual only) ──
//                       if (plan.billingOptions.isNotEmpty) ...[
//                         const SizedBox(height: 12),
//                         _BillingToggle(
//                           options: plan.billingOptions,
//                           selectedIndex: plan.selectedBillingIndex,
//                           accentColor: plan.accentColor,
//                           onChanged: (index) {
//                             plan.selectedBillingIndex = index;
//                             onBillingChanged();
//                           },
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 // ── Stat chips ─────────────────
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 14, vertical: 10),
//                   child: Row(
//                     children: [
//                       _StatChip(
//                           icon: Icons.calendar_today_rounded,
//                           label: 'Validity',
//                           value: plan.validity,
//                           color: plan.accentColor),
//                       const SizedBox(width: 6),
//                       _StatChip(
//                           icon: Icons.data_usage_rounded,
//                           label: 'Credits',
//                           value: plan.credits,
//                           color: plan.accentColor),
//                       const SizedBox(width: 6),
//                       _StatChip(
//                           icon: Icons.local_offer_rounded,
//                           label: 'Price',
//                           value: plan.displayPrice,
//                           color: plan.accentColor),
//                     ],
//                   ),
//                 ),

//                 // ── Features (flex) ────────────
//                 Expanded(
//                   child: Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text('Features',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w700,
//                               fontSize: 12.5,
//                               color: Color(0xFF1A1A2E),
//                             )),
//                         const SizedBox(height: 5),
//                         ...plan.features.take(4).map(
//                               (f) => Padding(
//                                 padding:
//                                     const EdgeInsets.only(bottom: 4),
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.check_circle_rounded,
//                                         size: 13,
//                                         color: plan.accentColor),
//                                     const SizedBox(width: 6),
//                                     Expanded(
//                                       child: Text(f,
//                                           style: const TextStyle(
//                                               fontSize: 11.5,
//                                               color:
//                                                   Color(0xFF444466))),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                         if (plan.features.length > 4)
//                           Text(
//                             '+ ${plan.features.length - 4} more features...',
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: plan.accentColor,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // ── CTA button ─────────────────
//                 Padding(
//                   padding:
//                       const EdgeInsets.fromLTRB(14, 4, 14, 14),
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: onTap,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: plan.accentColor,
//                         foregroundColor: Colors.white,
//                         padding:
//                             const EdgeInsets.symmetric(vertical: 13),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             plan.price == 'FREE'
//                                 ? 'Get Started'
//                                 : 'View Plan',
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 14),
//                           ),
//                           const SizedBox(width: 6),
//                           const Icon(
//                               Icons.arrow_forward_ios_rounded,
//                               size: 12),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }

// // ─────────────────────────────────────────────
// //  BILLING TOGGLE (Monthly / Yearly)
// // ─────────────────────────────────────────────
// class _BillingToggle extends StatelessWidget {
//   final List<BillingOption> options;
//   final int selectedIndex;
//   final Color accentColor;
//   final ValueChanged<int> onChanged;

//   const _BillingToggle({
//     required this.options,
//     required this.selectedIndex,
//     required this.accentColor,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: accentColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       padding: const EdgeInsets.all(3),
//       child: Row(
//         children: List.generate(options.length, (i) {
//           final selected = i == selectedIndex;
//           return Expanded(
//             child: GestureDetector(
//               onTap: selected ? null : () => onChanged(i),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 decoration: BoxDecoration(
//                   color: selected ? accentColor : Colors.transparent,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       options[i].label,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w800,
//                         color: selected ? Colors.white : accentColor,
//                       ),
//                     ),
//                     const SizedBox(height: 1),
//                     Text(
//                       options[i].displayPrice,
//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                         color: selected
//                             ? Colors.white.withOpacity(0.9)
//                             : accentColor.withOpacity(0.7),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  STAT CHIP
// // ─────────────────────────────────────────────
// class _StatChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color color;
//   const _StatChip(
//       {required this.icon,
//       required this.label,
//       required this.value,
//       required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding:
//             const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.07),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, size: 14, color: color),
//             const SizedBox(height: 3),
//             Text(value,
//                 style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w800,
//                     color: color),
//                 textAlign: TextAlign.center,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis),
//             Text(label,
//                 style: const TextStyle(
//                     fontSize: 9, color: Color(0xFF888AAA))),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  DETAIL BOTTOM SHEET
// // ─────────────────────────────────────────────
// class _PlanDetailSheet extends StatelessWidget {
//   final PricingPlan plan;
//   final VoidCallback onBillingChanged;
//   const _PlanDetailSheet({required this.plan, required this.onBillingChanged});

//   void _handleOrganisationContact(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'Contact Us',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             _ContactOption(
//               icon: Icons.email,
//               title: 'Email',
//               subtitle: 'support@arthumai.com',
//               color: Colors.red,
//               onTap: () async {
//                 final Uri emailUri = Uri(
//                   scheme: 'mailto',
//                   path: 'support@arthumai.com',
//                   query: 'subject=Organisation Plan Enquiry',
//                 );
//                 if (await canLaunchUrl(emailUri)) {
//                   await launchUrl(emailUri);
//                 }
//               },
//             ),
//             _ContactOption(
//               icon: Icons.description,
//               title: 'Contact Form',
//               subtitle: 'Fill out our contact form',
//               color: Colors.blue,
//               onTap: () {
//                 Navigator.pop(context);
//                 // TODO: Open contact form
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.88,
//       minChildSize: 0.5,
//       maxChildSize: 0.95,
//       expand: false,
//       builder: (_, sc) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius:
//                 BorderRadius.vertical(top: Radius.circular(28)),
//           ),
//           child: Column(
//             children: [
//               // Handle
//               Container(
//                 margin: const EdgeInsets.only(top: 12, bottom: 4),
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFDDDDEE),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               Expanded(
//                 child: SingleChildScrollView(
//                   controller: sc,
//                   padding:
//                       const EdgeInsets.fromLTRB(24, 16, 24, 40),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Header
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(14),
//                             decoration: BoxDecoration(
//                               color: plan.accentColor,
//                               borderRadius:
//                                   BorderRadius.circular(16),
//                             ),
//                             child: Icon(plan.icon,
//                                 color: Colors.white, size: 24),
//                           ),
//                           const SizedBox(width: 14),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment:
//                                   CrossAxisAlignment.start,
//                               children: [
//                                 Text(plan.name.toUpperCase(),
//                                     style: TextStyle(
//                                         color: plan.accentColor,
//                                         fontSize: 20,
//                                         fontWeight:
//                                             FontWeight.w900)),
//                                 Text(plan.tagline,
//                                     style: const TextStyle(
//                                         fontSize: 11.5,
//                                         color: Color(0xFF666688),
//                                         height: 1.4)),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),

//                       // Stats
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: plan.bgColor,
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Row(
//                           children: [
//                             _DetailInfo(
//                                 label: 'Validity',
//                                 value: plan.validity,
//                                 icon: Icons.calendar_today_rounded,
//                                 color: plan.accentColor),
//                             _vDivider(),
//                             _DetailInfo(
//                                 label: 'Credits',
//                                 value: plan.credits,
//                                 icon: Icons.data_usage_rounded,
//                                 color: plan.accentColor),
//                             _vDivider(),
//                             _DetailInfo(
//                                 label: 'Price',
//                                 value: plan.displayPrice,
//                                 icon: Icons.local_offer_rounded,
//                                 color: plan.accentColor),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),

//                       // ── Billing toggle (Individual only) ──
//                       if (plan.billingOptions.isNotEmpty) ...[
//                         _BillingToggle(
//                           options: plan.billingOptions,
//                           selectedIndex: plan.selectedBillingIndex,
//                           accentColor: plan.accentColor,
//                           onChanged: (index) {
//                             plan.selectedBillingIndex = index;
//                             onBillingChanged();
//                           },
//                         ),
//                         const SizedBox(height: 20),
//                       ],

//                       // Features heading
//                       Text('All Features',
//                           style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w800,
//                               color: plan.accentColor)),
//                       const SizedBox(height: 4),
//                       Container(
//                           height: 2,
//                           width: 40,
//                           decoration: BoxDecoration(
//                               color: plan.accentColor,
//                               borderRadius:
//                                   BorderRadius.circular(2))),
//                       const SizedBox(height: 14),

//                       // Features list
//                       ...plan.features.map((f) => Container(
//                             margin:
//                                 const EdgeInsets.only(bottom: 8),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 14, vertical: 11),
//                             decoration: BoxDecoration(
//                               color: plan.bgColor,
//                               borderRadius:
//                                   BorderRadius.circular(12),
//                             ),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(4),
//                                   decoration: BoxDecoration(
//                                       color: plan.accentColor,
//                                       shape: BoxShape.circle),
//                                   child: const Icon(Icons.check,
//                                       size: 10,
//                                       color: Colors.white),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                     child: Text(f,
//                                         style: const TextStyle(
//                                             fontSize: 13,
//                                             color:
//                                                 Color(0xFF333355),
//                                             fontWeight:
//                                                 FontWeight.w500))),
//                               ],
//                             ),
//                           )),
//                       const SizedBox(height: 20),

//                       // CTA
//                       if (plan.id == 'organisation')
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               final navigator = Navigator.of(context);
//                               final parentContext = navigator.context;
//                               navigator.pop();
                              
//                               Future.delayed(
//                                 const Duration(milliseconds: 250),
//                                 () {
//                                   _handleOrganisationContact(parentContext);
//                                 },
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: plan.accentColor,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                   vertical: 15),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius:
//                                       BorderRadius.circular(16)),
//                               elevation: 0,
//                             ),
//                             child: const Text(
//                               'Contact Sales Team',
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w800,
//                                   fontSize: 15),
//                             ),
//                           ),
//                         )
//                       else
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               final navigator = Navigator.of(context);
//                               navigator.pop();
                              
//                               if (plan.price == 'FREE') {
//                                 final messenger = ScaffoldMessenger.of(context);
//                                 Future.delayed(
//                               const Duration(milliseconds: 250),
//                                   () async {
//                                     final token =
//                                         await SessionService.getAuthToken();
//                                     if (token == null) {
//                                       messenger.showSnackBar(
//                                         const SnackBar(
//                                           content: Text('Login required'),
//                                         ),
//                                       );
//                                       return;
//                                     }

//                                     final url =
//                                         '${ApiConstants.authUrl}/api/pricing/activate-free-plan';

//                                     final res = await http.post(
//                                       Uri.parse(url),
//                                       headers: {
//                                         'Authorization': 'Bearer $token',
//                                         'Content-Type': 'application/json',
//                                       },
//                                     );

//                                     final body = res.body.isNotEmpty
//                                         ? (jsonDecode(res.body) as Map<String, dynamic>)
//                                         : <String, dynamic>{};

//                                     if (res.statusCode == 200 &&
//                                         body['success'] == true) {
//                                       messenger.showSnackBar(
//                                         const SnackBar(
//                                           content: Text(
//                                               '1000 credits added successfully'),
//                                           backgroundColor: Colors.green,
//                                         ),
//                                       );

//                                       if (!context.mounted) return;
// Navigator.pushAndRemoveUntil(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => const HomeScreen(),
//                                         ),
//                                         (route) => false,
//                                       );
//                                     } else {
//                                       messenger.showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             body['message'] ??
//                                                 'Free trial already used',
//                                           ),
//                                           backgroundColor: Colors.redAccent,
//                                         ),
//                                       );
//                                     }
//                                   },
//                                 );
//                               } else {
//                                 Future.delayed(
// const Duration(milliseconds: 250),
//                                   () {
//                                     navigator.push(
//                                       MaterialPageRoute(
//                                         builder: (_) => CheckoutScreen(
//                                           plan: plan,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 );
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: plan.accentColor,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                   vertical: 15),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius:
//                                       BorderRadius.circular(16)),
//                               elevation: 0,
//                             ),
//                             child: Text(
//                               plan.price == 'FREE'
//                                   ? 'Get Started Now'
//                                   : 'Choose This Plan',
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.w800,
//                                   fontSize: 15),
//                             ),
//                           ),
//                         ),

//                       if (plan.id == 'organisation') ...[
//                         const SizedBox(height: 10),
//                         Center(
//                           child: Text(
//                             'Drop your query at support@arthumai.com\nOur senior CRM team will reach out to you.',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                                 fontSize: 11.5,
//                                 color: Colors.grey.shade500,
//                                 height: 1.6),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _vDivider() => Container(
//         height: 40,
//         width: 1,
//         color: Colors.white.withOpacity(0.6),
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//       );
// }

// // ─────────────────────────────────────────────
// //  DETAIL INFO
// // ─────────────────────────────────────────────
// class _DetailInfo extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color color;
//   const _DetailInfo(
//       {required this.label,
//       required this.value,
//       required this.icon,
//       required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Column(
//         children: [
//           Icon(icon, size: 18, color: color),
//           const SizedBox(height: 4),
//           Text(value,
//               style: TextStyle(
//                   fontWeight: FontWeight.w800,
//                   fontSize: 12,
//                   color: color),
//               textAlign: TextAlign.center,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis),
//           Text(label,
//               style: const TextStyle(
//                   fontSize: 10, color: Color(0xFF888AAA))),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  CONTACT OPTION WIDGET
// // ─────────────────────────────────────────────
// class _ContactOption extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final Color color;
//   final VoidCallback onTap;

//   const _ContactOption({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: color.withOpacity(0.1),
//         child: Icon(icon, color: color),
//       ),
//       title: Text(title),
//       subtitle: Text(subtitle),
//       onTap: onTap,
//     );
//   }
// }