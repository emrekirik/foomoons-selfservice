import 'package:altmisdokuzapp/featured/profile/profile_info_showdialog.dart';
import 'package:altmisdokuzapp/featured/providers/loading_notifier.dart';
import 'package:altmisdokuzapp/featured/providers/profile_notifier.dart';
import 'package:altmisdokuzapp/product/constants/color_constants.dart';
import 'package:altmisdokuzapp/product/widget/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final _profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref);
});

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  final TextEditingController profileImageController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(_profileProvider.notifier).fetchAndLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    final profileState = ref.watch(_profileProvider);
    final profileNotifier = ref.read(_profileProvider.notifier);

    final List<IconData> icons = [
      Icons.person,
      Icons.lock,
      Icons.check_circle,
      Icons.phone,
      Icons.email,
      Icons.settings,
      Icons.star,
      Icons.face,
    ];

    return Column(
      children: [
        if (isLoading)
          const LinearProgressIndicator(
            color: Colors.green,
          ),
        Expanded(
          child: Scaffold(
            appBar: const PreferredSize(
              preferredSize: Size.fromHeight(70.0),
              child: CustomAppbar(
                showDrawer: false,
                showBackButton: true,
              ),
            ),
            backgroundColor:
                ColorConstants.appbackgroundColor.withOpacity(0.15),
            body: Center(
              child: AspectRatio(
                aspectRatio: 22 / 20,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.white,
                        ColorConstants.white,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    color: ColorConstants.loginCardBackgroundColorr,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: !isLoading
                      ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const SizedBox(height: 100),
                                  _ProfilePhotoSection(
                                      profileNotifier: profileNotifier,
                                      profileState: profileState,
                                      deviceWidth: deviceWidth),
                                  Divider(
                                    indent: deviceWidth * 0.04,
                                    endIndent: deviceWidth * 0.04,
                                  ),
                                  _PermissionsSection(
                                      deviceWidth: deviceWidth,
                                      deviceHeight: deviceHeight,
                                      icons: icons),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: deviceWidth * 0.035,
                                  // vertical: deviceWidth * 0.02,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 100,),
                                      _UserDataSection(
                                          deviceHeight: deviceHeight,
                                          profileState: profileState,
                                          profileNotifier: profileNotifier),
                                      _BusinessDataSection(
                                          deviceHeight: deviceHeight,
                                          deviceWidth: deviceWidth,
                                          profileState: profileState,
                                          profileNotifier: profileNotifier),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BusinessDataSection extends StatelessWidget {
  const _BusinessDataSection(
      {required this.deviceHeight,
      required this.deviceWidth,
      required this.profileState,
      required this.profileNotifier,
      required});

  final double deviceHeight;
  final double deviceWidth;
  final ProfileState profileState;
  final ProfileNotifier profileNotifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CustomTitle(
          deviceHeight: deviceHeight,
          title: 'İşletme Bilgileri',
        ),
        // SizedBox(height: deviceHeight * 0.02),
        // GestureDetector(
        //   onTap: () {
        //     profileNotifier.pickAndUploadImage();
        //   },
        //   child: Stack(
        //     alignment: Alignment.center,
        //     children: [
        //       ClipRRect(
        //         borderRadius: BorderRadius.circular(8),
        //         child: profileState.photoURL != null
        //             ? Image.network(profileState.photoURL!)
        //             : Image.asset(
        //                 'assets/images/personal_placeholder.png'), // Eğer URL varsa, NetworkImage kullanıyoruz
        //       ),
        //       if (profileState.isUploading)
        //         const CircularProgressIndicator(
        //           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        //         ),
        //     ],
        //   ),
        // ),
        SizedBox(height: deviceHeight * 0.02),
        _CustomText(
            title: 'İşletme Adı: ',
            desc: profileState.businessName ?? '',
            onPressed: () => ProfileInfoShowDialog(
                  initialValue: profileState.businessName ?? '',
                  context,
                  onSave: (updatedValue) {
                    profileNotifier.updateProfileInfo(
                        fieldName: 'businessName', updatedValue: updatedValue);
                  },
                )),
        SizedBox(height: deviceHeight * 0.02),
        _CustomText(
            title: 'İşletme Adresi: ',
            desc: profileState.businessAddress ?? '',
            onPressed: () => ProfileInfoShowDialog(
                  initialValue: profileState.businessAddress ?? '',
                  context,
                  onSave: (updatedValue) {
                    profileNotifier.updateProfileInfo(
                        fieldName: 'businessAddress',
                        updatedValue: updatedValue);
                  },
                )),
        SizedBox(height: deviceHeight * 0.02),
        _CustomTextVertical(
            title: 'İşletme Hakkında: ',
            desc: profileState.businessInfo ?? '',
            onPressed: () => ProfileInfoShowDialog(
                  initialValue: profileState.businessInfo ?? '',
                  context,
                  onSave: (updatedValue) {
                    profileNotifier.updateProfileInfo(
                        fieldName: 'businessInfo', updatedValue: updatedValue);
                  },
                ))
      ],
    );
  }
}

class _UserDataSection extends ConsumerWidget {
  const _UserDataSection({
    required this.deviceHeight,
    required this.profileState,
    required this.profileNotifier,
  });

  final double deviceHeight;
  final ProfileState profileState;
  final ProfileNotifier profileNotifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _CustomTitle(
          deviceHeight: deviceHeight,
          title: 'ÜNVAN',
        ),
        SizedBox(height: deviceHeight * 0.02),
        _CustomText(
          title: 'İsim: ',
          desc: profileState.name ??
              'Bilinmiyor', // Eğer `name` null ise varsayılan bir değer göster
          onPressed: () => ProfileInfoShowDialog(
            context,
            initialValue: profileState.name ?? 'Bilinmiyor',
            onSave: (updatedValue) {
              ref.read(_profileProvider.notifier).updateProfileInfo(
                    fieldName: 'name',
                    updatedValue: updatedValue,
                  );
            },
          ),
        ),
        SizedBox(height: deviceHeight * 0.01),
        _CustomText(
            title: 'Telefon: ',
            desc: profileState.phoneNumber ?? '',
            onPressed: () => ProfileInfoShowDialog(
                  initialValue: profileState.phoneNumber ?? '',
                  context,
                  onSave: (updatedValue) {
                    profileNotifier.updateProfileInfo(
                        fieldName: 'phoneNumber', updatedValue: updatedValue);
                  },
                )),
        SizedBox(height: deviceHeight * 0.01),
        _CustomText(
          title: 'Email: ',
          desc: profileState.email ?? 'bilinmiyor',
        ),
         SizedBox(height: deviceHeight * 0.02),
      ],
    );
  }
}

class _PermissionsSection extends StatelessWidget {
  const _PermissionsSection({
    required this.deviceWidth,
    required this.deviceHeight,
    required this.icons,
  });

  final double deviceWidth;
  final double deviceHeight;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: deviceWidth * 0.035, vertical: deviceHeight * 0.02),
        child: Column(
          children: [
            _CustomTitle(
              deviceHeight: deviceHeight,
              title: 'YETKİLER',
            ),
            SizedBox(height: deviceHeight * 0.05),
            Expanded(
              child: GridView.builder(
                physics:
                    const NeverScrollableScrollPhysics(), // Bu, kaydırmayı devre dışı bırakır
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                ),
                itemCount: icons.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Icon(
                      icons[index],
                      size: 30, // Boyutu 10'dan 30'a çıkarıldı
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePhotoSection extends StatelessWidget {
  const _ProfilePhotoSection({
    required this.deviceWidth,
    required this.profileNotifier,
    required this.profileState,
  });
  final ProfileNotifier profileNotifier;
  final ProfileState profileState;
  final double deviceWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: GestureDetector(
        onTap: () {
          profileNotifier.pickAndUploadImage();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: profileState.photoURL != null
                  ? Image.network(profileState.photoURL!)
                  : Image.asset(
                      'assets/images/personal_placeholder.png'), // Eğer URL varsa, NetworkImage kullanıyoruz
            ),
            if (profileState.isUploading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomText extends StatelessWidget {
  final String title;
  final String desc;
  final VoidCallback? onPressed;
  const _CustomText({
    required this.title,
    required this.desc,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.ubuntu(
              textStyle: const TextStyle(fontSize: 20),
              fontWeight: FontWeight.bold),
        ),
        Flexible(
          child: Text(
            desc.length > 50 ? '${desc.substring(0, 50)}...' : desc,
            style: GoogleFonts.ubuntu(textStyle: TextStyle(fontSize: 20)),
          ),
        ),
        onPressed != null
            ? IconButton(onPressed: onPressed, icon: const Icon(Icons.info))
            : const SizedBox()
      ],
    );
  }
}

class _CustomTextVertical extends StatelessWidget {
  final String title;
  final String desc;
  final VoidCallback? onPressed;
  const _CustomTextVertical({
    required this.title,
    required this.desc,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.ubuntu(
                  textStyle: const TextStyle(fontSize: 20),
                  fontWeight: FontWeight.bold),
            ),
            onPressed != null
                ? IconButton(onPressed: onPressed, icon: const Icon(Icons.info))
                : const SizedBox()
          ],
        ),
        Flexible(
          child: Text(
            desc.length > 50 ? '${desc.substring(0, 50)}...' : desc,
            style: GoogleFonts.ubuntu(textStyle: const TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }
}

class _CustomTitle extends StatelessWidget {
  final String title;
  final double deviceHeight;

  const _CustomTitle({
    required this.title,
    required this.deviceHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: deviceHeight * 0.05,
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              ColorConstants.titleContainerColor,
              ColorConstants.titleContainerColorSecond,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(30)),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.ubuntu(
              textStyle: const TextStyle(color: Colors.white),
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
