import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';
import '../../constants/other_consts.dart';
import '../../widgets/toll_display_widget.dart';
import 'controller/toll_calculator_static_controller.dart';

class TollPlazaTab extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> fadeAnimation;

  const TollPlazaTab({
    super.key,
    required this.animationController,
    required this.fadeAnimation,
  });

  static const Map<int, int> _tollMapMurree = {
    1: 200,
    2: 200,
    3: 200,
    4: 350,
    5: 400,
    6: 800,
  };
  static const Map<int, int> _tollMapEasternBypass = {
    1: 70,
    2: 150,
    3: 150,
    4: 250,
    5: 300,
    6: 550,
  };
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MotorwayStaticController>(
      builder: (controller) => LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 600;
          final padding = isLargeScreen ? 18.0 : 10.0;

          return _buildContent(
            controller,
            isLargeScreen,
            padding,
            context,
            constraints,
          );
        },
      ),
    );
  }

  Widget _buildContent(
    MotorwayStaticController controller,
    bool isLargeScreen,
    double padding,
    BuildContext context,
    BoxConstraints constraints,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      controller: controller.scrollController,
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 800,
          minHeight: constraints.maxHeight,
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildMotorwaySection(controller, isLargeScreen, context),
            const SizedBox(height: 12),
            Obx(() => _buildStationSection(controller, padding, context)),
            const SizedBox(height: 12),
            _buildVehicleSection(controller, isLargeScreen, context),
            Obx(() => _buildTollDisplay(controller, padding, context)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMotorwaySection(
    MotorwayStaticController controller,
    bool isLargeScreen,
    BuildContext context,
  ) {
    return _section(
      context,
      child: Column(
        children: [
          Text(
            'Select Motorway',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: isLargeScreen ? 120 : 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: OtherConsts.mwNameList.length,
              itemBuilder: (ctx, index) =>
                  _buildMotorwayItem(ctx, index, isLargeScreen, controller),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildMotorwayItem(
    BuildContext context,
    int index,
    bool isLargeScreen,
    MotorwayStaticController controller,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode
        ? Colors.redAccent
        : Theme.of(context).primaryColor;
    final motorway = OtherConsts.mwNameList[index];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 8 : 6),
      child: Obx(() {
        final isSelected = controller.selectedMotorway.value == index;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onMotorwaySelected(controller, index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isLargeScreen ? 150 : 120,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isSelected ? borderColor : Colors.transparent,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: borderColor.withAlpha(20),
                        blurRadius: 0,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: FittedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    motorway.motorwayAbbrivation!,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 14 : 12,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Image.asset(
                    'assets/road.png',
                    height: isLargeScreen ? 45 : 50,
                    width: 60,
                  ),
                  Text(
                    motorway.motorwayName!,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 20 : 18,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _onMotorwaySelected(MotorwayStaticController controller, int index) {
    controller.selectedMotorway.value = index;
    controller.selectedVehicle.value = -1;
    controller.showTollPlaza.value = false;
    controller.entryStation.value = '';
    controller.exitStation.value = '';

    final motorway = OtherConsts.mwNameList[index];

    if (motorway.motorwayID != 200 && motorway.motorwayID != 300) {
      controller.entryStation.value = '';
    controller.exitStation.value = '';
      controller.fetchStations(motorway.motorwayID ?? 0);
    }else{
      controller.entryStation.value = '';
    controller.exitStation.value = '';
    }
  }

  Widget _buildStationSection(
    MotorwayStaticController controller,
    double padding,
    BuildContext context,
  ) {
    final selectedMotorwayIndex = controller.selectedMotorway.value;

  if (selectedMotorwayIndex != -1) {
    final motorway = OtherConsts.mwNameList[selectedMotorwayIndex];

    if (motorway.motorwayID == 200 || motorway.motorwayID == 300) {
      return const SizedBox.shrink();
    
  }
  }
    return _section(
      context,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            Center(
              child: Text(
                'Select Interchange',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 10),
            _buildStationField(
              controller: controller,
              isEntry: true,
              context: context,
            ),
            Obx(
              () => controller.entryStation.value.isNotEmpty
                  ? Column(
                      children: [
                        const SizedBox(height: 10),
                        _buildStationField(
                          controller: controller,
                          isEntry: false,
                          context: context,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationField({
    required MotorwayStaticController controller,
    required bool isEntry,
    required BuildContext context,
  }) {
    final station = isEntry
        ? controller.entryStation.value
        : controller.exitStation.value;
    final label = isEntry ? 'Entry Station' : 'Exit Station';
    final hint = isEntry ? 'Enter starting point' : 'Enter destination';
    final icon = isEntry
        ? const Icon(Icons.location_on_outlined, color: Colors.green)
        : const Icon(Icons.location_on, color: Colors.redAccent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => controller.showStationSelectionDialog(isEntry),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: station.isEmpty
                    ? Colors.grey
                    : Theme.of(context).primaryColor,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                icon,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    station.isEmpty ? hint : station,
                    style: TextStyle(
                      color: station.isEmpty
                          ? Colors.grey[600]
                          : Theme.of(context).primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: station.isEmpty
                      ? Colors.grey[600]
                      : Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleSection(
    MotorwayStaticController controller,
    bool isLargeScreen,
    BuildContext context,
  ) {
    return _section(
      context,
      child: Column(
        children: [
          Text(
            'Select Vehicle Type',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: isLargeScreen ? 160 : 120,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: OtherConsts.vehicleList.length,
              itemBuilder: (ctx, index) =>
                  _buildVehicleItem(ctx, index, isLargeScreen, controller),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildVehicleItem(
    BuildContext context,
    int index,
    bool isLargeScreen,
    MotorwayStaticController controller,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode
        ? Colors.redAccent
        : Theme.of(context).primaryColor;
    final vehicle = OtherConsts.vehicleList[index];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 8 : 6),
      child: Obx(() {
        final isSelected = controller.selectedVehicle.value == index;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onVehicleSelected(controller, index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isLargeScreen ? 160 : 120,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isSelected ? borderColor : Colors.transparent,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: borderColor.withAlpha(20),
                        blurRadius: 0,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    vehicle.image!,
                    height: isLargeScreen ? 60 : 70,
                  ),
                ),
                Text(
                  vehicle.name!,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 18 : 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _onVehicleSelected(MotorwayStaticController controller, int index) {
    final selectedMotorwayIndex = controller.selectedMotorway.value;
    if (selectedMotorwayIndex == -1) {
      controller.showSnackBar('Please select a motorway first');
      return;
    }

    final motorway = OtherConsts.mwNameList[selectedMotorwayIndex];
    if (motorway.motorwayID != 200 &&
        motorway.motorwayID != 300 &&
        (controller.entryStation.value.isEmpty ||
            controller.exitStation.value.isEmpty)) {
      controller.showSnackBar('Please select entry and exit stations first');
      return;
    }

    controller.selectedVehicle.value = index;
    controller.showTollPlaza.value = true;

    _calculateToll(controller, motorway.motorwayID, index);
  }

  void _calculateToll(
    MotorwayStaticController controller,
    int? motorwayID,
    int vehicleIndex,
  ) {
    if (motorwayID == 200) {
      final toll =
          _tollMapMurree[OtherConsts.vehicleList[vehicleIndex].id]
              ?.toString() ??
          '0';
      controller.calculatedTollPlaza.value = toll;
      controller.isCalculatingPlaza.value = false;
      animationController.forward(from: 0);
    } else if (motorwayID == 300) {
      final toll =
          _tollMapEasternBypass[OtherConsts.vehicleList[vehicleIndex].id]
              ?.toString() ??
          '0';
      controller.calculatedTollPlaza.value = toll;
      controller.isCalculatingPlaza.value = false;
      animationController.forward(from: 0);
    } else {
      controller.calculateTollPlaza(animationController);
    }
  }

  Widget _buildTollDisplay(
    MotorwayStaticController controller,
    double padding,
    BuildContext context,
  ) {
    if (!controller.showTollPlaza.value) return const SizedBox.shrink();
    final selectedMotorwayIndex = controller.selectedMotorway.value;
    final selectedVehicleIndex = controller.selectedVehicle.value;
    if (selectedMotorwayIndex == -1 || selectedVehicleIndex == -1) {
      return const SizedBox.shrink();
    }
    final motorway = OtherConsts.mwNameList[selectedMotorwayIndex];
    final vehicle = OtherConsts.vehicleList[selectedVehicleIndex];
    final isSpecialMotorway =
        motorway.motorwayID == 200 || motorway.motorwayID == 300;
    final toll = _getTollValue(
      controller,
      motorway.motorwayID,
      selectedVehicleIndex,
    );
    final route = isSpecialMotorway
        ? motorway.motorwayName
        : '${controller.entryStation.value} - ${controller.exitStation.value}';

    return Column(
      children: [
        const SizedBox(height: 12),
        FadeTransition(
          opacity: fadeAnimation,
          child: _section(
            context,
            child: SafeArea(
              child: TollDisplay(
                padding: padding,
                isCalculating:
                    controller.isCalculatingPlaza.value && !isSpecialMotorway,
                entry: isSpecialMotorway ? null : controller.entryStation.value,
                exit: isSpecialMotorway ? null : controller.exitStation.value,
                vehicleName: vehicle.name,
                toll: toll,
                route: route,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _getTollValue(
    MotorwayStaticController controller,
    int? motorwayID,
    int vehicleIndex,
  ) {
    if (vehicleIndex == -1) return null;

    return motorwayID == 200
        ? _tollMapMurree[OtherConsts.vehicleList[vehicleIndex].id]?.toString()
        : motorwayID == 300
        ? _tollMapEasternBypass[OtherConsts.vehicleList[vehicleIndex].id]
              ?.toString()
        : controller.calculatedTollPlaza.value;
  }

  Widget _section(BuildContext context, {Widget? child}) {
    return Container(
      decoration: BoxDecoration(
      gradient: Theme.of(context).extension<AppGradients>()!.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
