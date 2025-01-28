import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/user_repo.dart';
import '../../constants/analytics.dart';
import '../../pages/activity/controller/activity_controller.dart';
import '../../pages/activity/model/activities_model.dart';
import '../../widgets/jazz_card_widget.dart';
import '../../widgets/master_card.dart';
import '../../widgets/sticky_header_widget.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Analytics.yourActivitiesScreenDisplayed();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        title: const Text('Activities'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).primaryColor,
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadiusDirectional.only(
              topEnd: Radius.circular(15),
              topStart: Radius.circular(15),
            ),
          ),
          child: GetX<ActivityContorller>(
            init: ActivityContorller(UserRepo()),
            builder: (controller) {
              final jazzcashData = controller.activitiesModel.value.jazzcashData;
              final cardData = controller.activitiesModel.value.cardData;
              final transData = controller.activitiesModel.value.transData;

              return CustomScrollView(
                slivers: [
                  // Sticky Header
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverHeaderDelegate(
                      child: _buildSavedCardsHeader(context),
                      minHeight: 30,
                      maxHeight: 50,
                    ),
                  ),
                  // Rest of the scrollable content
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _buildJazzcashCardSection(jazzcashData, context),
                        _buildDebitCardSection(cardData, context),
                        _buildActivitiesList(transData, context),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSavedCardsHeader(BuildContext context) {
    return Container(
      
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.credit_card, size: 25),
          const SizedBox(width: 5),
          Text(
            'Saved Cards/ Wallets',
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildJazzcashCardSection(List<JazzcashData>? jazzcashData, BuildContext context) {
    if (jazzcashData?.isNotEmpty ?? false) {
      return SizedBox(
        height: 120,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              jazzcashData?.length ?? 0,
              (index) => JazzCardWidget(
                jazzcardNumber: jazzcashData?[index].cardNumber ?? '',
                isActive: jazzcashData?[index].isActive ?? '',
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildDebitCardSection(List<CardDataX>? cardData, BuildContext context) {
    if (cardData?.isNotEmpty ?? false) {
      return SizedBox(
        height: MediaQuery.of(context).size.height / 4.9,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              cardData?.length ?? 0,
              (index) => MediaQuery.of(context).size.height > 680
                  ? DebitCard(
                      brandName: cardData?[index].brand,
                      isActivity: true,
                      issuer: cardData?[index].issuer,
                      cardNumber: cardData?[index].cardNumber,
                      fundinMethod: cardData?[index].fundingMethod,
                      expire: cardData?[index].expiry,
                    )
                  : SizedBox(
                      child: DebitCardSmall(
                        brandName: cardData?[index].brand,
                        isActivity: true,
                        issuer: cardData?[index].issuer,
                        cardNumber: cardData?[index].cardNumber,
                        fundinMethod: cardData?[index].fundingMethod,
                        expire: cardData?[index].expiry,
                      ),
                    ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActivitiesList(List<TransData>? transData, BuildContext context) {
    if (transData != null && transData.isNotEmpty) {
      return ActivitiesListView(activitiesModel: transData);
    }
    return const Center(child: Text('No Activities Found!'));
  }
}

class ActivitiesListView extends StatelessWidget {
  final List<TransData>? activitiesModel;

  const ActivitiesListView({super.key, required this.activitiesModel});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: activitiesModel?.length,
      itemBuilder: (context, index) {
        final transaction = activitiesModel?[index];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                horizontalTitleGap: 8.0,
                leading: const Icon(
                  Icons.receipt_outlined,
                  size: 45,
                  color: Colors.grey,
                ),
                title: Text(
                  'Recharge ${transaction?.logDate ?? ''}',
                  style: Theme.of(context).listTileTheme.titleTextStyle,
                ),
                trailing: Text(
                  'PKR ${transaction?.amount ?? ''}/-',
                  style: Theme.of(context).listTileTheme.titleTextStyle?.copyWith(
                        color: Colors.green,
                      ),
                ),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction?.orderId ?? '',
                      style: Theme.of(context).listTileTheme.titleTextStyle?.copyWith(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction?.cardNumber ?? '',
                      style: Theme.of(context)
                          .listTileTheme
                          .titleTextStyle
                          ?.copyWith(color: Colors.redAccent, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              indent: 12,
              endIndent: 12,
              thickness: 0.2,
            ),
          ],
        );
      },
    );
  }
}
