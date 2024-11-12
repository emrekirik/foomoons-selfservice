import 'package:altmisdokuzapp/featured/bill/bill_mobile_view.dart';
import 'package:altmisdokuzapp/featured/bill/bill_view.dart';
import 'package:altmisdokuzapp/featured/providers/admin_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/menu_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/tables_notifier.dart';
import 'package:altmisdokuzapp/featured/responsive/responsive_layout.dart';
import 'package:altmisdokuzapp/featured/tables/dialogs/add_areas_dialog.dart';
import 'package:altmisdokuzapp/featured/tables/dialogs/add_table_dialog.dart';
import 'package:altmisdokuzapp/product/constants/color_constants.dart';
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

final _adminProvider = StateNotifierProvider<AdminNotifier, HomeState>((ref) {
  return AdminNotifier(ref);
});

/// MenuView Widget
class TablesView extends ConsumerStatefulWidget {
  final String? successMessage;
  const TablesView({this.successMessage, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TablesViewState();
}

class _TablesViewState extends ConsumerState<TablesView> {
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
    final deviceWidth = MediaQuery.of(context).size.width;
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: ColorConstants.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
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
                                            tablesNotifier
                                                .selectArea(area.name);
                                          },
                                          child: Center(
                                            child: Text(
                                              area.name ?? '',
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
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                (constraints.maxWidth / 180).floor(),
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
                                .watch(_tablesProvider.select((state) =>
                                    state.getTableBill(tableId!)))
                                .where((item) =>
                                    item.isAmount !=
                                    true) // `isAmount == true` olanlar filtrelenir
                                .toList();
                            final totalAmount = tableBill.fold(
                                0,
                                (sum, item) =>
                                    sum +
                                    ((item.price ?? 0) * (item.piece ?? 1)));
                            final tableBillAmount = ref
                                .watch(_tablesProvider.select((state) =>
                                    state.getTableBill(tableId!)))
                                .where((item) =>
                                    item.isAmount ==
                                    true) // `isAmount == true` olanlar filtrelenir
                                .toList();
                            final negativeAmount = tableBillAmount.fold(
                                0,
                                (sum, item) =>
                                    sum +
                                    ((item.price ?? 0) * (item.piece ?? 1)));
                            bool negativeAmountFull = negativeAmount != 0 &&
                                negativeAmount == totalAmount;
                            bool allItemsPaid = tableBill
                                    .every((item) => item.status == 'ödendi') ||
                                negativeAmountFull;
                            final remainingAmount =
                                totalAmount - negativeAmount;
                            return InkWell(
                              onTap: () async {
                                final tableId = filteredTables[index].tableId;
                                final tableQrUrl = filteredTables[index].qrUrl;
                                if (tableId != null) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ResponsiveLayout(
                                          desktopBody: BillView(
                                            tableId: tableId,
                                            orderItems: productItem,
                                            qrUrl: tableQrUrl,
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
                                            ? ColorConstants
                                                .tableItemPaymentColor
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
                                                child: Text(
                                                  '₺${tableBill.fold(0, (sum, item) => sum + ((item.price ?? 0) * (item.piece ?? 1)))}',
                                                  style: TextStyle(
                                                    decoration: (allItemsPaid &&
                                                            tableBill
                                                                .isNotEmpty)
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : TextDecoration.none,
                                                    fontSize: 20.0,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
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
                                                    fontSize: 24.0,
                                                    fontWeight:
                                                        FontWeight.bold),
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
            ),
          ),
        );
      },
    );
  }
}
