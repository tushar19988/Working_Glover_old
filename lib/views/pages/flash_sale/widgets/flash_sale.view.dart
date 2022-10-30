import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/models/flash_sale.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/flash_sale.vm.dart';
import 'package:fuodz/views/pages/flash_sale/flash_sale.page.dart';
import 'package:fuodz/views/pages/flash_sale/widgets/flash_sale.item_view.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:fuodz/widgets/custom_listed.list_view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:slide_countdown/slide_countdown.dart';

class FlashSaleView extends StatelessWidget {
  const FlashSaleView(this.vendorType, {Key key}) : super(key: key);

  //
  final VendorType vendorType;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FlashSaleViewModel>.reactive(
      viewModelBuilder: () =>
          FlashSaleViewModel(context, vendorType: vendorType),
      onModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        //
        if (vm.isBusy) {
          return BusyIndicator().p20().centered();
        } else if (vm.flashSales.isEmpty) {
          return UiSpacer.emptySpace();
        }
        //
        return VStack(
          [
            ...flashSalesListView(context, vm.flashSales),
            //UiSpacer.verticalSpace(),
          ],
        );
      },
    );
  }

  //
  List<Widget> flashSalesListView(
    BuildContext context,
    List<FlashSale> flashsales,
  ) {
    List<Widget> list = [];
    //
    flashsales.forEach((flashsale) {
      //
      if (flashsale.items == null || flashsale.items.isEmpty) {
        list.add(UiSpacer.emptySpace());
        return;
      }

      Widget title = HStack(
        [
          Icon(
            FlutterIcons.sale_mco,
            color: Utils.textColorByColor(AppColor.closeColor),
          ),
          UiSpacer.hSpace(10),
          VStack(
            [
              "${flashsale.name}"
                  .text
                  .semiBold
                  .lg
                  .color(Utils.textColorByTheme())
                  .make(),
              UiSpacer.vSpace(1),
              HStack(
                [
                  "TIME LEFT:"
                      .tr()
                      .text
                      .light
                      .sm
                      .color(Utils.textColorByTheme())
                      .make(),
                  UiSpacer.hSpace(6),
                  SlideCountdown(
                    textStyle: TextStyle(
                      fontSize: 11,
                      color: Utils.textColorByColor(AppColor.closeColor),
                    ),
                    duration: flashsale.countDownDuration,
                    separatorType: SeparatorType.symbol,
                    slideDirection: SlideDirection.up,
                  ),
                ],
              ),
            ],
          ).expand(),
          UiSpacer.hSpace(10),
          //
          "SEE ALL"
              .tr()
              .text
              .color(Utils.textColorByColor(AppColor.closeColor))
              .make()
              .onTap(
                () => openFlashSaleItems(context, flashsale),
              ),
        ],
      ).p12().box.color(AppColor.closeColor).make().wFull(context);
      //categories list
      Widget items = CustomListedListView(
        noScrollPhysics: false,
        scrollDirection: Axis.horizontal,
        items: flashsale.items.map(
          (flashSaleItem) {
            return FittedBox(
              child: FlashSaleItemListItem(flashSaleItem),
            );
          },
        ).toList(),
      ).h(Platform.isAndroid ? 160 : 190);

      //
      list.add(
        VStack(
          [
            title,
            items,
            UiSpacer.vSpace(10),
          ],
        ),
      );
    });

    return list;
  }

  openFlashSaleItems(BuildContext context, FlashSale flashsale) {
    context.nextPage(FlashSaleItemsPage(flashsale));
  }
}
