import 'package:altmisdokuzapp/featured/bill/payment_showdialog.dart';
import 'package:altmisdokuzapp/featured/providers/admin_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/menu_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/tables_notifier.dart';
import 'package:altmisdokuzapp/product/constants/color_constants.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:altmisdokuzapp/product/widget/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

final _adminProvider = StateNotifierProvider<AdminNotifier, HomeState>((ref) {
  return AdminNotifier(ref);
});

final _tablesProvider =
    StateNotifierProvider<TablesNotifier, TablesState>((ref) {
  return TablesNotifier(ref);
});
final _menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier(ref);
});

class BillView extends ConsumerStatefulWidget {
  final String tableId;
  final List<Menu> orderItems;
  final String? qrUrl;
  const BillView({
    required this.tableId,
    required this.orderItems,
    this.qrUrl,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BillViewState();
}

class _BillViewState extends ConsumerState<BillView> {
  bool isClosing = false;
  bool isSearchBarVisible = false;
  late TextEditingController searchContoller;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchContoller = TextEditingController();
    Future.microtask(
      () {
        ref.read(_tablesProvider.notifier).fetchTableBill(widget.tableId);
        ref.read(_menuProvider.notifier).fetchAndload().then(
          (_) {
            // İlk kategori seçimini yapıyoruz
            final categories = ref.read(_menuProvider).categories;
            if (categories != null && categories.isNotEmpty) {
              ref
                  .read(_menuProvider.notifier)
                  .selectCategory(categories.first.name);
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    searchContoller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    final isLoadingAddItem = ref.watch(_tablesProvider).isLoading;
    final tablesNotifier = ref.read(_tablesProvider.notifier);
    final menuNotifier = ref.read(_menuProvider.notifier);
    final productItem = ref.watch(_menuProvider).products ?? [];
    final categories = ref.watch(_menuProvider).categories ?? [];
    final selectedCategory = ref.watch(_menuProvider).selectedValue;
    double deviceWidth = MediaQuery.of(context).size.width;

    // Filter items based on the search query, ignoring the selected category during search
    final filteredItems = productItem.where((item) {
      // If search query is not empty, ignore category and search across all products
      if (searchQuery.isNotEmpty) {
        return item.title!.toLowerCase().contains(searchQuery.toLowerCase());
      }

      // If search query is empty, filter based on the selected category
      final isCategoryMatch = selectedCategory == null ||
              selectedCategory == MenuNotifier.allCategories
          ? true
          : item.category == selectedCategory;
      return isCategoryMatch;
    }).toList();

    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          if (isLoading)
            const LinearProgressIndicator(
              color: Colors.green,
            ),
          Expanded(
            child: Scaffold(
              appBar: const PreferredSize(
                preferredSize: Size.fromHeight(70.0),
                child: CustomAppbar(
                  showDrawer: false,
                  showBackButton: true,
                ),
              ),
              backgroundColor:
                  ColorConstants.appbackgroundColor.withOpacity(0.15),
              body: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: ColorConstants.tablePageBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Sol taraf: Ürün listesi
                        Flexible(
                          flex: 2,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Search icon
                                  IconButton(
                                    icon: Icon(
                                      isSearchBarVisible
                                          ? Icons.close
                                          : Icons.search,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isSearchBarVisible =
                                            !isSearchBarVisible; // Arama çubuğu aç/kapat
                                      });
                                    },
                                  ),
                                  // Eğer arama çubuğu görünürse arama çubuğunu göster
                                  if (isSearchBarVisible)
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 8),
                                        child: TextField(
                                          controller: searchContoller,
                                          decoration: InputDecoration(
                                            hintText: 'Ara...',
                                            prefixIcon:
                                                const Icon(Icons.search),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onChanged: (query) {
                                            setState(() {
                                              searchQuery =
                                                  query; // Update search query
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                      child: isSearchBarVisible
                                          ? const SizedBox()
                                          : Wrap(
                                              children:
                                                  categories.map((category) {
                                                final isSelected =
                                                    selectedCategory ==
                                                        category.name;
                                                double itemWidth =
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        10; // 4 sütun
                                                return Container(
                                                  width: itemWidth,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? Colors.orange
                                                        : Colors.white,
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? Colors.orange
                                                          : Colors.black12,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Material(
                                                    color: isSelected
                                                        ? Colors.orange
                                                        : Colors.white,
                                                    child: InkWell(
                                                      splashColor: Colors.orange
                                                          .withOpacity(0.6),
                                                      onTap: () {
                                                        menuNotifier
                                                            .selectCategory(
                                                                category.name);
                                                      },
                                                      child: Center(
                                                        child: Text(
                                                          category.name ?? '',
                                                          style: TextStyle(
                                                              color: isSelected
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            )),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  color:
                                      ColorConstants.tablePageBackgroundColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: GridView.builder(
                                            itemCount: filteredItems.length,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount:
                                                  (constraints.maxWidth / 320)
                                                      .floor(),
                                              crossAxisSpacing: 10,
                                              mainAxisSpacing: 10,
                                              childAspectRatio: 1.6,
                                            ),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final item = filteredItems[index];
                                              return isLoading
                                                  ? const SizedBox()
                                                  : InkWell(
                                                      onTap: () {
                                                        // Ürün seçimi işlemi
                                                        // Ürünü masanın adisyonuna ekle
                                                        tablesNotifier
                                                            .addItemToBill(
                                                                widget.tableId,
                                                                item);
                                                      },
                                                      child: Card(
                                                          color: Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 40,
                                                                    bottom: 10,
                                                                    left: 10,
                                                                    right: 10),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                    item.title ??
                                                                        '',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    )),
                                                                Text(
                                                                    '₺${item.price}',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    )),
                                                              ],
                                                            ),
                                                          )),
                                                    );
                                            },
                                          ),
                                        ),
                                        widget.qrUrl != null
                                            ? SizedBox(
                                                child: QrImageView(
                                                  data: widget.qrUrl!,
                                                  version: QrVersions.auto,
                                                  size: 100.0,
                                                ),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Sağ taraf adisyon listesi
                        isLoadingAddItem == true
                            ? const Expanded(
                                child:
                                    Center(child: CircularProgressIndicator()))
                            : Expanded(
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    final tableBill = ref
                                        .watch(_tablesProvider.select((state) =>
                                            state.getTableBill(widget.tableId)))
                                        .where((item) =>
                                            item.isAmount !=
                                            true) // `isAmount == true` olanlar filtrelenir
                                        .toList();
                                    final totalAmount = tableBill.fold(
                                        0,
                                        (sum, item) =>
                                            sum +
                                            ((item.price ?? 0) *
                                                (item.piece ?? 1)));
                                    final tableBillAmount = ref
                                        .watch(_tablesProvider.select((state) =>
                                            state.getTableBill(widget.tableId)))
                                        .where((item) =>
                                            item.isAmount ==
                                            true) // `isAmount == true` olanlar filtrelenir
                                        .toList();
                                    final negativeAmount = tableBillAmount.fold(
                                        0,
                                        (sum, item) =>
                                            sum +
                                            ((item.price ?? 0) *
                                                (item.piece ?? 1)));
                                    bool negativeAmountFull =
                                        negativeAmount != 0 &&
                                            negativeAmount == totalAmount;
                                    bool allItemsPaid = tableBill.every(
                                            (item) =>
                                                item.status == 'ödendi') ||
                                        negativeAmountFull;
                                    final remainingAmount =
                                        totalAmount - negativeAmount;
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(12),
                                              bottomRight: Radius.circular(12)),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.4),
                                                spreadRadius: 1,
                                                blurRadius: 5,
                                                offset: const Offset(-2, 0)),
                                          ],
                                          border: const Border(
                                              left: BorderSide(
                                                  color: Colors.black12,
                                                  width: 1))),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text(
                                              widget.tableId,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            child: ListView.separated(
                                              separatorBuilder:
                                                  (context, index) =>
                                                      const Divider(
                                                indent: 10,
                                                endIndent: 10,
                                              ),
                                              itemCount: tableBill.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                final item = tableBill[index];
                                                return ListTile(
                                                  title: Text(item.title ?? ''),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                          '${item.piece ?? 1} adet'),
                                                      Text(
                                                          '₺${(item.price ?? 0) * (item.piece ?? 1)}'), // Her bir item için toplam fiyat
                                                    ],
                                                  ), // Fiyat null ise 0 olarak göster
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      item.status != 'ödendi'
                                                          ? const SizedBox()
                                                          : Text(
                                                              '${item.status}',
                                                              style: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .green),
                                                            ),
                                                      IconButton(
                                                        icon: const Icon(Icons
                                                            .remove_circle_outline),
                                                        onPressed: () {
                                                          // Adisyondan ürünü çıkarma işlemi
                                                          tablesNotifier
                                                              .removeItemFromBill(
                                                                  widget
                                                                      .tableId,
                                                                  item.id!);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const Divider(
                                            indent: 10,
                                            endIndent: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  // Her bir item için `price * piece` çarpımı yaparak toplam tutarı hesapla
                                                  'Toplam Tutar',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  // Her bir item için `price * piece` çarpımı yaparak toplam tutarı hesapla
                                                  '₺$totalAmount',
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: deviceWidth < 1350
                                                ? verticalButtons(
                                                    tableBill,
                                                    context,
                                                    ref,
                                                    allItemsPaid,
                                                    remainingAmount)
                                                : horiontalButtons(
                                                    tableBill,
                                                    context,
                                                    ref,
                                                    allItemsPaid,
                                                    remainingAmount),
                                          ),
                                          const SizedBox(
                                            height: 24,
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Row horiontalButtons(List<Menu> tableBill, BuildContext context,
      WidgetRef ref, bool allItemsPaid, int remainingAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.9), // Gölgenin rengi
                spreadRadius: 1, // Gölgenin yayılma alanı
                blurRadius: 10, // Gölgenin yumuşaklığı
                offset: const Offset(0, 1),
              )
            ], borderRadius: BorderRadius.circular(12)),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.transparent),
                backgroundColor: tableBill.isNotEmpty
                    ? Colors.green
                    : Colors.grey, // Liste boşsa rengi gri yap
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: tableBill.isNotEmpty
                  ? () async {
                      final result =
                          await paymentShowDialog(context, widget.tableId);
                      if (result == true) {
                        // Dialog kapandıktan sonra verileri yenile
                        ref
                            .read(_tablesProvider.notifier)
                            .fetchTableBill(widget.tableId);
                      }
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ÖDE',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '₺$remainingAmount',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ), // Liste boşsa düğme pasif olur
            ),
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
            child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.9), // Gölgenin rengi
              spreadRadius: 1, // Gölgenin yayılma alanı
              blurRadius: 10, // Gölgenin yumuşaklığı
              offset: const Offset(0, 1),
            ),
          ], borderRadius: BorderRadius.circular(12)),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: (allItemsPaid &&
                      tableBill
                          .isNotEmpty) // Adisyon boş değil ve tüm öğeler ödendi mi?
                  ? ColorConstants.billCloseButtonColor
                  : Colors
                      .grey, // Eğer adisyon boş veya tüm öğeler ödenmediyse buton gri (pasif) olur
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: (allItemsPaid && tableBill.isNotEmpty) &&
                    !isClosing // Adisyon boş değil ve tüm öğeler ödendiyse buton aktif olur
                ? () async {
                    setState(() {
                      isClosing = true; // Hesap kapatma işlemi başladı
                    });
                    final tablesNotifier = ref.read(_tablesProvider.notifier);
                    final isClosed =
                        await tablesNotifier.hesabiKapat(widget.tableId);

                    if (isClosed) {
                      // Hesap başarıyla kapatıldıysa kullanıcıya bildirim göster ve sayfayı kapat
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hesap başarıyla kapatıldı!'),
                        ),
                      );
                      Navigator.pop(context); // Sayfayı kapat
                    } else {
                      // Eğer hesap kapatılamadıysa kullanıcıya uyarı mesajı göster
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Tüm öğeler ödenmediği için hesap kapatılamadı!'),
                        ),
                      );
                    }
                    setState(() {
                      isClosing = false; // Hesap kapatma işlemi başladı
                    });
                  }
                : null, // Buton aktif değilse `null` değer atayarak pasif hale getir
            child: const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 16,
              ),
              child: Text(
                'HESABI KAPAT',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }

  Column verticalButtons(List<Menu> tableBill, BuildContext context,
      WidgetRef ref, bool allItemsPaid, int remainingAmount) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.9), // Gölgenin rengi
              spreadRadius: 1, // Gölgenin yayılma alanı
              blurRadius: 10, // Gölgenin yumuşaklığı
              offset: const Offset(0, 1),
            )
          ], borderRadius: BorderRadius.circular(12)),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.transparent),
              backgroundColor: tableBill.isNotEmpty
                  ? Colors.green
                  : Colors.grey, // Liste boşsa rengi gri yap
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: tableBill.isNotEmpty
                ? () async {
                    final result =
                        await paymentShowDialog(context, widget.tableId);
                    if (result == true) {
                      // Dialog kapandıktan sonra verileri yenile
                      ref
                          .read(_tablesProvider.notifier)
                          .fetchTableBill(widget.tableId);
                    }
                  }
                : null,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 16,
              ),
              child: Text(
                'ÖDE',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ), // Liste boşsa düğme pasif olur
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.9), // Gölgenin rengi
              spreadRadius: 1, // Gölgenin yayılma alanı
              blurRadius: 10, // Gölgenin yumuşaklığı
              offset: const Offset(0, 1),
            ),
          ], borderRadius: BorderRadius.circular(12)),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: (allItemsPaid &&
                      tableBill
                          .isNotEmpty) // Adisyon boş değil ve tüm öğeler ödendi mi?
                  ? ColorConstants.billCloseButtonColor
                  : Colors
                      .grey, // Eğer adisyon boş veya tüm öğeler ödenmediyse buton gri (pasif) olur
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: (allItemsPaid && tableBill.isNotEmpty) &&
                    !isClosing // Adisyon boş değil ve tüm öğeler ödendiyse buton aktif olur
                ? () async {
                    setState(() {
                      isClosing = true; // Hesap kapatma işlemi başladı
                    });
                    final tablesNotifier = ref.read(_tablesProvider.notifier);
                    final isClosed =
                        await tablesNotifier.hesabiKapat(widget.tableId);

                    if (isClosed) {
                      // Hesap başarıyla kapatıldıysa kullanıcıya bildirim göster ve sayfayı kapat
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hesap başarıyla kapatıldı!'),
                        ),
                      );
                      Navigator.pop(context); // Sayfayı kapat
                    } else {
                      // Eğer hesap kapatılamadıysa kullanıcıya uyarı mesajı göster
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Tüm öğeler ödenmediği için hesap kapatılamadı!'),
                        ),
                      );
                    }
                    setState(() {
                      isClosing = false; // Hesap kapatma işlemi başladı
                    });
                  }
                : null, // Buton aktif değilse `null` değer atayarak pasif hale getir
            child: const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 16,
              ),
              child: Text(
                'HESABI KAPAT',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
