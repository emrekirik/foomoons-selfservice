import 'package:altmisdokuzapp/featured/bill/bill_mobile_view.dart';
import 'package:altmisdokuzapp/featured/bill/bill_view.dart';
import 'package:altmisdokuzapp/featured/providers/admin_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/menu_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/tables_notifier.dart';
import 'package:altmisdokuzapp/featured/responsive/responsive_layout.dart';
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
      ref.read(_tablesProvider.notifier).fetchAndLoad();
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

    // // Eğer kullanıcı giriş yapmamışsa, "Giriş yapmadı" mesajı gösterin
    // if (authState.asData?.value == null) {
    //   return const Center(
    //     child: Text('Kullanıcı Giriş Yapmadı'),
    //   );
    // }
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
                        children: [
                          const Expanded(
                            flex: 8,
                            child: Text(
                              'Masalar',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: IconButton(
                              onPressed: () {
                                showAddTableDialog(context, tablesNotifier);
                              },
                              icon: const Icon(
                                Icons.add,
                                color: Colors.black,
                              ),
                            ),
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
                          itemCount: tables.length,
                          itemBuilder: (BuildContext context, int index) {
                            ref
                                .read(_tablesProvider.notifier)
                                .fetchTableBill(tables[index].tableId!);
                            final tableBill = ref.watch(_tablesProvider.select(
                                (state) => state
                                    .getTableBill(tables[index].tableId!)));
                            bool allItemsPaid = tableBill
                                .every((item) => item.status == 'ödendi');
                            return InkWell(
                              onTap: () async {
                                final tableId = tables[index].tableId;
                                final tableQrUrl = tables[index].qrUrl;
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
                                                'Masa ${tables[index].tableId}',
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
                                                'Masa ${tables[index].tableId}',
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
