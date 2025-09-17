import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mtag_flutterapp/api/user_repo.dart';
import 'package:mtag_flutterapp/constants/analytics.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';

import '../../pages/receipt/controller/receipt_generate_controller.dart';
import '../../pages/tollhistory/controller/tollcontroller.dart';

class TollHistoryPage extends StatefulWidget {
  const TollHistoryPage({super.key});

  @override
  State<TollHistoryPage> createState() => _TollHistoryPageState();
}

class _TollHistoryPageState extends State<TollHistoryPage> {
  final _receiptController = Get.find<ReceiptController>();
  final isLoading = false.obs;
  final startDate = DateTime.now().obs;
  final endDate = DateTime.now().obs;

  void onListTileTap(arguments) async {
    if (arguments.cR == 'P') {
      return;
    }
    _receiptController.chechTravel(arguments.cR == '-');
    await _receiptController.getrechargeDetails(
      cr: arguments.cR,
      uID: arguments.uID,
      itoken: arguments.iTOKKENNO,
    );
    await Get.toNamed('/receipt', arguments: arguments.cR == '-');
  }

  Future<void> getTollHistory() async {
    try {
      isLoading.value = true;
      await Get.find<TollController>().geTollHistory();
      isLoading.value = false;
    } catch (e) {
      isLoading(false);
      throw Exception(e);
    } finally {
      isLoading(false);
    }
  }

  @override
  void initState() {
    super.initState();
    getTollHistory();
  }

  @override
  void dispose() {
    Get.find<TollController>().isSlected(0);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Analytics.historyScreenDisplayed();
    return Scaffold(
      appBar: AppBar(title: const Text('Toll History')),
      body: Column(
        children: [
          _buildStickyMessage(context),
          Expanded(
            child: Obx(
              () => isLoading.value
                  ? Center(
                      child: LoadingAnimationWidget.flickr(
                        leftDotColor: Theme.of(context).primaryColor,
                        rightDotColor: Colors.white,
                        size: 35.0,
                      ),
                    )
                  : GetX<TollController>(
                      init: TollController(userRepo: UserRepo()),
                      builder: (controller) =>
                          _buildTollHistoryContent(controller),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTollHistoryContent(TollController controller) {
    return Container(
      height: MediaQuery.sizeOf(context).height,
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        height: MediaQuery.sizeOf(context).height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChip(controller, 'All', 0, ''),
                      const SizedBox(width: 5),
                      _buildChip(controller, 'Recharge', 1, '+'),
                      const SizedBox(width: 5),
                      _buildChip(controller, 'Travel', 2, '-'),
                      //coming soon
                      const SizedBox(width: 5),
                      _buildChip(controller, 'CDA-Parking', 3, 'P'),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  (controller.searchList == [] ||
                      controller.searchList!.isEmpty)
                  ? const Center(child: Text('No Record Found!'))
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            BuildContext context,
                            int index,
                          ) {
                            final item = controller.searchList?[index];
                            return _buildListTile(item);
                          }, childCount: controller.searchList?.length),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(
    TollController controller,
    String label,
    int value,
    String searchData,
  ) {
    return InkWell(
      onTap: () async {
        controller.isSlected.value = value;
        controller.serchData(searchData);
        if (value == 2) {
          Get.find<ReceiptController>().chechTravel(true);
        }
      },
      child: Chip(
        label: Text(label),
        labelStyle: TextStyle(
          color: controller.isSlected.value == value
              ? Colors.white
              : Theme.of(context).highlightColor,
        ),
        backgroundColor: controller.isSlected.value == value
            ? primarSwatch
            : Theme.of(context).disabledColor,
        side: const BorderSide(color: Colors.black12),
      ),
    );
  }

  Widget _buildListTile(dynamic item) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        tileColor: Theme.of(context).listTileTheme.tileColor,
        minVerticalPadding: 6,
        onTap: () => onListTileTap(item),
        title: Text(
          textAlign: TextAlign.left,
          '${item?.eNTRYSTATIONNAME ?? ''}${item?.eXITSTATIONNAME != null ? ' - ' : ''}${item?.eXITSTATIONNAME ?? ''}',
        ),
        trailing: _buildTrailingColumn(item),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('M-TAG ${item?.iTOKKENNO ?? ''}'),
            Text(
              item?.tRANSTIME ?? '',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailingColumn(item) {
    final String? cR = item?.cR;

    late final Color color;
    late final String label;

    if (cR == '-') {
      color = Colors.redAccent;
      label = 'Travel';
    } else if (cR == 'P') {
      color = Colors.redAccent;
      label = 'Parking';
    } else {
      color = Colors.green;
      label = 'Recharge';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          cR == 'P' ? 'Rs. ${item?.fARE ?? ''}' : '$cR Rs. ${item?.fARE ?? ''}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}

Widget _buildStickyMessage(BuildContext context) {
  return Container(
    margin: EdgeInsets.all(5),
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      color: Colors.yellow.shade100,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.campaign, color: Theme.of(context).primaryColor),
            Text(
              'Announcement',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                'The history section displays only M-Tag transactions, cash transactions are not included.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
