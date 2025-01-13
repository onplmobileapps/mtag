import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mtag_flutterapp/api/user_repo.dart';
import 'package:mtag_flutterapp/constants/analytics.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';
import '../../constants/auth_utils.dart';
import '../../pages/receipt/controller/receipt_generate_controller.dart';
import '../../pages/tollhistory/controller/tollcontroller.dart';
import '../../widgets/elevated_button.dart';
import '../../widgets/date_picker.dart';

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
    _receiptController.chechTravel(arguments.cR == '-');
    await _receiptController.getrechargeDetails(cr: arguments.cR, uID: arguments.uID, itoken: arguments.iTOKKENNO);
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
      appBar: AppBar(
        title: const Text('Toll History'),
        actions: [
          InkWell(
            onTap: () => _showFilterDialog(context),
            child: Image.asset(
              'assets/filter.png',
              height: 20,
              width: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Obx(
        () => isLoading.value
            ? Center(
                child: LoadingAnimationWidget.flickr(
                    leftDotColor: Theme.of(context).primaryColor, rightDotColor: Colors.white, size: 35.0))
            : GetX<TollController>(
                init: TollController(userRepo: UserRepo()),
                builder: (controller) => _buildTollHistoryContent(controller),
              ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        elevation: 0.0,
        actionsAlignment: MainAxisAlignment.spaceAround,
        title: const Center(
          child: Text(
            'Toll History Filter',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', textScaler: TextScaler.noScaling),
          ),
          ElevatedButton1(
            width: 90,
            text: 'Apply',
            onclick: () async {
              Get.back(closeOverlays: false);
              await Get.find<TollController>().geTollHistory(
                startDate: startDate.value.toString(),
                endDate: endDate.value.toString(),
                pageNo: 1,
              );
            },
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Obx(
          () => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dateView(context, date: startDate, label: 'From', onPress: () async {
                final pickedDate = await showDatePickerDialog(context);
                if (pickedDate != null) startDate.value = pickedDate;
              }),
              _dateView(context, date: endDate, label: 'To', onPress: () async {
                final pickedDate = await showDatePickerDialog(context);
                if (pickedDate != null) endDate.value = pickedDate;
              }),
            ],
          ),
        ),
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
            Padding(
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
                ],
              ),
            ),
            Expanded(
              child: (controller.searchList == [] || controller.searchList!.isEmpty)
                  ? const Center(child: Text('No Record Found!'))
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              final item = controller.searchList?[index];
                              return _buildListTile(item);
                            },
                            childCount: controller.searchList?.length,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(TollController controller, String label, int value, String searchData) {
    return InkWell(
      onTap: () async {
        controller.isSlected.value = value;
        await controller.serchData(searchData);
        if (value == 2) {
          Get.find<ReceiptController>().chechTravel(true);
        }
      },
      child: Chip(
        label: Text(label),
        labelStyle: TextStyle(
          color: controller.isSlected.value == value ? Colors.white : Theme.of(context).highlightColor,
        ),
        backgroundColor: controller.isSlected.value == value ? primarSwatch : Theme.of(context).disabledColor,
        side: const BorderSide(color: Colors.black12),
      ),
    );
  }

  Widget _buildListTile(item) {
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
    final isTravel = item?.cR == '-';
    final color = isTravel ? Colors.redAccent : Colors.green;
    final label = isTravel ? 'Travel' : 'Recharge';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${item?.cR} Rs. ${item?.fARE ?? ''}',
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

  Widget _dateView(BuildContext context, {Function()? onPress, String? label, Rx<DateTime>? date}) {
    Analytics.filterTapped();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).disabledColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label ?? '',
                style: Theme.of(context).textTheme.displaySmall,
                overflow: TextOverflow.ellipsis,
                textScaler: const TextScaler.linear(1),
              ),
              Text(
                AuthenticationUtil.formatedDate(date?.value),
                style: Theme.of(context).textTheme.displaySmall,
                textScaler: const TextScaler.linear(1),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: InkWell(
              onTap: onPress,
              child: const Icon(
                Icons.calendar_today,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
