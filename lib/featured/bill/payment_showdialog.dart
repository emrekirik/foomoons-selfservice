import 'package:altmisdokuzapp/featured/bill/custom_numpad.dart';
import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/tables_notifier.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _tablesProvider =
    StateNotifierProvider<TablesNotifier, TablesState>((ref) {
  return TablesNotifier(ref);
});

Future<bool?> paymentShowDialog(BuildContext context, String tableId) async {
  return await showDialog<bool>(
    context: context,
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
  late List<Menu> leftList; // Sol listede yer alan ürünler
  late List<Menu> rightList; // Sağ listede yer alan ürünler
  Set<int> selectedIndexes = {};
  Set<int> saveIndexes = {};
  bool isLoading = true;
  double totalAmount = 0; // Toplam tutar
  double paidAmount = 0; // Ödenen tutar
  double remainingAmount = 0; // Kalan tutar
  int inputAmount = 0;
  bool isSaving = false;
  bool? isCredit;
  String? errorMessage;
  String selectedPaymentType = 'product';
  late TextEditingController inputController;

  @override
  void initState() {
    super.initState();
    leftList = []; // Başlangıçta sol listeyi boş olarak tanımla
    rightList = []; // Başlangıçta sağ listeyi boş olarak tanımla
    inputController = TextEditingController();
    // Tabloya ait adisyon verilerini yükleyin ve sol listeye ekleyin.
    Future.microtask(() async {
      await ref.read(_tablesProvider.notifier).fetchTableBill(widget.tableId);
      final initialItems = ref
          .read(_tablesProvider)
          .getTableBill(widget.tableId); // Başlangıçtaki öğeler

      // Eğer adisyon öğeleri yüklenmişse sol listeye ekle ve durumu güncelle.
      if (mounted) {
        setState(() {
          // Sol listeyi `ödendi` olmayan öğelerle doldur
          leftList =
              initialItems.where((item) => item.status != 'ödendi').toList();
          // Sağ listeyi `ödendi` olan öğelerle doldur
          rightList =
              initialItems.where((item) => item.status == 'ödendi').toList();

          // Tutar bilgilerini hesapla
          _calculateAmounts();
          isLoading = false; // Yükleme işlemi tamamlandı
        });
      }
    });
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    print(isCredit);
    print(errorMessage);
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hesap',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Masa Adı: ${widget.tableId}',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Row(
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
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      isCredit == true ? Colors.orange : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () {
                  _processSelectedItems(true); // Kredi kartı için true
                },
                icon: const Icon(
                  Icons.credit_card,
                  color: Colors.black,
                ),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Kredi Kartı',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      isCredit == false ? Colors.green : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () {
                  _processSelectedItems(false); // Nakit için false
                },
                icon: const Icon(
                  Icons.attach_money,
                  color: Colors.black,
                ),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Text('Nakit', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
      content: Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(8)),
        width: deviceWidth * 0.75,
        height: deviceHeight * 0.6,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    selectedPaymentType == 'amount'
                        ? Expanded(
                            child: Column(
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
                                      controller: TextEditingController(
                                          text: inputAmount.toString()),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: CustomNumpad(
                                    value: remainingAmount.toStringAsFixed(2),
                                    onInput: (value) {
                                      setState(() {
                                        inputAmount =
                                            int.tryParse(value.toString()) ?? 0;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _leftListViewOrders(),
                    // Sağ Liste
                    _rightListView(),
                  ],
                ),
              ),
      ),
      actions: <Widget>[
        if (errorMessage != null) // Eğer bir hata mesajı varsa göster
          Text(
            errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: (isSaving || selectedIndexes.isNotEmpty)
                  ? Colors.grey // Pasif durum
                  : Colors.blue, // Aktif durum
              foregroundColor: Colors.white, // Metin rengi
              disabledBackgroundColor:
                  Colors.grey, // Pasif durumdaki arka plan rengi
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Kaydet',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          onPressed: () => isSaving || selectedIndexes.isNotEmpty
              ? null
              : _onPayPressed(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Kapat',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Expanded _rightListView() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                left:
                    BorderSide(color: Colors.grey.withOpacity(0.4), width: 1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                'ÖDENENLER',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => const Divider(),
                itemCount: rightList.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = rightList[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          item.title ?? '',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${item.piece ?? 1} adet'),
                          ],
                        ), // Fiyat null ise 0 olarak göster
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₺${(item.price ?? 0) * (item.piece ?? 1)}',
                              style: const TextStyle(fontSize: 16),
                            ),
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
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      _moveItemToLeftList(index);
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(),
            // Toplam Tutar, Ödenen Tutar ve Kalan Tutar bilgilerini göster
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam Tutar:',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        '₺$totalAmount',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ödenen Tutar: ',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        '₺$paidAmount',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kalan Tutar:',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        '₺$remainingAmount',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded _leftListViewOrders() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              'ÖDENECEKLER',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: leftList.length,
              itemBuilder: (BuildContext context, int index) {
                final item = leftList[index];
                final isSelected = selectedIndexes.contains(index);

                return Card(
                  color: isSelected ? Colors.green.shade100 : Colors.white,
                  child: ListTile(
                    hoverColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedIndexes.remove(index);
                        } else {
                          selectedIndexes.add(index);
                        }
                      });
                    },
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
                    trailing: Text(
                      '₺${(item.price ?? 0) * (item.piece ?? 1)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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

    double selectedItemsTotal = selectedIndexes.fold<double>(
      0.0,
      (total, index) => total + (leftList[index].price ?? 0.0),
    );

    if (inputAmount > remainingAmount || selectedItemsTotal > remainingAmount) {
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

  /// `status` alanını güncellemek için `TablesNotifier` fonksiyonunu çağır
  Future<void> _updateItemStatus(Menu item) async {
    final tablesNotifier = ref.read(_tablesProvider.notifier);
    await tablesNotifier.updateBillItemStatus(widget.tableId, item);
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
