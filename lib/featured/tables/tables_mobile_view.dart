/* import 'package:foomoons/featured/bill/bill_mobile_view.dart';
import 'package:foomoons/featured/bill/bill_view.dart';
import 'package:foomoons/featured/providers/loading_notifier.dart';
import 'package:foomoons/featured/providers/menu_notifier.dart';
import 'package:foomoons/featured/providers/tables_notifier.dart';
import 'package:foomoons/featured/responsive/responsive_layout.dart';
import 'package:foomoons/featured/tables/dialogs/add_areas_dialog.dart';
import 'package:foomoons/featured/tables/dialogs/add_table_dialog.dart';
import 'package:foomoons/product/constants/color_constants.dart';
import 'package:foomoons/product/model/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// /// Firebase AuthState Provider
// final authStateProvider = StreamProvider<User?>((ref) {
//   return FirebaseAuth.instance.authStateChanges();
// });

/// Menu Provider
final _tablesProvider =
    StateNotifierProvider<TablesNotifier, TablesState>((ref) {
  // // Kullanıcı oturum değişikliklerini izleyin
  // final authStateChanges = ref.watch(authStateProvider);

  // // AsyncValue olduğu için asData ile kontrol edin
  // if (authStateChanges.asData?.value == null) {
  //   // Eğer kullanıcı çıkış yapmışsa state'i sıfırla
  //   ref.read(tablesProvider.notifier).resetState();
  // } else {
  //   ref.read(tablesProvider.notifier).fetchTable();
  // }

  return TablesNotifier(ref);
});

final _menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier(ref);
});

/// MenuView Widget
class TablesMobileView extends ConsumerStatefulWidget {
  final String? successMessage;
  const TablesMobileView({this.successMessage, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TablesMobileViewState();
}

class _TablesMobileViewState extends ConsumerState<TablesMobileView> {
  late bool allItemsPaid;
  late int remainingAmount;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(_tablesProvider.notifier).fetchAndLoad().then((_) {
        // İlk bölge seçimini yapıyoruz
        final areas = ref.read(_tablesProvider).areas;
        if (areas != null && areas.isNotEmpty) {
          ref.read(_tablesProvider.notifier).selectArea(areas.first.name);
        }
      });
      ref.read(_menuProvider.notifier).fetchAndload();
    });
  }

  @override
  Widget build(BuildContext context) {
    // final authState = ref.watch(authStateProvider);
    final isLoading = ref.watch(loadingProvider);
    final tablesNotifier = ref.read(_tablesProvider.notifier);
    final productItem = ref.watch(_menuProvider).products ?? [];
    final tables = ref.watch(_tablesProvider).tables ?? [];
    final areas = ref.watch(_tablesProvider).areas ?? [];
    final selectedArea = ref.watch(_tablesProvider).selectedValue;

    // Filter items based on the search query, ignoring the selected category during search
    final filteredTables = tables.where((item) {
      // If search query is empty, filter based on the selected category
      final isAreaMatch = item.area == selectedArea;
      return isAreaMatch;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                final area = areas[index];
                                return Container(
                                  width: 180,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: const BorderSide(
                                          color: Colors.black12, width: 1),
                                      bottom: BorderSide(
                                        color: selectedArea == area.name
                                            ? Colors.orange
                                            : Colors
                                                .transparent, // Seçili kategori altına çizgi ekle
                                        width: 5, // Çizginin kalınlığı
                                      ),
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.white,
                                    child: InkWell(
                                      splashColor:
                                          Colors.orange.withOpacity(0.6),
                                      onTap: () {
                                        tablesNotifier.selectArea(area.name);
                                      },
                                      child: Center(
                                        child: Text(
                                          area.name,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              itemCount: areas.length),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (String value) {
                          switch (value) {
                            case 'Masa Ekle':
                              showAddTableDialog(
                                  context, tablesNotifier, selectedArea!);
                              break;
                            case 'Bölge Ekle':
                              showAddAreaDialog(context, tablesNotifier);
                              break;
                            default:
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem<String>(
                              value: 'Masa Ekle',
                              child: Text('Masa Ekle'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Bölge Ekle',
                              child: Text('Bölge Ekle'),
                            ),
                          ];
                        },
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // Masaların Listesi
                if (isLoading == false)
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (constraints.maxWidth / 140).floor(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: filteredTables.length,
                      itemBuilder: (BuildContext context, int index) {
                        final tableId = filteredTables[index].tableId;
                        ref
                            .read(_tablesProvider.notifier)
                            .fetchTableBill(filteredTables[index].tableId!);
                        final tableBill = ref
                            .watch(_tablesProvider.select(
                                (state) => state.getTableBill(tableId!)))
                            .where((item) =>
                                item.isAmount !=
                                true) // `isAmount == true` olanlar filtrelenir
                            .toList();
                        print('ui: $tableBill');

                        final totalAmount = tableBill.fold(
                            0,
                            (sum, item) =>
                                sum + ((item.price ?? 0) * (item.piece ?? 1)));

                        calculateAmount(tableBill, totalAmount, tableId!);

                        final odenenToplamTutar = totalAmount - remainingAmount;
                        return InkWell(
                          onTap: () async {
                            final tableId = filteredTables[index].tableId;
                            final tableQrUrl = filteredTables[index].qrUrl;
                            if (tableId != null) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ResponsiveLayout(
                                      desktopBody: BillView(
                                        orderItems: productItem,
                                        qrUrl: tableQrUrl,
                                        tableId: tableId,
                                      ),
                                      mobileBody: BillMobileView(
                                        tableId: tableId,
                                        orderItems: productItem,
                                        qrUrl: tableQrUrl,
                                      ))));
                            }
                          },
                          child: Container(
                            decoration: tableBill.isNotEmpty
                                ? BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12)),
                                    color: (allItemsPaid &&
                                            tableBill.isNotEmpty)
                                        ? ColorConstants.tableItemPaymentColor
                                        : // Adisyon boş değil ve tüm öğeler ödendi mi?
                                        ColorConstants.tableItemColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  )
                                : BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12)),
                                    image: const DecorationImage(
                                      image: AssetImage(
                                          "assets/images/table_icon.png"),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: tableBill.isNotEmpty
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            '${filteredTables[index].tableId}',
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          Center(
                                            child: odenenToplamTutar != 0
                                                ? Text(
                                                    '₺$totalAmount / ₺$odenenToplamTutar',
                                                    style: TextStyle(
                                                      decoration: (allItemsPaid &&
                                                              tableBill
                                                                  .isNotEmpty)
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration.none,
                                                      fontSize: 20.0,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                : Text(
                                                    '₺$totalAmount',
                                                    style: TextStyle(
                                                      decoration: (allItemsPaid &&
                                                              tableBill
                                                                  .isNotEmpty)
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration.none,
                                                      fontSize: 20.0,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(),
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const SizedBox(),
                                          Text(
                                            '${filteredTables[index].tableId}',
                                            style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void calculateAmount(List<Menu> tableBill, int totalAmount, String tableId) {
    final tableBillAmount = _getTableBillAmount(tableId);
    final negativeAmount = _calculateTotal(tableBillAmount);

    final urunBazliOdenenler =
        tableBill.where((item) => item.status == 'ödendi').toList();
    final urunBazliOdenenToplam = _calculateTotal(urunBazliOdenenler);

    allItemsPaid = _checkIfAllItemsPaid(
      tableBill,
      negativeAmount,
      urunBazliOdenenToplam,
      totalAmount,
    );

    remainingAmount = _calculateRemainingAmount(
      totalAmount,
      negativeAmount,
      urunBazliOdenenToplam,
    );
  }

  List<Menu> _getTableBillAmount(String tableId) {
    return ref
        .watch(_tablesProvider.select((state) => state.getTableBill(tableId)))
        .where((item) => item.isAmount == true)
        .toList();
  }

  int _calculateTotal(List<Menu> items) {
    return items.fold(
        0, (sum, item) => sum + ((item.price ?? 0) * (item.piece ?? 1)));
  }

  bool _checkIfAllItemsPaid(List<Menu> tableBill, int negativeAmount,
      int urunBazliOdenenToplam, int totalAmount) {
    return tableBill.every((item) => item.status == 'ödendi') ||
        (negativeAmount != 0 && negativeAmount == totalAmount) ||
        urunBazliOdenenToplam + negativeAmount == totalAmount;
  }

  int _calculateRemainingAmount(
      int totalAmount, int negativeAmount, int urunBazliOdenenToplam) {
    return totalAmount - negativeAmount - urunBazliOdenenToplam;
  }
}
 */