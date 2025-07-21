
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'controller/toll_calculator_static_controller.dart';

class CitiesTab extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> fadeAnimation;

  const CitiesTab({
    super.key,
    required this.animationController,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MotorwayStaticController>(
      init: MotorwayStaticController(),
      builder: (controller) => LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 600;
          final padding = isLargeScreen ? 24.0 : 16.0;
          return SingleChildScrollView(
            controller: controller.scrollController,
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800, minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSection(
                    _buildCitySelector(padding, controller),
                    context,
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    _buildVehicleSelector(isLargeScreen, controller),
                    context,
                  ),
                  Obx(() => controller.showToll.value
                      ? Column(
                          children: [
                            const SizedBox(height: 12),
                            FadeTransition(
                              opacity: fadeAnimation,
                              child: _buildSection(
                                TollDisplay(
                                  padding: padding,
                                  isCalculating: controller.isCalculating.value,
                                  entry: controller.entryCity.value.isEmpty ? null : controller.entryCity.value,
                                  exit: controller.exitCity.value.isEmpty ? null : controller.exitCity.value,
                                  vehicleName: controller.selectedVehicle.value != -1
                                      ? controller.vehicleList[controller.selectedVehicle.value].name
                                      : null,
                                  toll: controller.calculatedToll.value,
                                  route: controller.calculatedRoute.value,
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

  Widget _buildCitySelector(double padding, MotorwayStaticController controller) => Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Select Your Route',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => _buildCityDropdownField(
                    icon: Icons.location_city_outlined,
                    label: 'Entry City',
                    value: controller.entryCity.value.isEmpty ? null : controller.entryCity.value,
                    hint: 'Select Entry City',
                    onTap: () => controller.showCitySelectionDialog(true),
                  )),
              Obx(() => controller.entryCity.value.isNotEmpty
                  ? Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildCityDropdownField(
                          icon: Icons.location_city,
                          label: 'Exit City',
                          value: controller.exitCity.value.isEmpty ? null : controller.exitCity.value,
                          hint: 'Select Exit City',
                          onTap: () => controller.showCitySelectionDialog(false),
                        ),
                      ],
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      );

  Widget _buildCityDropdownField({
    required IconData icon,
    required String label,
    required String? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;
    final borderColor = value == null ? Colors.grey : Theme.of(Get.context!).primaryColor;
    final textColor = value != null
        ? (isDarkMode ? Colors.white : Theme.of(Get.context!).primaryColor)
        : Colors.grey[600];

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
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
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

  Widget _buildVehicleSelector(bool isLargeScreen, MotorwayStaticController controller) => Card(
        elevation: 0,
        color: Colors.transparent,
        child: Column(
          children: [
            Text('Select Vehicle Type', style: Theme.of(Get.context!).textTheme.labelLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: isLargeScreen ? 140 : 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.vehicleList.length,
                itemBuilder: (context, index) => _buildVehicleItem(index, isLargeScreen, controller),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );

  Widget _buildVehicleItem(int index, bool isLargeScreen, MotorwayStaticController controller) {
    final isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;
    final borderColor = isDarkMode ? Colors.redAccent : Theme.of(Get.context!).primaryColor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 8 : 6),
      child: Obx(() => InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (controller.entryCity.value.isEmpty || controller.exitCity.value.isEmpty) {
                controller.showSnackBar('Please select entry and exit cities first');
                return;
              }
              controller.selectedVehicle.value = index;
              controller.calculateTollUI(animationController);
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
                  SvgPicture.asset(
                    controller.vehicleList[index].image!,
                    height: isLargeScreen ? 45 : 35,
                    colorFilter: ColorFilter.mode(
                      Theme.of(Get.context!).primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  Text(
                    controller.vehicleList[index].name!,
                    style: Theme.of(Get.context!).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

class TollDisplay extends StatelessWidget {
  final double padding;
  final bool isCalculating;
  final String? entry;
  final String? exit;
  final String? vehicleName;
  final String? toll;
  final String? route;

  const TollDisplay({
    super.key,
    required this.padding,
    required this.isCalculating,
    required this.entry,
    required this.exit,
    required this.vehicleName,
    required this.toll,
    this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            Text('Toll Details', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            _buildDetailRow('Route', route ?? '$entry - $exit'),
            _buildDetailRow('Vehicle', vehicleName ?? 'Unknown'),
            const Divider(height: 1, color: Colors.grey),
            isCalculating
                ? const CircularProgressIndicator()
                : _buildDetailRow(
                    'Total Toll',
                    '$toll PKR',
                    isTotal: true,
                    valueStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red, fontSize: 18),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isTotal = false,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Flexible(
            child: Text(
              value,
              style: valueStyle,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
