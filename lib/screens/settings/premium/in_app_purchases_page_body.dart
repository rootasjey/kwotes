import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:in_app_purchase/in_app_purchase.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/types/enums/enum_page_state.dart";

class InPurchasesPageBody extends StatelessWidget {
  const InPurchasesPageBody({
    super.key,
    this.pageState = EnumPageState.idle,
    this.products = const [],
    this.onTapInAppPurchase,
  });

  /// Page state.
  final EnumPageState pageState;

  /// List of products
  final List<ProductDetails> products;

  /// On tap in app purchase
  final void Function(ProductDetails product)? onTapInAppPurchase;

  @override
  Widget build(BuildContext context) {
    final bool openingStore = pageState == EnumPageState.openingStore;
    final bool buying = pageState == EnumPageState.buyingInAppPurchase;
    if (pageState == EnumPageState.loading || openingStore || buying) {
      String message = "premium.in_app_purchase.loading".tr();
      if (openingStore) {
        message = "premium.opening_store".tr();
      } else if (buying) {
        message = "premium.in_app_purchase.buying".tr();
      }

      return LoadingView(
        message: message,
        useSliver: true,
      );
    }

    if (pageState == EnumPageState.idle && products.isEmpty) {
      return EmptyView.premium(
        context,
        margin: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
        title: "premium.in_app_purchase.no_product".tr(),
        description: "premium.in_app_purchase.no_product_description".tr(),
        onRefresh: () async {},
      );
    }

    return SliverList.builder(
      itemBuilder: (BuildContext context, int index) {
        final ProductDetails product = products[index];
        return ListTile(
          title: Text(product.title),
          subtitle: Text(product.description),
          trailing: Text(product.price),
          onTap: onTapInAppPurchase != null
              ? () => onTapInAppPurchase?.call(product)
              : null,
        );
      },
      itemCount: products.length,
    );
  }
}
