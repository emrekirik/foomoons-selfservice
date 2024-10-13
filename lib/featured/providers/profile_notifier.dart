import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this.ref) : super(const ProfileState());

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final Ref ref; // Ref instance to manage the global provider

  // Fetch the user's profile information from Firestore and FirebaseAuth
  Future<void> fetchProfileInfo() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Fetching user profile from FirebaseAuth
        final String? name = user.displayName; // Kullanıcının adı (displayName)
        final String? email = user.email; // Kullanıcının e-posta adresi

        // Fetching additional user profile data from Firestore
        final profileDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (profileDoc.exists) {
          final data = profileDoc.data()!;
          state = state.copyWith(
            name: name ?? data['name'] ?? '',
            email: email ?? '',
            phoneNumber: data['phoneNumber'] ?? '',
            businessName: data['businessName'] ?? '',
            businessAddress: data['businessAddress'] ?? '',
            businessInfo: data['businessInfo'] ?? '',
          );
        } else {
          // Firestore'da kullanıcı profili yoksa, Authentication'dan gelen verileri güncelleyebilirsiniz
          state = state.copyWith(
            name: name ?? '',
            email: email ?? '',
          );
        }
      } else {
        // Kullanıcı oturum açmamışsa
        state = state.copyWith(errorMessage: 'Kullanıcı oturum açmamış.');
      }
    } catch (e) {
      state = state.copyWith(
          errorMessage: 'Profil bilgileri çekilirken hata oluştu: $e');
    }
  }

  // Firestore'dan profil fotoğrafı URL'sini çekiyoruz
  Future<void> fetchProfilePhotoURL() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      // Firestore'dan kullanıcıya ait photoURL'yi çekiyoruz
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        // photoURL'yi al ve state'i güncelle
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
        String? photoURL = data?['photoURL'] as String?;

        state = state.copyWith(photoURL: photoURL); // state güncelle
      }
    } catch (e) {
      print('Profil fotoğrafı çekilirken hata oluştu: $e');
    }
  }

  Future<void> fetchAndLoad() async {
    ref.read(loadingProvider.notifier).setLoading(true);
    try {
      await Future.wait([fetchProfileInfo(), fetchProfilePhotoURL()]);
    } catch (e) {
      _handleError(e, 'Veri yükleme hatası');
    } finally {
      ref.read(loadingProvider.notifier).setLoading(false);
    }
  }

  // Update the user's profile information in Firestore
  Future<void> updateProfileInfo({
    required String fieldName, // Güncellenecek alan adı
    required String updatedValue, // Güncellenecek yeni değer
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Tek bir alanı güncelleriz
        Map<String, dynamic> updatedData = {
          fieldName: updatedValue, // Dinamik olarak fieldName'i güncelliyoruz
        };

        // Firestore'da ilgili alanı güncelle
        await _firestore.collection('users').doc(user.uid).update(updatedData);

        // Local state'i güncelleme
        switch (fieldName) {
          case 'name':
            state = state.copyWith(name: updatedValue);
            break;
          case 'email':
            state = state.copyWith(email: updatedValue);
            break;
          case 'phoneNumber':
            state = state.copyWith(phoneNumber: updatedValue);
            break;
          case 'businessName':
            state = state.copyWith(businessName: updatedValue);
            break;
          case 'businessAddress':
            state = state.copyWith(businessAddress: updatedValue);
            break;
          case 'businessInfo':
            state = state.copyWith(businessInfo: updatedValue);
            break;
          default:
            break;
        }
      }
    } catch (e) {
      state =
          state.copyWith(errorMessage: 'Profil güncellenirken hata oluştu: $e');
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
        final String fileName = 'profile_pictures/${currentUser.uid}.jpg';

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

  // Profil resmi URL'sini Firestore'da günceller
  Future<void> updateProfilePhotoURL(String photoURL, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'photoURL': photoURL,
      });
      // Local state'i güncelle
      state = state.copyWith(photoURL: photoURL);
    } catch (e) {
      print('Profil fotoğrafı güncellenirken hata oluştu: $e');
    }
  }

  /// Hata yönetimi
  void _handleError(Object e, String message) {
    print(
        '$message: $e'); // Hataları loglayın veya bir hata yönetimi mekanizması kullanın
  }

  // Reset profile state
  void resetProfile() {
    state = const ProfileState();
  }
}

// State class to hold profile data
class ProfileState {
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? businessName;
  final String? businessAddress;
  final String? businessInfo;
  final String? errorMessage;
  final String? photoURL;
  final bool isUploading;

  const ProfileState({
    this.name,
    this.email,
    this.phoneNumber,
    this.businessName,
    this.businessAddress,
    this.businessInfo,
    this.errorMessage,
    this.photoURL,
    this.isUploading = false,
  });

  ProfileState copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? businessName,
    String? businessAddress,
    String? businessInfo,
    String? errorMessage,
    String? photoURL,
    bool? isUploading,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      businessInfo: businessInfo ?? this.businessInfo,
      errorMessage: errorMessage ?? this.errorMessage,
      photoURL: photoURL ?? this.photoURL,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}
