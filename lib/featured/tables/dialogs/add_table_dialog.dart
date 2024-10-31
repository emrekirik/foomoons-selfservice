import 'package:altmisdokuzapp/featured/providers/tables_notifier.dart';
import 'package:flutter/material.dart';
import 'package:altmisdokuzapp/product/model/table.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Make sure to import the correct package

void showAddTableDialog(BuildContext context, TablesNotifier tablesNotifier) {
  final TextEditingController tableIdController = TextEditingController();
  String? qrData;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Masa Ekle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tableIdController,
                    decoration: const InputDecoration(hintText: "Masa ID'si"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  if (qrData != null)
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: QrImageView(
                        data: qrData!,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('İptal'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('QR Kod Oluştur'),
                onPressed: () {
                  final tableIdText = tableIdController.text;
                  if (tableIdText.isNotEmpty) {
                    final tableId = int.parse(tableIdText);
                    final String qrCode =
                        tablesNotifier.generateQRCode(tableId);
                    setState(() {
                      qrData = qrCode;
                    });
                  }
                },
              ),
              TextButton(
                child: const Text('Masa Ekle'),
                onPressed: qrData == null
                    ? null
                    : () {
                        final tableIdText = tableIdController.text;
                        if (tableIdText.isNotEmpty) {
                          final tableId = int.parse(tableIdText);
                          final newTable =
                              CoffeTable(tableId: tableId, qrUrl: qrData);
                          tablesNotifier.addTable(newTable);
                        }
                        Navigator.of(context).pop();
                      },
              ),
            ],
          );
        },
      );
    },
  );
}
