import 'package:foomoons/featured/providers/loading_notifier.dart';
import 'package:foomoons/product/model/category.dart';
import 'package:foomoons/product/model/menu.dart';
import 'package:foomoons/product/model/table.dart';
import 'package:foomoons/product/utility/firebase/user_firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class MenuNotifier extends StateNotifier<MenuState> {
  static const String allCategories = 'Tüm Kategoriler';
  final UserFirestoreHelper _firestoreHelper = UserFirestoreHelper();
  final Ref ref;
  final ImagePicker _picker = ImagePicker();
  MenuNotifier(this.ref) : super(const MenuState());

  Future<void> fetchProducts() async {
    try {
      // Kullanıcı detaylarını al
      final userDetails = await getCurrentUserDetails();
      Query<Map<String, dynamic>> productQuery;

      if (userDetails?['userType'] == 'kafe') {
        // Kafe kullanıcısıysa kendi 'products' koleksiyonunu sorgula
        productQuery = FirebaseFirestore.instance
            .collection('users')
            .doc(_firestoreHelper.currentUser!.uid)
            .collection('products');
      } else if (userDetails!['userType'] == 'çalışan' &&
          userDetails['cafeId'] != null) {
        // Çalışan kullanıcıysa bağlı olduğu kafenin 'products' koleksiyonunu sorgula
        final cafeId = userDetails['cafeId'];
        productQuery = FirebaseFirestore.instance
            .collection('users')
            .doc(cafeId)
            .collection('products');
      } else {
        throw Exception('Yetkisiz kullanıcı');
      }

      // Firestore'dan ürünleri getir
      final response = await productQuery
          .withConverter<Menu>(
            fromFirestore: (snapshot, options) {
              final menu = Menu.fromJson(snapshot.data()!);
              return menu.copyWith(id: snapshot.id); // ID ekleme
            },
            toFirestore: (value, options) => value.toJson(),
          )
          .get();

      final products = response.docs.map((e) => e.data()).toList();
      state = state.copyWith(products: products);
    } catch (e) {
      _handleError(e, 'Ürünleri getirme hatası');
    }
  }

  // Future<void> fetchCategories() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse(
  //           'https://myapiapp123.azurewebsites.net/api/categories/getall'),
  //     );

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = json.decode(response.body);

  //       // "categories" anahtarını kontrol ederek listeyi alıyoruz
  //       final List<dynamic> categoryList = data['data'];

  //       final categories =
  //           categoryList.map((json) => Category.fromJson(json)).toList();
  //       print(categories);
  //       state = state.copyWith(categories: categories);
  //     } else {
  //       throw Exception('APİ Hatası');
  //     }
  //   } catch (e) {
  //     _handleError(e, 'Kategorileri getirme hatası');
  //   }
  // }

  // Kategorileri (categories) Firebase'den getirir.
  Future<void> fetchCategories() async {
    try {
      // Kullanıcı detaylarını al
      final userDetails = await getCurrentUserDetails();
      Query<Map<String, dynamic>> categoryQuery;

      if (userDetails?['userType'] == 'kafe') {
        // Kafe kullanıcısıysa kendi 'categories' koleksiyonunu sorgula
        categoryQuery = FirebaseFirestore.instance
            .collection('users')
            .doc(_firestoreHelper.currentUser!.uid)
            .collection('categories');
      } else if (userDetails?['userType'] == 'çalışan' &&
          userDetails!['cafeId'] != null) {
        // Çalışan kullanıcıysa bağlı olduğu kafenin 'categories' koleksiyonunu sorgula
        final cafeId = userDetails['cafeId'];
        categoryQuery = FirebaseFirestore.instance
            .collection('users')
            .doc(cafeId)
            .collection('categories');
      } else {
        throw Exception('Yetkisiz kullanıcı');
      }

      // Firestore'dan kategorileri getir
      final response = await categoryQuery
          .withConverter<Category>(
            fromFirestore: (snapshot, options) =>
                Category.fromJson(snapshot.data()!),
            toFirestore: (value, options) => value.toJson(),
          )
          .get();

      final categories = response.docs.map((e) => e.data()).toList();
      state = state.copyWith(categories: categories);
    } catch (e) {
      _handleError(e, 'Kategorileri getirme hatası');
    }
  }

  Future<void> fetchAndload() async {
    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      await Future.wait([fetchProducts(), fetchCategories()]);
    } catch (e) {
      _handleError(e, 'Veri yükleme hatası');
    } finally {
      ref.read(loadingProvider.notifier).setLoading(false);
    }
  }

// Future<void> addCategory(Category category) async {
//   try {
//     final url = Uri.parse('https://myapiapp123.azurewebsites.net/api/Categories/add');

//     // JSON formatında request body'yi oluştur
//     final body = jsonEncode({
//       'id': 30, // ID'yi integer olarak gönderiyoruz
//       'name': category.name,
//       'coffeId': '1', // Gerekli alanlar burada belirlenmeli
//     });

//     // HTTP POST isteği gönder
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: body,
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       // Başarılı durum: Yeni kategoriyi state'e ekle
//       state = state.copyWith(
//         categories: [...?state.categories, category],
//       );
//     } else {
//       // Hata durumu
//       throw Exception('Kategori eklenemedi: ${response.statusCode}');
//     }
//   } catch (e) {
//     _handleError(e, 'Kategori Ekleme Hatası');
//   }
// }

  // Kategori ekleme işlemi
  Future<void> addCategory(Category category) async {
    try {
      final categoryCollection =
          _firestoreHelper.getUserCollection('categories');
      final docRef = await categoryCollection.add(category.toJson());
      final newCategory = category.copyWith(id: docRef.id);
      state = state.copyWith(categories: [...?state.categories, newCategory]);
    } catch (e) {
      _handleError(e, 'Kategori Ekleme Hatası');
    }
  }

  /// Add Product (Menu) for the current user
  Future<void> addProduct(Menu newProduct) async {
    try {
      final productCollection = _firestoreHelper.getUserCollection('products');
      final docRef = await productCollection.add(newProduct.toJson());
      final newProductWithId = newProduct.copyWith(id: docRef.id);
      state = state.copyWith(products: [...?state.products, newProductWithId]);
      await fetchProducts();
    } catch (e) {
      _handleError(e, 'Ürün ekleme hatası');
    }
  }

  /// Ürün güncelleme işlemi
  Future<void> updateProduct(
      String productId, Menu updatedMenu, BuildContext context) async {
    try {
      final productDocument =
          _firestoreHelper.getUserDocument('products', productId);
      await productDocument.update(updatedMenu.toJson());
      await fetchProducts();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ürün başarıyla güncellendi')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _handleError(e, 'Ürünü güncelleme hatası');
      }
    }
  }

  /// Ürün stok miktarını sipariş miktarı kadar azaltma işlemi
  Future<void> reduceProductStock(
      String productId, int piece, BuildContext context) async {
    try {
      // Ürünler yüklü değilse yüklemeyi yap
      if (state.products == null || state.products!.isEmpty) {
        print('Ürünler henüz yüklenmedi, fetchProducts çağrılıyor...');
        await fetchProducts(); // Ürünleri yükle
      }

      // Mevcut ürünü bulma
      final product = getProductById(productId);
      print(
          'Güncellenen ürün: ${product?.title}, Mevcut stok: ${product?.stock}');

      if (product == null || product.stock == null) {
        print('Ürün bulunamadı veya stok değeri null: productId: $productId');
        return;
      }

      // Yeni stok miktarını hesapla
      final updatedStock = (product.stock ?? 0) - piece;

      // Eğer stok 0 veya daha az ise, stok güncellemesi yapma ve uyarı mesajı göster
      if (updatedStock < 0) {
        state = state.copyWith(
          stockWarning:
              '${product.title} ürününün yeterli stoğu bulunmamaktadır!',
        );
        print('Stok uyarısı: ${state.stockWarning}');
        return; // Stok güncellemesini durdur
      }

      // Eğer stok 0 ise sadece uyarı mesajı göster
      if (updatedStock == 0) {
        state = state.copyWith(
          stockWarning: '${product.title} ürününün stoğu tükenmiştir!',
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ürününün stoğu tükenmiştir!')),
          );
        }
        print('Stok uyarısı: ${state.stockWarning}');
      }

      // Stok miktarını güncelle
      await updateProductStock(productId, updatedStock, context);
      print('Stok başarıyla güncellendi: $updatedStock');
    } catch (e) {
      print('Stok miktarı güncellenirken hata oluştu: $e');
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserDetails() async {
    final currentUser = _firestoreHelper.currentUser;
    if (currentUser == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    // Kullanıcının Firestore belgesini al
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!userDoc.exists) {
      throw Exception('Kullanıcı bulunamadı');
    }

    return userDoc.data() as Map<String, dynamic>?;
  }

  // stock güncelleme işlemi
  Future<void> updateProductStock(
      String productId, int? updatedStock, BuildContext context) async {
    try {
      final productDocument =
          _firestoreHelper.getUserDocument('products', productId);

      // Fetch existing product data
      final productSnapshot = await productDocument.get();
      final existingData = productSnapshot.data();

      if (existingData != null) {
        // Update only the stock field
        final updatedData = {
          'stock': updatedStock,
        };

        // Update only the stock field in Firestore
        await productDocument.update(updatedData);
        await fetchProducts(); // Refresh products after update

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ürün stoğu başarıyla güncellendi')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _handleError(e, 'Ürünü güncelleme hatası');
      }
    }
  }

  Menu? getProductById(String productId) {
    return state.products?.firstWhere(
      (product) => product.id == productId,
      orElse: () =>
          const Menu(), // Return a default `Menu` object instead of `null`
    );
  }

  /// Ürün silme işlemi
  Future<void> deleteProduct(String productId, BuildContext context) async {
    try {
      final productDocument =
          _firestoreHelper.getUserDocument('products', productId);
      await productDocument.delete();
      await fetchProducts(); // Sipariş listesini güncelle

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ürün başarıyla silindi')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _handleError(e, 'Ürünü silme hatası');
      }
    }
  }

  // Web ortamı için resim seçip yükleme işlemi
  Future<void> pickAndUploadImage() async {
    try {
      // Oturum açmış olan kullanıcıyı alıyoruz
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      // Galeriden bir resim seçiyoruz
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // Yükleme işlemine başlıyoruz
        state = state.copyWith(isUploading: true);

        // Seçilen dosya File değil, XFile olduğu için web'de direkt XFile'dan yükleme yapıyoruz
        final String fileName =
            'product_pictures/${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Firebase Storage'a dosyayı yüklüyoruz
        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child(fileName)
            .putData(await pickedFile
                .readAsBytes()); // Web'de readAsBytes() kullanıyoruz

        TaskSnapshot snapshot = await uploadTask;
        String downloadURL = await snapshot.ref.getDownloadURL();

        // Firestore'da profil resmi URL'sini güncelle
        await updateProfilePhotoURL(downloadURL, currentUser.uid);
      }
    } catch (e, stackTrace) {
      print('Fotoğraf seçilirken hata oluştu: $e');
      print('Hata Yığını: $stackTrace');
    } finally {
      // Yükleme tamamlandı, durumu güncelle
      state = state.copyWith(isUploading: false);
    }
  }

  Future<void> updateProfilePhotoURL(String photoURL, String userId) async {
    try {
      final documentRef =
          FirebaseFirestore.instance.collection('productImage').doc(userId);

      final docSnapshot = await documentRef.get();

      if (docSnapshot.exists) {
        // Eğer belge mevcutsa, photoURL'yi güncelle
        await documentRef.update({
          'photoURL': photoURL,
        });
      } else {
        // Eğer belge yoksa, photoURL ile yeni bir belge oluştur
        await documentRef.set({
          'photoURL': photoURL,
        });
      }

      // Lokal durumu güncelle
      state = state.copyWith(photoURL: photoURL);
    } catch (e) {
      print('Profil fotoğrafı güncellenirken hata oluştu: $e');
    }
  }

  /// Seçili kategoriyi günceller
  void selectCategory(String? categoryName) {
    state = state.copyWith(selectedValue: categoryName);
  }

  /// Hata yönetimi
  void _handleError(Object e, String message) {
    print(
        '$message: $e'); // Hataları loglayın veya bir hata yönetimi mekanizması kullanın
  }

  void resetState() {
    state = const MenuState(); // Reset to the initial state
  }

  void resetPhotoUrl() {
    state = state.copyWith(photoURL: null);
  }
}

class MenuState extends Equatable {
  const MenuState(
      {this.products,
      this.categories,
      this.selectedValue,
      this.tables,
      this.tableBills = const {},
      this.stockWarning,
      this.isUploading = false,
      this.photoURL});

  final List<Menu>? products;
  final List<Category>? categories;
  final String? selectedValue;
  final List<CoffeTable>? tables;
  final Map<int, List<Menu>> tableBills;
  final String? stockWarning;
  final bool isUploading;
  final String? photoURL;

  @override
  List<Object?> get props => [
        products,
        categories,
        selectedValue,
        tables,
        tableBills,
        stockWarning,
        isUploading,
        photoURL
      ];

  MenuState copyWith({
    List<Menu>? products,
    List<Category>? categories,
    String? selectedValue,
    List<CoffeTable>? tables,
    Map<int, List<Menu>>? tableBills,
    String? stockWarning,
    bool? isUploading,
    String? photoURL,
  }) {
    return MenuState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedValue: selectedValue ?? this.selectedValue,
      tables: tables ?? this.tables,
      tableBills: tableBills ?? this.tableBills,
      stockWarning: stockWarning ?? this.stockWarning,
      isUploading: isUploading ?? this.isUploading,
      photoURL: photoURL ?? this.photoURL,
    );
  }
}
