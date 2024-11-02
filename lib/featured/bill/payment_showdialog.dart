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
  bool isLoading = true;
  double totalAmount = 0; // Toplam tutar
  double paidAmount = 0; // Ödenen tutar
  double remainingAmount = 0; // Kalan tutar
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    leftList = []; // Başlangıçta sol listeyi boş olarak tanımla
    rightList = []; // Başlangıçta sağ listeyi boş olarak tanımla

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

  /// Toplam tutar, ödenen tutar ve kalan tutarı hesaplar
  void _calculateAmounts() {
    // Toplam tutarı hesapla (leftList ve rightList'in toplamı, adet ile çarpılarak)
    totalAmount = leftList.fold<double>(
            0, (sum, item) => sum + ((item.price ?? 0) * (item.piece ?? 1))) +
        rightList.fold<double>(
            0, (sum, item) => sum + ((item.price ?? 0) * (item.piece ?? 1)));

    // Ödenen tutarı hesapla (rightList'in toplamı, adet ile çarpılarak)
    paidAmount = rightList.fold<double>(
        0, (sum, item) => sum + ((item.price ?? 0) * (item.piece ?? 1)));

    // Kalan tutarı hesapla (toplam tutar - ödenen tutar)
    remainingAmount = totalAmount - paidAmount;
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Column(
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
              'Masa Adı: Masa ${widget.tableId}',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
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
                    // Sol Liste
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              'ÖDENECEKLER',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: leftList.length,
                              itemBuilder: (BuildContext context, int index) {
                                final item = leftList[index];
                                return Card(
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      hoverColor: Colors
                                          .transparent, // İmleç üzerinde iken gölge çıkmasını engeller

                                      onTap: () {
                                        _moveItemToRightList(index);
                                      },
                                      title: Text(item.title ?? ''),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            style: TextStyle(fontSize: 16),
                                          ), // Her bir item için toplam fiyat
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Sağ Liste
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(
                                    color: Colors.grey.withOpacity(0.4),
                                    width: 1))),
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
                                separatorBuilder: (context, index) =>
                                    const Divider(),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.remove_circle_outline),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Toplam Tutar:',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Text(
                                        '₺$totalAmount',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Ödenen Tutar: ',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Text(
                                        '₺$paidAmount',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 28,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Kalan Tutar:',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Text(
                                        '₺$remainingAmount',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
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
          onPressed: () => isSaving ? null : _onPayPressed(context),
        ),
        TextButton(
          style: TextButton.styleFrom(
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
      final updatedItem = item.copyWith(status: 'ödendi');
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
      });
      await _updateItemStatus(item); // Statü güncellemesini bekleyin
      _calculateAmounts(); // Tutarları yeniden hesaplayın
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
      });
      await _updateItemStatus(updatedItem); // Statü güncellemesini bekleyin
      _calculateAmounts(); // Tutarları yeniden hesaplayın
    }
  }
}
