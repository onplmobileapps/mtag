import 'package:flutter/material.dart';

// ── COLORS ──────────────────────────────────────────────────────────────────────
const kPrimaryGreen = Color(0xFF4CAF83);
const kLightGreen = Color(0xFF2FA36B);
const kDarkGreen = Color(0xFF2C2E65); // used for recharge button
const kLightBg = Color(0xFFFFFFFF);
const kCardBg = Colors.white;
const kMutedText = Color(0xFF8E99A5);
const kWarning = Color(0xFFFF9800);

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
    return Scaffold(appBar: AppBar(backgroundColor: Colors.transparent,elevation: 0,
      title:  Image.asset("assets/logolight.png", height: 50, width: 50),),
      backgroundColor: kLightBg,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          kScreenPaddingHorizontal,
          kScreenPaddingTop,
          kScreenPaddingHorizontal,
          kScreenPaddingBottom,
        ),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
           
            SizedBox(height: 10),
            const VehicleCard(),
      
            Transform.translate(
              offset: const Offset(0, kBalanceOverlapVehicle),
              child: const BalanceCard(),
            ),
      
           
      
            Transform.translate(
              offset: const Offset(0, kActionGridOverlapQuick),
              child: const ActionGrid(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── VEHICLE CARD ────────────────────────────────────────────────────────────────
class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kVehicleCardHeight,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: const LinearGradient(
          colors: [Color(0xFFE4EDFC), Color(0xFFFCFCFC), Color(0xFFEAEBFD)],
        ),
      ),
      child: Row(
        mainAxisAlignment: .start,
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 60,left: 10),
            child: Align(alignment: .center,
              child: Image.asset(
                'assets/vehicles/car.png',
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 110),
                  child: _ActiveBadge(),
                ),
                const SizedBox(height: 12),
                Text(
                  'Honda Civic 2022',
                  textAlign: .start,
                  style: TextStyle(
                    fontFamily: "biotifbold",
                    fontSize: 17,
                    color: Colors.black87,
                    fontWeight: .w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: .start,
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'LEF-3574',
                      style: TextStyle(
                        fontFamily: 'biotifbold',
                        fontWeight: .w900,
                      ),
                    ),
                    Text(
                      '• M-TAG ',
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'biotifbold',
                      ),
                    ),
                    Text(
                      '#14639258',
                      style: TextStyle(
                        fontFamily: 'biotifbold',
                        fontWeight: .w900,
                      ),
                    ),
                  ],
                ),

                Container(
                  margin: .symmetric(vertical: 10),
                  height: 1,
                  width: 180,
                  color: Colors.grey.shade300,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.person_4_rounded,
                      color: Colors.green.shade400,
                      size: 20,
                    ),
                    Text(
                      'Owner:',
                      style: TextStyle(
                        fontFamily: 'biotifbold',
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const Text(
                      ' Ahmed Hassan',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'biotifbold',
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
        color: Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: Colors.green, size: 16),
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

// ── BALANCE CARD ────────────────────────────────────────────────────────────────
class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFCFCFC),
            Color(0xFFF8F6FF),
            Color(0xFFE6EBFF),
            Color(0xFFD9E5FF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
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
          SizedBox(height: 8), // ← was 28 → good balance before button
          Card(
            borderOnForeground: true,
            shape: RoundedSuperellipseBorder(borderRadius: .circular(50)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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

// ── RECHARGE BUTTON ──────────────────────────────────────────────────────────────
class _RechargeButton extends StatelessWidget {
  const _RechargeButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(colors: [kDarkGreen, Color(0xFF1E214F)]),
        boxShadow: [
          BoxShadow(
            color: kDarkGreen.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () {},
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_rounded, size: 26, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Recharge M-TAG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    fontFamily: 'biotifbold',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── TRANSFER / REMOVE CAPSULE ───────────────────────────────────────────────────
class _TransferRemoveRow extends StatelessWidget {
  const _TransferRemoveRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
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
                fontSize: 22,
                fontWeight: FontWeight.w100,
                color: Colors.grey.shade200,
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
    final color = Colors.black87.withValues(alpha: 0.4);

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
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── QUICK INSIGHTS ──────────────────────────────────────────────────────────────
class QuickInsightsCard extends StatelessWidget {
  const QuickInsightsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: .circular(14),

        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFCFCFC),
            Color(0xFFFCFCFC),
            Color(0xFFF8F6FF),
            Color(0xFFF8F6FF),
            Color(0xFFE6EBFF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Quick Insights',
                style: TextStyle(
                  fontSize: 17.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'biotifbold',
                ),
              ),
              Spacer(),
              Icon(Icons.chevron_right_rounded, color: kMutedText),
            ],
          ),
          const SizedBox(height: 16),
          _lastTriptRow(Icons.schedule, 'Islamabad → Lahore'),
          const SizedBox(height: 14),
          _lastTollRow(Icons.payments_rounded, 'Rs. 50 '),
        ],
      ),
    );
  }

  Widget _lastTriptRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: kMutedText.withValues(alpha: 0.9)),
        const SizedBox(width: 12),
        Text('Last Trip :', style: TextStyle(color: Colors.black54)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.3,
              color: Colors.black,
              fontFamily: 'biotifbold',
            ),
          ),
        ),
      ],
    );
  }
}

Widget _lastTollRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 20, color: kMutedText.withValues(alpha: 0.9)),
      const SizedBox(width: 12),
      Text('Last Toll : ', style: TextStyle(color: Colors.black54)),
      const SizedBox(width: 12),
      Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.3,
          fontFamily: 'biotifbold',
          color: Colors.black,
        ),
      ),
      Text('• Yesterday', style: TextStyle(color: Colors.black45)),
    ],
  );
}

// ── ACTION GRID ─────────────────────────────────────────────────────────────────
class ActionGrid extends StatelessWidget {
  const ActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionTile('M-TAG Details', 'assets/icons/receipt.png'),
            ),
            SizedBox(width: kActionGridColumnGap),
            Expanded(
              child: _ActionTile('Toll History', 'assets/icons/history.png'),
            ),
          ],
        ),
        SizedBox(height: kActionGridRowGap),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                'Toll Calculator',
                'assets/icons/calculator.png',
              ),
            ),
            SizedBox(width: kActionGridColumnGap),
            Expanded(
              child: _ActionTile('Recharge', 'assets/icons/recharge1.png'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String imagePath;

  const _ActionTile(this.title, this.imagePath);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFCFCFC), Color(0xFFEAEBFD)],
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
              imagePath,
              width: 38,
              height: 38,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
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
