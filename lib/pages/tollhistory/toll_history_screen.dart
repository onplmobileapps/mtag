import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/user_repo.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_appbar.dart';
import 'package:shimmer/shimmer.dart';


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

  void onListTileTap(dynamic arguments) async {
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
    return Scaffold(
      appBar: GradientAppBar(title: const Text('Toll History')),
      body: SafeArea(top: false,
        child: Column(
          children: [
            _buildStickyMessage(context),
            Expanded(
              child: Obx(
                () => isLoading.value
                    ? ListSkeleton()
                    : GetX<TollController>(
                        init: TollController(userRepo: UserRepo()),
                        builder: (controller) =>
                            _buildTollHistoryContent(controller),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTollHistoryContent(TollController controller) {
    return Container(margin: .all(4),
      height: MediaQuery.sizeOf(context).height,
      width: double.infinity,

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
                      // _buildChip(controller, 'CDA-Parking', 3, 'P'),   Sir Suleman Asked to remove CDA parking
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
        controller.searchData(searchData);
        if (value == 2) {
          Get.find<ReceiptController>().chechTravel(true);
        }
      },
      child: Chip(
        label: Text(label),
        labelStyle: TextStyle(
          color: controller.isSlected.value == value
              ? Colors.white
              : Theme.of(context).highlightColor,fontFamily: 'biotifbold',
        ),
        backgroundColor: controller.isSlected.value == value
            ? primarSwatch
            : Theme.of(context).disabledColor,
   shape: RoundedRectangleBorder(borderRadius: .circular(18)),
      ),
    );
  }

  Widget _buildListTile(dynamic item) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      gradient: Theme.of(context).extension<AppGradients>()!.gridWidget,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.05),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      tileColor: Colors.transparent,
      onTap: () => onListTileTap(item),
      title: Text(
        '${item?.eNTRYSTATIONNAME ?? ''}${item?.eXITSTATIONNAME != null ? ' → ' : ''}${item?.eXITSTATIONNAME ?? ''}',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _buildTrailingColumn(item),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.nfc,
                size: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 4),
              Text(
                'M-TAG ${item?.iTOKKENNO ?? ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 4),
              Text(
                item?.tRANSTIME ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildTrailingColumn(dynamic item) {
  final String? cR = item?.cR;
  final String fare = item?.fARE ?? '0';
  
  final isTravel = cR == '-';
  final isParking = cR == 'P';
  
  // Use Material 3 tonal colors
  final color = isTravel
      ? Colors.red
      : isParking
          ? Theme.of(context).colorScheme.error
          : Colors.green;
  
  final label = isTravel ? 'Travel' : isParking ? 'Parking' : 'Recharge';
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha:0.08),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isParking ? 'Rs. $fare' : '$cR Rs. $fare',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
         color: color
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
         
          
          ),
        ),
      ],
    ),
  );
}

Widget _buildStickyMessage(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      
      const SizedBox(height: 10),
      Container(margin: .symmetric(horizontal:8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
    gradient: Theme.of(context).extension<AppGradients>()!.stickyNote,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.campaign,

              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'The history section displays only M-Tag transactions. '
                'Cash transactions are not included in this view.',
                style: TextTheme.of(context).displaySmall,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
      
    ],
  );
}}

class ListSkeleton extends StatelessWidget {
  final int itemCount;

  const ListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: itemCount,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Shimmer.fromColors(
            baseColor: colorScheme.surfaceContainerLowest,
            highlightColor: colorScheme.surface,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      ...List.generate(
                        3,
                        (i) => Container(
                          width: i==0? 120:100,
                          height: 10,
                          margin: const EdgeInsets.only(right: 8, bottom: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 3 Leading items
                  const Spacer(),
                  Column(children: [...List.generate(
                    2,
                    (i) => Container(
                      width: 50,
                      height: 10,
                      margin: const EdgeInsets.only(left: 8, top: 2, bottom: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),],)
                  // 2 Trailing items
                  
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

