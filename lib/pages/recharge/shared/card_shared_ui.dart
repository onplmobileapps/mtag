import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '/pages/payment/controller/payment_card_controller.dart';
import '/utils/utils.dart';
import '/widgets/textform_widget.dart';
import '../../payment/model/payment_card_model.dart';

// Global ValueNotifiers (consider moving to a state management solution if app scales)
final ValueNotifier<bool> isJazzShown = ValueNotifier(false);
final ValueNotifier<bool> isCardsVisible = ValueNotifier(false);

class CardSharedUi extends StatelessWidget {
  const CardSharedUi({
    super.key,
    this.paymentHead,
    this.mtagId,
    this.amount,
    this.loading = false,
    this.payId,
    this.cardListData = const [],
  });

  final String? paymentHead;
  final String? mtagId;
  final String? amount;
  final bool loading;
  final int? payId;
  final List<CardsData> cardListData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CardListSection(
          paymentHead: paymentHead,
          loading: loading,
          payId: payId,
          cardListData: cardListData,
          mtagId: mtagId,
          amount: amount,
        ),
        _JazzCashInputSection(
          mtagId: mtagId,
          amount: amount,
        ),
      ],
    );
  }
}

// Card List Section
class _CardListSection extends StatelessWidget {
  const _CardListSection({
    this.paymentHead,
    required this.loading,
    this.payId,
    this.cardListData = const [],
    this.mtagId,
    this.amount,
  });

  final String? paymentHead;
  final bool loading;
  final int? payId;
  final List<CardsData> cardListData;
  final String? mtagId;
  final String? amount;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isCardsVisible,
      builder: (context, isVisible, _) {
        if (!isVisible) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (paymentHead != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  paymentHead!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            _CardCarousel(
              loading: loading,
              payId: payId,
              cardListData: cardListData,
              mtagId: mtagId,
              amount: amount,
            ),
          ],
        );
      },
    );
  }
}

// Card Carousel with Scroll Controls
class _CardCarousel extends StatelessWidget {
  _CardCarousel({
    required this.loading,
    this.payId,
    this.cardListData = const [],
    this.mtagId,
    this.amount,
  });

  final bool loading;
  final int? payId;
  final List<CardsData> cardListData;
  final String? mtagId;
  final String? amount;

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ScrollButton(
          icon: Icons.keyboard_arrow_left,
          offset: -100,
          controller: _scrollController,
        ),
        Expanded(
          child: SizedBox(
            height: 100, // Fixed height for consistency
            child: loading
                ? Center(
                    child: LoadingAnimationWidget.flickr(
                      leftDotColor: Colors.white,
                      rightDotColor: Theme.of(context).primaryColor,
                      size: 30,
                    ),
                  )
                : ListView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _AddNewCardTile(
                        payId: payId,
                        mtagId: mtagId,
                        amount: amount,
                      ),
                      ...cardListData.map(
                        (card) => _CardTile(
                          card: card,
                          payId: payId,
                          mtagId: mtagId,
                          amount: amount,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        _ScrollButton(
          icon: Icons.keyboard_arrow_right,
          offset: 100,
          controller: _scrollController,
        ),
      ],
    );
  }
}

// Scroll Button Widget
class _ScrollButton extends StatelessWidget {
  const _ScrollButton({
    required this.icon,
    required this.offset,
    required this.controller,
  });

  final IconData icon;
  final double offset;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Check if the controller is attached to a scrollable widget
        if (controller.hasClients) {
          // Ensure the scroll position is valid before animating
          final currentOffset = controller.offset;
          final maxScrollExtent = controller.position.maxScrollExtent;
          final minScrollExtent = controller.position.minScrollExtent;

          // Calculate new offset and clamp it within bounds
          final newOffset = (currentOffset + offset).clamp(minScrollExtent, maxScrollExtent);

          controller.animateTo(
            newOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Transform.translate(
        offset: const Offset(0, -25),
        child: Icon(icon),
      ),
    );
  }
}

// Add New Card Tile
class _AddNewCardTile extends StatelessWidget {
  const _AddNewCardTile({
    this.payId,
    this.mtagId,
    this.amount,
  });

  final int? payId;
  final String? mtagId;
  final String? amount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        log('payId: $payId');
        final controller = Get.find<PaymentCardController>();
        if (payId == 2) {
          _toggleJazzCashVisibility();
        } else {
          await controller.getRechargeSummary(
            isFleet: false,
            mtagId: mtagId ?? '',
            payId: payId == 1 ? '0' : '1',
            amount: amount ?? '0',
          );
          isJazzShown.value = false;
        }
      },
      child: _CardContainer(
        label: 'Add New +',
        labelColor: Colors.green,
        child: SvgPicture.asset(
          payId == 2 ? 'assets/jazzcash.svg' : 'assets/addnew.svg',
          height: 15,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

// Card Tile
class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.card,
    this.payId,
    this.mtagId,
    this.amount,
  });

  final CardsData card;
  final int? payId;
  final String? mtagId;
  final String? amount;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentCardController>();
    return GestureDetector(
      onTap: () async => await controller.getRechargeSummary(
        isFleet: false,
        token: card.tOKEN,
        mtagId: mtagId ?? '',
        payId: payId == 1 ? '0' : '1',
        amount: amount ?? '0',
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _CardContainer(
            label: 'Ends ${maskString(card.cARDNUMBER ?? '')}',
            child: SvgPicture.asset(
              payId == 2
                  ? 'assets/jazzcash.svg'
                  : card.bRAND == 'MASTERCARD'
                      ? 'assets/mastercard.svg'
                      : 'assets/visa-logo.svg',
              height: 20,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: -8,
            right: -8,
            child: _DeleteButton(
              onDelete: () => _showDeleteDialog(context, card, controller),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, CardsData card, PaymentCardController controller) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text(
          'Are you sure you want to delete this card?\nThis action cannot be undone.',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () async {
              Get.back();
              await controller.deleteCardDetails(
                token: card.tOKEN ?? '',
                payId: payId == 1 ? '0' : '1',
              );
          
            },
            child: const Text('Confirm'),
          ),
          CupertinoDialogAction(
            onPressed: Get.back,
            isDestructiveAction: true,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// Reusable Card Container
class _CardContainer extends StatelessWidget {
  const _CardContainer({
    required this.child,
    required this.label,
    this.labelColor = Colors.black,
  });

  final Widget child;
  final String label;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 0.2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Center(child: child),
        ),
        Padding(
          padding: const EdgeInsets.all(2),
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: labelColor),
          ),
        ),
      ],
    );
  }
}

// Delete Button
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDelete,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
          ],
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 16),
      ),
    );
  }
}

// JazzCash Input Section
class _JazzCashInputSection extends StatelessWidget {
  _JazzCashInputSection({this.mtagId, this.amount});

  final String? mtagId;
  final String? amount;
  final TextEditingController _jazzCashController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isJazzShown,
      builder: (context, isVisible, _) {
     
        return Visibility(visible: isVisible,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/jazzcash.svg', height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('JazzCash', style: Theme.of(context).textTheme.titleSmall),
                        Text(
                          'JazzCash Account is required',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              CustomTExtField(
                hint: 'Enter JazzCash Account Number',
                maxLength: 11,keyboardType: TextInputType.numberWithOptions(signed: true),
                validator: validateJazzcashNumber,inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _jazzCashController,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                onEditingComplete: () async {
                  if (validateJazzcashNumber(_jazzCashController.text) != null ||
                      mtagId == null ||
                      mtagId!.length < 8) {
                    return;
                  }
                  await Get.find<PaymentCardController>().getRechargeSummary(
                    isFleet: false,
                    mtagId: mtagId!,
                    payId: '1',
                    amount: amount ?? '',
                    token: _jazzCashController.text.trim(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Helper to toggle visibility states
void _toggleJazzCashVisibility() {
  isJazzShown.value = true;
  isCardsVisible.value = false;
}