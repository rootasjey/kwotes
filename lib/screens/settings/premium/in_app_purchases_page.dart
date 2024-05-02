import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:in_app_purchase/in_app_purchase.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/settings/premium/in_app_purchases_page_body.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:loggy/loggy.dart";

class InAppPurchasesPage extends StatefulWidget {
  const InAppPurchasesPage({super.key});

  @override
  State<InAppPurchasesPage> createState() => _InAppPurchasesPageState();
}

class _InAppPurchasesPageState extends State<InAppPurchasesPage> with UiLoggy {
  /// Page state.
  EnumPageState _pageState = EnumPageState.idle;

  /// List of products
  final List<ProductDetails> _products = [];

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  void initState() {
    super.initState();
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchase.instance.purchaseStream;

    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      // handle error here.
    });

    fetch();
  }

  @override
  dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SettingsPageHeader(
              isMobileSize: isMobileSize,
              onTapBackButton: () => Navigator.of(context).pop(),
              onTapCloseIcon: () {
                NavigationStateHelper.navigateBackToLastRoot(context);
              },
              title: "premium.in_app_purchase.name".tr(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: 24.0,
                  top: 6.0,
                ),
                child: Text(
                  "premium.in_app_purchase.description".tr(),
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      color: foregroundColor?.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            InPurchasesPageBody(
              pageState: _pageState,
              products: _products,
              onTapInAppPurchase: onTapInAppPurchase,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetch() async {
    setState(() => _pageState = EnumPageState.loading);
    try {
      final bool available = await InAppPurchase.instance.isAvailable();
      if (!available) {
        // The store cannot be reached or accessed. Update the UI accordingly.
        loggy.error("InAppPurchase.instance.isAvailable() returned false");
        return;
      }

      const Set<String> kIds = <String>{"test"};
      final ProductDetailsResponse response =
          await InAppPurchase.instance.queryProductDetails(kIds);
      if (response.notFoundIDs.isNotEmpty) {
        loggy.error("not found ids");
      }

      final List<ProductDetails> products = response.productDetails;

      setState(() {
        _products.clear();
        _products.addAll(products);
        _pageState = EnumPageState.idle;
      });
    } catch (error) {
      loggy.error(error);
      setState(() => _pageState = EnumPageState.idle);
    }
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() => _pageState = EnumPageState.buyingInAppPurchase);
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // _handleError(purchaseDetails.error!);
          Utils.graphic.showSnackbar(
            context,
            message: purchaseDetails.error?.message ??
                "premium.in_app_purchase.error".tr(),
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // bool valid = await _verifyPurchase(purchaseDetails);
          // if (valid) {
          //   // _deliverProduct(purchaseDetails);
          // } else {
          //   // _handleInvalidPurchase(purchaseDetails);
          // }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
          setState(() => _pageState = EnumPageState.idle);
        }
      }
    }
  }

  void onTapInAppPurchase(ProductDetails product) async {
    setState(() => _pageState = EnumPageState.openingStore);
    try {
      await InAppPurchase.instance.buyConsumable(
        purchaseParam: PurchaseParam(
          productDetails: product,
          applicationUserName: null,
        ),
      );
      setState(() => _pageState = EnumPageState.idle);
    } catch (error) {
      loggy.error(error);
      setState(() => _pageState = EnumPageState.idle);
    }
  }
}
