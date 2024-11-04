import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/tables_notifier.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _tablesProvider =
    StateNotifierProvider<TablesNotifier, TablesState>((ref) {
  return TablesNotifier(ref);
});

Future<bool?> paymentBottomSheet(BuildContext context, String tableId) async {
  return await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true, // Enable full-screen scrolling
    builder: (BuildContext context) {
      return _PaymentPage(tableId: tableId);
    },
  );
}

class _PaymentPage extends ConsumerStatefulWidget {
  final String tableId;
  const _PaymentPage({
    required this.tableId,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<_PaymentPage> {
  late List<Menu> leftList;
  late List<Menu> rightList;
  bool isLoading = true;
  double totalAmount = 0;
  double paidAmount = 0;
  double remainingAmount = 0;
  bool isSaving = false;
  bool? isCredit;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    leftList = [];
    rightList = [];
    _loadTableData(); // Load data asynchronously
  }

  Future<void> _loadTableData() async {
    await ref.read(_tablesProvider.notifier).fetchTableBill(widget.tableId);
    final initialItems = ref.read(_tablesProvider).getTableBill(widget.tableId);

    if (mounted) {
      setState(() {
        leftList =
            initialItems.where((item) => item.status != 'ödendi').toList();
        rightList =
            initialItems.where((item) => item.status == 'ödendi').toList();
        _calculateAmounts();
        isLoading = false;
      });
    }
  }

  void _calculateAmounts() {
    totalAmount = leftList.fold<double>(
            0, (sum, item) => sum + ((item.price ?? 0) * (item.piece ?? 1))) +
        rightList.fold<double>(
            0, (sum, item) => sum + ((item.price ?? 0) * (item.piece ?? 1)));
    paidAmount = rightList.fold<double>(
        0, (sum, item) => sum + ((item.price ?? 0) * (item.piece ?? 1)));
    remainingAmount = totalAmount - paidAmount;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16))),
            height: MediaQuery.of(context).size.height *
                0.8, // Limit to 80% screen height
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Hesap',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        _buildCloseButton(context),
                      ],
                    ),
                    Text(
                      'Masa Adı:${widget.tableId}',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'ÖDENECEKLER',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: leftList.length,
                      itemBuilder: (context, index) {
                        final item = leftList[index];
                        return Card(
                          color: Colors.white,
                          child: ListTile(
                            title: Text(item.title ?? ''),
                            subtitle: Text('${item.piece ?? 1} adet'),
                            trailing: Text(
                                '₺${(item.price ?? 0) * (item.piece ?? 1)}',
                                style: const TextStyle(fontSize: 16)),
                            onTap: () => _moveItemToRightList(index),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'ÖDENENLER',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rightList.length,
                      itemBuilder: (context, index) {
                        final item = rightList[index];
                        return Card(
                          color: Colors.white,
                          child: ListTile(
                            title: Text(item.title ?? ''),
                            subtitle: Text('${item.piece ?? 1} adet'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    '₺${(item.price ?? 0) * (item.piece ?? 1)}',
                                    style: const TextStyle(fontSize: 16)),
                                item.isCredit != null
                                    ? const Padding(
                                        padding: EdgeInsets.only(left: 4),
                                        child: Text(
                                          'Ödendi',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green),
                                        ),
                                      )
                                    : IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                        onPressed: () {
                                          _moveItemToLeftList(index);
                                        },
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    _buildAmountSummary(),
                    Center(child: _buildSaveButton(context)),
                    if (errorMessage !=
                        null) // Eğer bir hata mesajı varsa göster
                      Center(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(
                            color: errorMessage == 'Lütfen ödeme yöntemi seçin.'
                                ? Colors.red
                                : Colors.green,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildAmountSummary() {
    return Column(
      children: [
        _buildAmountRow('Toplam Tutar:', '₺$totalAmount'),
        _buildAmountRow('Ödenen Tutar:', '₺$paidAmount'),
        _buildAmountRow('Kalan Tutar:', '₺$remainingAmount'),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      backgroundColor:
                          isCredit == true ? Colors.orange : Colors.transparent,
                      shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(4))),
                  onPressed: () {
                    setState(() {
                      isCredit = isCredit == true
                          ? null
                          : true; // Eğer true ise null yap, değilse true yap
                      errorMessage = null;
                    });
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Kredi Kartı',
                        style: TextStyle(color: Colors.black)),
                  )),
              const SizedBox(width: 4),
              OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      backgroundColor:
                          isCredit == false ? Colors.green : Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4))),
                  onPressed: () {
                    setState(() {
                      isCredit = isCredit == false
                          ? null
                          : false; // Eğer true ise null yap, değilse true yap
                      errorMessage = null;
                    });
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    child: Text('Nakit', style: TextStyle(color: Colors.black)),
                  )),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildAmountRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          backgroundColor: Colors.orange,
          side: const BorderSide(color: Colors.orange)),
      onPressed: isSaving ? null : () => _onPayPressed(context),
      child: const Padding(
        padding: EdgeInsets.all(4.0),
        child:
            Text('Kaydet', style: TextStyle(fontSize: 20, color: Colors.black)),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Padding(
        padding: EdgeInsets.all(4.0),
        child:
            Text('İptal', style: TextStyle(fontSize: 16, color: Colors.black)),
      ),
    );
  }

  Future<void> _onPayPressed(BuildContext context) async {
    ref.read(loadingProvider.notifier).setLoading(true); // isLoading set
    if (isSaving) return; // Eğer zaten kaydediliyorsa işlemi durdur.
    if (isCredit == null) {
      setState(() {
        errorMessage = 'Lütfen ödeme yöntemi seçin.';
      });
      ref.read(loadingProvider.notifier).setLoading(false);
      return; // Tüm işlemi durdur
    }
    setState(() {
      isSaving = true; // Kaydetme işlemi başladı
    });

    final tablesNotifier = ref.read(_tablesProvider.notifier);

    // Sağ liste (rightList) içerisindeki her bir öğeyi güncelle
    for (var item in rightList) {
      final updatedItem = item.isCredit == null
          ? item.copyWith(status: 'ödendi', isCredit: isCredit)
          : item.copyWith(status: 'ödendi');
      await tablesNotifier.updateBillItemStatus(widget.tableId, updatedItem);
    }
    // Sol listeyi kaydetmeden önce işlem tamamlanana kadar bekle
    for (var item in leftList) {
      final updatedItem = item.copyWith(status: 'bekliyor');
      await tablesNotifier.updateBillItemStatus(widget.tableId, updatedItem);
    }

    // Güncelleme tamamlandığında Snackbar veya başka bir geri bildirim gösterilebilir
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ödeme başarıyla tamamlandı ve ürünler güncellendi.'),
        ),
      );
      setState(() {
        isSaving = false; // Kaydetme işlemi tamamlandı
      });
      // İşlem tamamlandıktan sonra dialog kapatılabilir
      ref.read(loadingProvider.notifier).setLoading(false); // isLoading set
      Navigator.of(context).pop(true);
    }
  }

  void _moveItemToRightList(int index) async {
    if (index >= 0 && index < leftList.length) {
      final item = leftList[index]; // Öğeyi çıkarırken referans al
      setState(() {
        leftList.removeAt(index); // Sadece geçerli bir index varsa çıkar
        rightList.add(item.copyWith(
            status: 'ödendi')); // Sağ listeye ekle ve statüyü güncelle
        _calculateAmounts(); // Tutarları yeniden hesaplayın
      });
    }
  }

  void _moveItemToLeftList(int index) async {
    if (index >= 0 && index < rightList.length) {
      final item = rightList[index]; // Öğeyi çıkarırken referans al

      // Status'ü bekliyor olarak güncelle
      final updatedItem = item.copyWith(status: 'bekliyor');
      setState(() {
        rightList.removeAt(index); // Sadece geçerli bir index varsa çıkar
        leftList.add(updatedItem); // Sol listeye ekle ve statüyü güncelle
        _calculateAmounts(); // Tutarları yeniden hesaplayın
      });
    }
  }
}
