import 'dart:ui';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/constants/analytics.dart';

import '../../pages/tolcalator/controller/toll_calculator_controller.dart';
import 'model/stations_model.dart';

class TolCalCulatorScreen extends StatefulWidget {
  const TolCalCulatorScreen({
    super.key,
  });

  static const String kTitle = 'Toll Calculator';

  @override
  State<TolCalCulatorScreen> createState() => _TolCalCulatorScreenState();
}

class _TolCalCulatorScreenState extends State<TolCalCulatorScreen> {
  @override
  void dispose() {
    Get.find<TollCalculatorController>().clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool tollVisibility = false;
    Analytics.tollCalculatorScreenDisplayed();
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text(TolCalCulatorScreen.kTitle)),
      body: Container(
        constraints: const BoxConstraints.expand(),
        key: GlobalKey(),
        height: size.height,
        width: size.width,
        color: Theme.of(context).primaryColor,
        child: Container(
          width: size.width,
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: GetX<TollCalculatorController>(
            global: true,
            autoRemove: false,
            builder: (controller) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      constraints: const BoxConstraints.expand(),
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration:
                          BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          Text(
                            'Select Motorway',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Expanded(
                            child: ListView.builder(
                              reverse: false,
                              itemCount: controller.motorways.value.data?.length ?? 0,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (ctx, index1) {
                                var data = controller.motorways.value.data?[index1];
                                return Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        controller.motorWayIndex = index1;
                                        controller.vehicleIndex = -1;
                                        if (data != null) {
                                          await controller.getMotStations(mwid: int.parse('${data.mWID}'));
                                        }
                                        controller.resetValues();
                                        controller.update();
                                        tollVisibility = false;
                                      },
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        margin: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color:
                                                  controller.motorWayIndex == index1 ? Colors.red : Colors.transparent),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Spacer(),
                                            SvgPicture.asset(
                                              'assets/line.svg',
                                              colorFilter:
                                                  ColorFilter.mode(Theme.of(context).primaryColor, BlendMode.srcIn),
                                              fit: BoxFit.contain,
                                            ),
                                            const Spacer(),
                                            Text(
                                              data?.mWSHORTNAME?.toUpperCase() ?? ''.toUpperCase(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall
                                                  ?.copyWith(color: Theme.of(context).primaryColor),
                                            ),
                                            const Spacer(),
                                            Text(
                                              data?.mWNAME ?? '',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(color: Theme.of(context).primaryColor),
                                            ),
                                            const Spacer(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration:
                        BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        Text(
                          'Select Interchange',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            BuildDropDownField(
                              selectedItem: controller.selectedEntryItem.value,
                              revesre: false,
                              validator: (p0) {
                                if (p0 != null) return null;
                                return 'Select Entry Station';
                              },
                              hint: 'Select Entry Station',
                              items: [...controller.motoStations.value?.data ?? []],
                              onChanged: (value) {
                                controller.setEntry(value);
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text('To', style: Theme.of(context).textTheme.labelLarge),
                            const SizedBox(
                              height: 5,
                            ),
                            BuildDropDownField(
                                selectedItem: controller.selectedExitItem.value,
                                validator: (p0) {
                                  if (p0 != null) return null;
                                  return 'Select Exit Station';
                                },
                                revesre: true,
                                hint: 'Select Exit Station',
                                onChanged: (value) {
                                  if (controller.selectedEntryItem.value?.stname == value?.stname) {
                                    controller.selectedExitItem.refresh();

                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (_) => CupertinoAlertDialog(
                                        content: const Text('Select different interchange'),
                                        actions: [
                                          CupertinoDialogAction(
                                            child: const Text('Ok'),
                                            onPressed: () {
                                              Get.back();
                                            },
                                          )
                                        ],
                                      ),
                                    );
                                    return;
                                  } else {
                                    controller.setExit(value!);
                                  }
                                },
                                items: [...controller.motoStations.value?.data ?? []])
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      constraints: const BoxConstraints.expand(),
                      width: size.width,
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(12),
                      decoration:
                          BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          Text(
                            'Vehicle Type',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Obx(
                            () => Expanded(
                              child: ListView.builder(
                                itemCount: controller.vehicleList.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (ctx, index) => Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        controller.vehicleIndex = index;

                                        if (controller.selectedEntryItem.value == null ||
                                            controller.selectedExitItem.value == null) {
                                          return;
                                        }
                                        await controller.calCulateToll(id: controller.vehicleList[index].id);
                                        tollVisibility = true;
                                      },
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        margin: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color:
                                                  controller.vehicleIndex == index ? Colors.red : Colors.transparent),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Spacer(),
                                            SvgPicture.asset(
                                              '${controller.vehicleList[index].image}',
                                              colorFilter:
                                                  ColorFilter.mode(Theme.of(context).primaryColor, BlendMode.srcIn),
                                              height: 30,
                                              width: 30,
                                              fit: BoxFit.cover,
                                            ),
                                            const Spacer(),
                                            Text(
                                              '${controller.vehicleList[index].name}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(color: Theme.of(context).primaryColor),
                                            ),
                                            const Spacer(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Visibility(
                    visible: tollVisibility,
                    child: Container(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Column(
                          children: [
                            Text(
                              'Toll Rate',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(letterSpacing: 3),
                            ),
                            Text(
                              '${controller.totalToll.value ?? ''} PKR',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(color: Colors.green, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
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
}

class BuildDropDownField extends StatefulWidget {
  final Data? selectedItem;
  final void Function(Data?) onChanged;
  final List<Data> items;
  final String? hint;
  final bool? revesre;
  final String? Function(Data?) validator;
  const BuildDropDownField({
    super.key,
    required this.onChanged,
    required this.selectedItem,
    required this.revesre,
    required this.validator,
    required this.items,
    required this.hint,
  });

  @override
  State<BuildDropDownField> createState() => _BuildDropDownFieldState();
}

class _BuildDropDownFieldState extends State<BuildDropDownField> {
  final _dropDownKey = GlobalKey<DropdownSearchState>();
  late Data? _selectedItem;
  init([bool isrebuid = false]) {
    _selectedItem = widget.selectedItem;
    if (isrebuid) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void didUpdateWidget(covariant BuildDropDownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    init(true);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Data>(
      autoValidateMode: AutovalidateMode.onUserInteraction,
      selectedItem: _selectedItem,
      validator: widget.validator,
      itemAsString: (item) => item.stname ?? '',
      suffixProps: const DropdownSuffixProps(
        clearButtonProps: ClearButtonProps(padding: EdgeInsets.zero),
        dropdownButtonProps: DropdownButtonProps(
            padding: EdgeInsets.zero,
            iconOpened: Icon(Icons.keyboard_arrow_up_outlined),
            iconClosed: Icon(Icons.keyboard_arrow_down_outlined)),
      ),
      decoratorProps: DropDownDecoratorProps(
        baseStyle: const TextStyle(color: Colors.black, fontFamily: 'Poppins', fontSize: 12),
        decoration: InputDecoration(hintStyle: Theme.of(context).inputDecorationTheme.hintStyle?.copyWith(color: Colors.black54),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.black54,
              width: .5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          hintText: widget.hint,
          
          constraints: const BoxConstraints(maxHeight: 35, maxWidth: double.infinity),
          suffixIcon: const Icon(Icons.keyboard_arrow_down_outlined),
          isDense: true,
          counterText: '',
          errorStyle: const TextStyle(height: 0.05),
          contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
          filled: true,
          border: InputBorder.none,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black54, width: .5),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black54, width: .5),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black54, width: .5),
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black54, width: .5),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      popupProps: PopupProps.menu(
        listViewProps: ListViewProps(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.fromViewPadding(ViewPadding.zero, MediaQuery.devicePixelRatioOf(context)),
            reverse: widget.revesre ?? false),
        menuProps: MenuProps(
            elevation: 0,
            backgroundColor: Theme.of(context).dropdownMenuTheme.inputDecorationTheme?.focusColor,
            shape: const RoundedRectangleBorder()),
        onDismissed: () {
          FocusScope.of(Get.context!).unfocus();
        },
        searchDelay: const Duration(seconds: 0),
        showSearchBox: true,
        emptyBuilder: (context, searchEntry) => const Center(
          child: Text('No Station Found!'),
        ),
        errorBuilder: (context, searchEntry, exception) => Center(
          child: Text(exception),
        ),
        searchFieldProps: TextFieldProps(
            scrollPadding: const EdgeInsets.all(4),
            style: const TextStyle(fontSize: 11, fontFamily: 'Poppins', height: 1),
            decoration: InputDecoration(hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
              border: InputBorder.none,
              hintText: 'Search Station',
              constraints: const BoxConstraints(maxHeight: 35),
              suffixIconConstraints: const BoxConstraints(maxHeight: 1, minHeight: 1),
              filled: true,
              fillColor: Colors.grey.withAlpha( 120),
              contentPadding: const EdgeInsets.only(left: 15, top: 0, bottom: 8),
            ),
            textInputAction: TextInputAction.done),
      ),
      onSaved: widget.onChanged,
      compareFn: (item1, item2) => item1.stid == item2.stid,
      enabled: true,
      onChanged: widget.onChanged,
      key: _dropDownKey,
      items: (value, load) => widget.items,
    );
  }
}
