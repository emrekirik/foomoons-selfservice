import 'package:foomoons/featured/bill/custom_numpad_mobile.dart';
import 'package:foomoons/featured/providers/loading_notifier.dart';
import 'package:foomoons/featured/providers/tables_notifier.dart';
import 'package:foomoons/product/model/menu.dart';
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
  Set<int> selectedIndexes = {};
  Set<int> saveIndexes = {};
  bool isLoading = true;
  double totalAmount = 0;
  double paidAmount = 0;
  double remainingAmount = 0;
  int inputAmount = 0;
  bool isSaving = false;
  bool? isCredit;
  String? errorMessage;
  String selectedPaymentType = 'product';
  late TextEditingController inputController;

  @override
  void initState() {
    super.initState();
    leftList = [];
    rightList = [];
    inputController = TextEditingController();
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
                        _paymentTypeButtons(),
                        _buildCloseButton(context),
                      ],
                    ),
                    Text(
                      'Masa Adı:${widget.tableId}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    selectedPaymentType == 'amount'
                        ? SizedBox(
                            height: 460,
                            child: _amountBased(),
                          )
                        : SizedBox(height: 320, child: _productBased()),
                    const SizedBox(height: 10),
                    SizedBox(height: 320, child: _paidList()),
                    const Divider(),
                    _buildAmountSummary(),
                    if (errorMessage !=
                        null) // Eğer bir hata mesajı varsa göster
                      ErrorMessage(errorMessage: errorMessage),
                    Center(child: _buildSaveButton(context)),
                    const SizedBox(height: 40)
                  ],
                ),
              ),
            ),
          );
  }

  Row _paymentTypeButtons() {
    return Row(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedPaymentType == 'product'
                ? Colors.orange
                : Colors.grey.shade200,
          ),
          onPressed: () {
            setState(() {
              selectedPaymentType = 'product';
            });
          },
          child: const Text(
            'Ürün Bazlı',
            style: TextStyle(color: Colors.black),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedPaymentType == 'amount'
                ? Colors.orange
                : Colors.grey.shade200,
          ),
          onPressed: () {
            setState(() {
              selectedPaymentType = 'amount';
            });
          },
          child: const Text(
            'Tutar Bazlı',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Column _amountBased() {
    return Column(
      children: [
        SizedBox(
          height: 60,
          width: 280,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Ödeme Tutarı',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: inputAmount.toString()),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: CustomNumpadMobile(
            value: remainingAmount.toStringAsFixed(2),
            onInput: (value) {
              setState(() {
                inputAmount = int.tryParse(value.toString()) ?? 0;
              });
            },
          ),
        ),
      ],
    );
  }

  SingleChildScrollView _paidList() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ÖDENENLER',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(),
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
                      Text('₺${(item.price ?? 0) * (item.piece ?? 1)}',
                          style: const TextStyle(fontSize: 16)),
                      item.isCredit != null
                          ? const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Text(
                                'Ödendi',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.green),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
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
        ],
      ),
    );
  }

  SingleChildScrollView _productBased() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ÖDENECEKLER',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leftList.length,
            itemBuilder: (context, index) {
              final item = leftList[index];
              final isSelected = selectedIndexes.contains(index);
              return Card(
                color: isSelected ? Colors.green.shade100 : Colors.white,
                child: ListTile(
                  hoverColor: Colors.transparent,
                  title: Text(item.title ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item.piece ?? 1} adet'),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ), // Seçim simgesi
                    ],
                  ),
                  trailing: Text('₺${(item.price ?? 0) * (item.piece ?? 1)}',
                      style: const TextStyle(fontSize: 16)),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedIndexes.remove(index);
                      } else {
                        selectedIndexes.add(index);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ],
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
                    _processSelectedItems(true);
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
                    _processSelectedItems(false); // Nakit için false
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
      onPressed: () => isSaving || selectedIndexes.isNotEmpty
          ? null
          : _onPayPressed(context),
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

  void _processSelectedItems(bool isCreditSelected) async {
    if (totalAmount == paidAmount) {
      setState(() {
        errorMessage = 'Hesap zaten ödendi.';
      });
      return;
    }
    if (inputAmount > remainingAmount) {
      setState(() {
        errorMessage = 'Hesaptan daha fazla ücret ödeyemezsiniz';
      });
      return;
    }
    List<Menu> itemsToMove = [];
    if (inputAmount != 0) {
      final amount = Menu(
        title: isCreditSelected == true ? 'Kredi' : 'Nakit',
        isCredit: isCreditSelected,
        price: inputAmount,
        status: 'ödendi',
        isAmount: true,
      );
      itemsToMove.add(amount);
      await ref
          .read(_tablesProvider.notifier)
          .addItemToBill(widget.tableId, amount);
    }

    // Eğer selectedIndexes boş değilse, listedeki öğeleri ekle
    if (selectedIndexes.isNotEmpty) {
      itemsToMove.addAll(selectedIndexes.map((index) {
        final item = leftList[index];
        return item.copyWith(
          status: 'ödendi', // Status güncelleniyor
          isCredit: isCreditSelected,
        );
      }).toList());
    }

    // Eğer hala liste boşsa, hata mesajını göster ve işlemi durdur
    if (itemsToMove.isEmpty) {
      setState(() {
        errorMessage = 'Lütfen önce bir veya daha fazla ürün seçin.';
      });
      return;
    }
    setState(() {
      // Sağ listeye ekle
      rightList.addAll(itemsToMove);
      saveIndexes = {...selectedIndexes};
      // Sol listeyi, taşınan ürünlerin `id` değerine göre filtrele
      leftList = leftList.where((item) {
        return !itemsToMove.any((movedItem) => movedItem.id == item.id);
      }).toList();

      selectedIndexes.clear(); // Seçim listesini temizle
      errorMessage = null; // Hata mesajını temizle
    });
    _calculateAmounts();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCreditSelected
              ? 'Seçilen ürünler kredi kartı ile ödendi olarak işaretlendi.'
              : 'Seçilen ürünler nakit ile ödendi olarak işaretlendi.',
        ),
      ),
    );
  }

  /// `ÖDE` butonuna basıldığında sağ listedeki ürünlerin `status` alanını `ödendi` olarak günceller
  Future<void> _onPayPressed(BuildContext context) async {
    ref.read(loadingProvider.notifier).setLoading(true); // isLoading set
    if (isSaving) return; // Eğer zaten kaydediliyorsa işlemi durdur.

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

  void _calculateAmounts() {
    // `isAmount` true olan ürünlerin fiyatlarını filtrele ve çıkar
    double amountItemTotal = rightList
        .where((item) => item.isAmount == true)
        .fold<double>(
            0, (sum, item) => sum + ((item.price ?? 0) * (item.piece ?? 1)));

    // Toplam tutarı hesapla (`isAmount` ürünler hariç)
    totalAmount = leftList.where((item) => item.isAmount != true).fold<double>(
            0, (sum, item) => sum + ((item.price ?? 0) * (item.piece ?? 1))) +
        rightList.where((item) => item.isAmount != true).fold<double>(
            0, (sum, item) => sum + ((item.price ?? 0) * (item.piece ?? 1)));

    // Ödenen tutarı hesapla
    paidAmount = rightList.where((item) => item.isAmount != true).fold<double>(
        0, (sum, item) => sum + ((item.price ?? 0) * (item.piece ?? 1)));

    // Kalan tutarı hesapla
    remainingAmount = totalAmount - paidAmount - amountItemTotal;
    paidAmount = rightList.fold<double>(
        0, (sum, item) => sum + ((item.price ?? 0) * (item.piece ?? 1)));
  }
}

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    super.key,
    required this.errorMessage,
  });

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        errorMessage!,
        style: TextStyle(
          color: errorMessage == 'Lütfen ödeme yöntemi seçin.'
              ? Colors.red
              : Colors.green,
          fontSize: 16,
        ),
      ),
    );
  }
}
