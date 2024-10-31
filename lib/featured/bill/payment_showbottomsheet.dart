import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/tables_notifier.dart';
import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _tablesProvider =
    StateNotifierProvider<TablesNotifier, TablesState>((ref) {
  return TablesNotifier(ref);
});

Future<bool?> paymentBottomSheet(BuildContext context, int tableId) async {
  return await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true, // Enable full-screen scrolling
    builder: (BuildContext context) {
      return _PaymentPage(tableId: tableId);
    },
  );
}

class _PaymentPage extends ConsumerStatefulWidget {
  final int tableId;
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
                      'Masa Adı: Masa ${widget.tableId}',
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
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _moveItemToLeftList(index),
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
    if (isSaving) return;
    setState(() => isSaving = true);
    ref.read(loadingProvider.notifier).setLoading(true);

    final tablesNotifier = ref.read(_tablesProvider.notifier);
    for (var item in rightList) {
      await tablesNotifier.updateBillItemStatus(
          widget.tableId, item.copyWith(status: 'ödendi'));
    }
    for (var item in leftList) {
      await tablesNotifier.updateBillItemStatus(
          widget.tableId, item.copyWith(status: 'bekliyor'));
    }
    ref.read(loadingProvider.notifier).setLoading(false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Ödeme başarıyla tamamlandı ve ürünler güncellendi.')),
    );
    if (mounted) {
      setState(() => isSaving = false);
      Navigator.of(context).pop(true);
    }
  }

  void _moveItemToRightList(int index) {
    setState(() {
      final item = leftList.removeAt(index);
      rightList.add(item.copyWith(status: 'ödendi'));
      _calculateAmounts();
    });
  }

  void _moveItemToLeftList(int index) {
    setState(() {
      final item = rightList.removeAt(index);
      leftList.add(item.copyWith(status: 'bekliyor'));
      _calculateAmounts();
    });
  }
}
