import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mtag_flutterapp/pages/dashboard/home_page.dart';
import 'package:mtag_flutterapp/widgets/elevated_button.dart';

// ── COLORS ──────────────────────────────────────────────────────────────────────

// ── SPACING & LAYOUT CONSTANTS ──────────────────────────────────────────────────
const double kScreenPaddingHorizontal = 16.0;
const double kScreenPaddingTop = 16.0;
const double kScreenPaddingBottom = 40.0;

const double kVehicleCardHeight = 210.0;

// Overlap values - negative = overlap (tuned for modern stacked card design)
const double kBalanceOverlapVehicle = -55.0; // Balance card overlaps Vehicle
const double kQuickInsightsOverlapBalance =
    -50.0; // Quick Insights overlaps Balance strongly
const double kActionGridOverlapQuick =
    -40.0; // Action Grid pulled close to Quick Insights

const double kActionGridRowGap = 14.0;
const double kActionGridColumnGap = 12.0;

// ────────────────────────────────────────────────────────────────────────────────

class MTagScreen extends StatelessWidget {
  const MTagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: .light,
          statusBarIconBrightness: .dark,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset("assets/logolight.png", height: 70, width: 70),
        // toolbarHeight: 0.0,
      ),

      body: CustomScrollView(
        slivers: [
          
           SliverAppBar(
      pinned: true,
      floating: false,expandedHeight: 430,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.none,
        background: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min, // important for dynamic height
            children: const [
              VehicleCard(), // your responsive vehicle card
            ],
          ),
        ),
      ),
    ),

          SliverToBoxAdapter(child: ActionGrid()),
          SliverPadding(
            sliver: SliderSection(),padding: .symmetric(horizontal:8),),
            SliverToBoxAdapter(child: SizedBox(height: 10,),),
          HelpSection(),
          SliverToBoxAdapter(child: SizedBox(height: 50,),)
        ],
      ),
    );
  }
}

// ── VEHICLE CARD ────────────────────────────────────────────────────────────────
class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        return Container(
          margin: .symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: .circular(16),
            gradient: const LinearGradient(
              begin: .topLeft,
              end: AlignmentGeometry.centerRight,
              colors: [Color(0xFFE4EDFC), Color(0xFFFCFCFC), Color(0xFFEAEBFD)],
            ),
          ),
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            crossAxisAlignment: .start,
            children: [
              Row(
                mainAxisAlignment: .start,
                crossAxisAlignment: .start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: 16,
                      left: w * 0.03,
                      bottom: w * 0.025,
                    ),

                    child: Image.asset(
                      'assets/vehicles/car.png',
                      height: w * 0.32,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: .symmetric(horizontal: 10),
                      child: Column(
                        mainAxisAlignment: .start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.end, // pushes badge to right
                            children: [
                              Padding(
                                padding: .only(right: 8, top: 8),
                                child: _ActiveBadge(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.topLeft,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'LEF-3574', // first part
                                    style: TextStyle(
                                      fontFamily: 'biotifbold',
                                      color: Colors.black, // grey color
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  TextSpan(
                                    text: ' • M-TAG ', // rest of text
                                    style: TextStyle(
                                      fontFamily: 'biotifbold',
                                      color: Colors.grey, // black color
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' #14639258', // rest of text
                                    style: TextStyle(
                                      fontFamily: 'biotifbold',
                                      color: Colors.black87, // black color
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.grey.shade300,
                            thickness: 1.5,
                            indent: 1,
                            endIndent: 10,
                          ),
                          FittedBox(
                            child: Row(
                              mainAxisAlignment: .start,
                              crossAxisAlignment: .start,
                              children: [
                                Icon(
                                  Icons.person_2,
                                  color: Colors.green.shade400,
                                  size: 20,
                                ),
                                Text(
                                  'Owner : ',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  'Syed Farooq (Ret)',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'biotifbold',
                                    fontWeight: .w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.grey.shade300,
                            thickness: 1.5,
                            indent: 1,
                            endIndent: 10,
                          ),

                          FittedBox(
                            child: Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Chassis No: ',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'biotifbold',
                                        ),
                                      ),
                                      // Number
                                      TextSpan(
                                        text: '273732BBBB6666',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'biotifbold',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.edit_square, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const BalanceCard(),
            ],
          ),
        );
      },
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: Colors.green, size: 12),
          SizedBox(width: 4),
          Text(
            'ACTIVE',
            style: TextStyle(
              color: Colors.green.shade900,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
              fontFamily: 'biotifbold',
            ),
          ),
        ],
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          end: AlignmentGeometry.xy(0, 3),
          colors: const [
            Color(0xFFFFFFFF),
            Color(0xFFFCFCFC),
            Color(0xFFF8F6FF),
            Color(0xFFD9E5FF),
            Color(0xFFE6EBFF),
            Color(0xFFE6EBFF),
            Color(0xFFE6EBFF),
            Color(0xFFE6EBFF),
            Color(0xFFE6EBFF),

            // fades out
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(4, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(4, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        24,
        20,
        24,
        16,
      ), // ← slightly reduced bottom padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: TextStyle(
                  fontFamily: 'biotifbold',
                  fontSize: 16,
                  color: Colors.black54.withValues(alpha: 0.7),
                ),
              ),
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                child: Icon(
                  Icons.visibility_rounded,
                  color: Colors.black54,
                  size: 17,
                ),
              ),
            ],
          ),
          SizedBox(height: 4), // ← was 6 → tighter
          Text(
            'Rs. 0',
            style: TextStyle(
              fontFamily: "biotifbold",
              fontSize: 42,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              height: 1.0,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 4), // ← was 8 → much tighter
          Row(
            children: [
              Text(
                'Low Balance',
                style: TextStyle(
                  color: Colors.black54,

                  fontSize: 15,
                  fontFamily: 'biotifbold',
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.warning_rounded,
                size: 24,
                color: Colors.yellow.shade800,
              ),
            ],
          ),
        // ← was 28 → good balance before button
          Card(
            elevation: 3,
            borderOnForeground: true,
            shape: RoundedSuperellipseBorder(borderRadius: .circular(50)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
              child: _RechargeButton(),
            ),
          ),
          SizedBox(height: 16), // ← was 20 → tighter before capsule
          _TransferRemoveRow(),
        ],
      ),
    );
  }
}

class _RechargeButton extends StatelessWidget {
  const _RechargeButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton1(
      width: double.infinity,
      onclick: () {},
      text: 'Recharge M-TAG',
      icon: Icon(Icons.add_circle),
      isShowIcon: true,
      iconAlignment: .start,
    );
  }
}

class _TransferRemoveRow extends StatelessWidget {
  const _TransferRemoveRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.swap_horiz_rounded,
              label: 'Transfer',
              onTap: () {}, //
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '|',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w100,
                color: Colors.grey.shade300,
              ),
            ),
          ),
          Expanded(
            child: _ActionButton(
              icon: Icons.delete,
              label: 'Remove',
              isDestructive: true,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.black87.withValues(alpha: 0.5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,

                color: color,
                fontFamily: 'biotifbold',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionGrid extends StatelessWidget {
  const ActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    title: 'M-TAG Details',
                    imagePath: 'assets/icons/receipt.png',
                  ),
                ),
                SizedBox(width: kActionGridColumnGap),
                Expanded(
                  child: _ActionTile(
                    title: 'Toll History',
                    imagePath: 'assets/icons/history.png',
                  ),
                ),
              ],
            ),
            SizedBox(height: kActionGridRowGap),
            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    title: 'Toll Calculator',
                    imagePath: 'assets/icons/calculator1.png',
                    isCalculatorWidget: true,
                  ),
                ),
                SizedBox(width: kActionGridColumnGap),
                Expanded(
                  child: _ActionTile(
                    title: 'Recharge',
                    imagePath: 'assets/icons/card.png',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String? title;
  final String? imagePath;
  final bool? isCalculatorWidget;
  const _ActionTile({
    this.title,
    this.imagePath,
    this.isCalculatorWidget = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: AlignmentGeometry.xy(-1.1, 0.9),
          end: Alignment(-1.0, 2.0),
          // bottom-left
          colors: (isCalculatorWidget == false)
              ? [Color(0xffFFFCFC), Color(0xffD9EDF8), Color(0xffE4EBF5)]
              : [Color(0xFFFFFEF8), Color(0xFFFFF9E5), Color(0xFFFFF2B8)],
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(1, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(4, 1),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,

            alignment: Alignment.center,
            child: Image.asset(
              imagePath ?? '',
              width: 38,
              height: 38,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title ?? '',
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
