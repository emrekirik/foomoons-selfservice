import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:foomoons/product/model/menu.dart';

class NetworkPrinter {
  final String ipAddress;

  NetworkPrinter({this.ipAddress = '192.168.1.165'});

  // Türkçe karakterleri ESC/POS uyumlu karakterlere dönüştür
  String convertTurkishChars(String text) {
    return text
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'I')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'G')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'U')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 'S')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'O')
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'C');
  }

  Future<List<int>> testTicket(List<Menu> billItems) async {
    try {
      print('Generating test ticket...');
      final profile = await CapabilityProfile.load();
      print('Profile loaded: ${profile.name}');
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      // Logo/Başlık bölümü
      bytes += generator.text(convertTurkishChars('FAKULTE KARABUK'),
          styles: const PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            align: PosAlign.center,
            bold: true,
          ));
      bytes += generator.feed(1);
      // Tarih
      bytes += generator.text('  ${DateTime.now().toString().substring(0, 19)}',
          styles: const PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            align: PosAlign.left,
          ));

      // Başlık satırı
      bytes += generator.text(convertTurkishChars('  URUN${' ' * 27}FIYAT'));
      bytes += generator.text('----------------------------------------');

      // Ürünler
      double total = 0;
      final Map<String, Map<String, dynamic>> groupedItems = {};

      // Ürünleri grupla
      for (final item in billItems) {
        final itemTitle = convertTurkishChars(item.title ?? "Bilinmeyen Urun");
        if (!groupedItems.containsKey(itemTitle)) {
          groupedItems[itemTitle] = {
            'count': 1,
            'price': item.price ?? 0,
            'total': item.price ?? 0,
            'isCredit': item.isCredit
          };
        } else {
          groupedItems[itemTitle]?['count'] =
              (groupedItems[itemTitle]?['count'] ?? 0) + 1;
          groupedItems[itemTitle]?['total'] =
              (groupedItems[itemTitle]?['total'] ?? 0) + (item.price ?? 0);
          // Son eklenen ürünün ödeme tipini kullan
          groupedItems[itemTitle]?['isCredit'] = item.isCredit;
        }
      }

      // Gruplanmış ürünleri yazdır
      for (final entry in groupedItems.entries) {
        final itemText = entry.key;
        final count = entry.value['count'];
        final totalPrice = entry.value['total'];
        final isCredit = entry.value['isCredit'];
        total += totalPrice;

        final itemWithCount = '$itemText (${count}x)';
        final paymentType =
            isCredit == null ? '' : (isCredit == true ? 'Kredi' : 'Nakit');
        final priceStr = '${totalPrice.toStringAsFixed(2)} TL'.padLeft(4);

        // Eğer ürün ismi 11 karakterden uzunsa
        if (itemWithCount.length > 11) {
          // İlk satır: ilk 11 karakter, ödeme tipi ve fiyat
          final firstLine = itemWithCount.substring(0, 11).padRight(20);
          bytes += generator
              .text('  $firstLine${paymentType.padRight(10)}$priceStr');

          // Kalan karakterler
          final remainingText = itemWithCount.substring(11);
          // Kalan metni 30 karakterlik bloklara böl
          for (var i = 0; i < remainingText.length; i += 30) {
            final end =
                i + 30 < remainingText.length ? i + 30 : remainingText.length;
            final line = remainingText.substring(i, end);
            bytes += generator.text('  $line');
          }
        } else {
          // Normal durum: tek satır
          final itemStr = itemWithCount.padRight(20);
          bytes +=
              generator.text('  $itemStr${paymentType.padRight(10)}$priceStr');
        }
      }

      bytes += generator.text('========================================');

      // Toplam tutar
      bytes += generator.text(
          '  TOPLAM:${' ' * 23}${total.toStringAsFixed(2)} TL',
          styles: const PosStyles(bold: true));
      bytes += generator.feed(1);
      // Alt bilgi
      bytes += generator.text(convertTurkishChars('Iyi Calismalar :)'),
          styles: const PosStyles(
              height: PosTextSize.size2,
              width: PosTextSize.size2,
              align: PosAlign.center,
              bold: true));
      bytes += generator.text('Wifi: fakulteynk',
          styles: const PosStyles(
              height: PosTextSize.size2,
              width: PosTextSize.size2,
              align: PosAlign.center,
              bold: true));
      bytes += generator.cut();

      print(
          'Test ticket generated successfully. Bytes length: ${bytes.length}');
      return bytes;
    } catch (e) {
      print('Error generating test ticket: $e');
      rethrow;
    }
  }

  Future<void> printTicket(List<int> ticket) async {
    try {
      print('Connecting to printer at IP: $ipAddress');
      final printer = PrinterNetworkManager(ipAddress);

      print('Attempting to connect to printer...');
      PosPrintResult connect = await printer.connect();
      print('Connection result: ${connect.msg}');

      if (connect == PosPrintResult.success) {
        print(
            'Successfully connected to printer. Attempting to print ticket...');
        PosPrintResult printing = await printer.printTicket(ticket);
        print('Print result: ${printing.msg}');

        if (printing != PosPrintResult.success) {
          throw Exception('Failed to print: ${printing.msg}');
        }

        print('Disconnecting from printer...');
        await printer.disconnect();
        print('Successfully disconnected from printer');
      } else {
        throw Exception('Failed to connect to printer: ${connect.msg}');
      }
    } catch (e) {
      print('Error in printTicket: $e');
      rethrow;
    }
  }
}
