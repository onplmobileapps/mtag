
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../widgets/toll_display_widget.dart';
import 'controller/toll_calculator_static_controller.dart';
class TollPlazaTab extends GetView<MotorwayStaticController> {
  final AnimationController animationController;
  final Animation<double> fadeAnimation;

  const TollPlazaTab({
    super.key,
    required this.animationController,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MotorwayStaticController>(
      initState: (_) =>controller.reset() ,
      builder: (controller) => LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 600;
          final padding = isLargeScreen ? 18.0 : 10.0;
          return SingleChildScrollView(
            controller: controller.scrollController,
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800, minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildSection(_buildMotorwaySelector(context, isLargeScreen, controller), context),
                  const SizedBox(height: 12),
                  _buildSection(_buildStationSelector(context, padding, controller), context),
                  const SizedBox(height: 12),
                  _buildSection(_buildVehicleSelector(context, isLargeScreen, controller), context),
                  Obx(() => controller.showTollPlaza.value
                      ? Column(
                          children: [
                            const SizedBox(height: 12),
                            FadeTransition(
                              opacity: fadeAnimation,
                              child: _buildSection(
                                TollDisplay(
                                  padding: padding,
                                  isCalculating: controller.isCalculatingPlaza.value,
                                  entry: controller.entryStation.value.isEmpty ? null : controller.entryStation.value,
                                  exit: controller.exitStation.value.isEmpty ? null : controller.exitStation.value,
                                  vehicleName: controller.selectedVehicle.value != -1
                                      ? controller.vehicleList[controller.selectedVehicle.value].name
                                      : null,
                                  toll: controller.calculatedTollPlaza.value,
                                  route: '${controller.entryStation.value} - ${controller.exitStation.value}',
                                ),
                                context,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink()),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(Widget child, BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );

  Widget _buildMotorwaySelector(BuildContext  context,bool isLargeScreen, MotorwayStaticController controller) => Card(
        elevation: 0,
        color: Colors.transparent,
        child: Column(
          children: [
            Text('Select Motorway', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: isLargeScreen ? 120 : 110,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: controller.mwNameList.length,
                itemBuilder: (context, index) => _buildMotorwayItem(context, index, isLargeScreen, controller),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );

  Widget _buildMotorwayItem(BuildContext context ,int index, bool isLargeScreen, MotorwayStaticController controller) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? Colors.redAccent : Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 8 : 6),
      child: Obx(() => InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              controller.fetchStations(controller.mwNameList[index].motorwayID ?? 0);
              controller.selectedMotorway.value = index;
              controller.selectedVehicle.value = -1;
              controller.showTollPlaza.value = false;
              controller.entryStation.value = '';
              controller.exitStation.value = '';
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isLargeScreen ? 150 : 120,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: controller.selectedMotorway.value == index ? borderColor : Colors.transparent,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: controller.selectedMotorway.value == index
                    ? [BoxShadow(color: borderColor.withValues(alpha: 20), blurRadius: 0, spreadRadius: 0)]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/line.svg',
                    height: isLargeScreen ? 45 : 35,
                    colorFilter: ColorFilter.mode(Theme.of(context).primaryColor, BlendMode.srcIn),
                  ),
                  Text(
                    controller.mwNameList[index].motorwayAbbrivation!,
                    style: TextStyle(fontSize: isLargeScreen ? 14 : 12, color: Theme.of(context).primaryColor),
                  ),
                  Text(
                    controller.mwNameList[index].motorwayName!,
                    style: TextStyle(fontSize: isLargeScreen ? 20 : 18, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildStationSelector(BuildContext context, double padding, MotorwayStaticController controller) => Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text('Select InterChange', style: Theme.of(context).textTheme.labelLarge)),
              const SizedBox(height: 10),
              Obx(() => _buildDropdownField(
                    icon: const Icon(Icons.location_on_outlined, color: Colors.green),
                    label: 'Entry Station',
                    value: controller.entryStation.value.isEmpty ? null : controller.entryStation.value,
                    hint: 'Enter starting point',
                    onTap: () => controller.showStationSelectionDialog(true),
                  )),
              Obx(() => controller.entryStation.value.isNotEmpty
                  ? Column(
                      children: [
                        const SizedBox(height: 10),
                        _buildDropdownField(
                          icon: const Icon(Icons.location_on, color: Colors.redAccent),
                          label: 'Exit Station',
                          value: controller.exitStation.value.isEmpty ? null : controller.exitStation.value,
                          hint: 'Enter destination',
                          onTap: () => controller.showStationSelectionDialog(false),
                        ),
                      ],
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      );

  Widget _buildDropdownField({
    required Widget icon,
    required String label,
    required String? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;
    final borderColor = value == null ? Colors.grey : Theme.of(Get.context!).primaryColor;
    final textColor = value != null ? (isDarkMode ? Colors.white : Theme.of(Get.context!).primaryColor) : Colors.grey[600];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(Get.context!).textTheme.labelSmall),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                icon,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: textColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleSelector(BuildContext context, bool isLargeScreen, MotorwayStaticController controller) => Card(
        elevation: 0,
        color: Colors.transparent,
        child: Column(
          children: [
            Text('Select Vehicle Type', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: isLargeScreen ? 160 : 120,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: controller.vehicleList.length,
                itemBuilder: (context, index) => _buildVehicleItem(context, index, isLargeScreen, controller),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );

  Widget _buildVehicleItem(BuildContext context,int index, bool isLargeScreen, MotorwayStaticController controller) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? Colors.redAccent : Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 8 : 6),
      child: Obx(() => InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (controller.selectedMotorway.value == -1) {
                controller.showSnackBar('Please select a motorway first');
                return;
              }
              if (controller.entryStation.value.isEmpty || controller.exitStation.value.isEmpty) {
                controller.showSnackBar('Please select entry and exit stations first');
                return;
              }
              controller.selectedVehicle.value = index;
              controller.calculateTollPlaza(animationController);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isLargeScreen ? 160 : 120,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: controller.selectedVehicle.value == index ? borderColor : Colors.transparent,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: controller.selectedVehicle.value == index
                    ? [BoxShadow(color: borderColor.withValues(alpha: 20), blurRadius: 0, spreadRadius: 0)]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      controller.vehicleList[index].image!,
                      height: isLargeScreen ? 48 : 40,
                      colorFilter: ColorFilter.mode(Theme.of(context).primaryColor, BlendMode.srcIn),
                    ),
                  ),
                  Text(
                    controller.vehicleList[index].name!,
                    style: TextStyle(fontSize: isLargeScreen ? 18 : 16, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
