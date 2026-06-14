import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suara_mawa/screens/auth/index.dart';
import 'package:suara_mawa/screens/profile/screens/password_change.dart';
import 'package:suara_mawa/screens/profile/screens/update_profile.dart';
import 'package:suara_mawa/utils/app_colors.dart';
import 'package:suara_mawa/utils/user_controller.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';

class ProfileMenuItem {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  ProfileMenuItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  });
}

class ProfileOptions extends ConsumerWidget {
  const ProfileOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menus = [
      ProfileMenuItem(
        title: "Edit Profile",
        icon: Icons.person,
        iconColor: AppColors.primary,
        backgroundColor: const Color(0xFF5171FE),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UpdateProfilePage()),
          );
        },
      ),
      ProfileMenuItem(
        title: "Ubah Password",
        icon: Icons.lock,
        iconColor: AppColors.primary,
        backgroundColor: const Color(0xFF5171FE),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UpdatePasswordPage()),
          );
        },
      ),
      ProfileMenuItem(
        title: "Pengaturan Notifikasi",
        icon: Icons.notifications_active,
        iconColor: AppColors.primary,
        backgroundColor: const Color(0xFF5171FE),
        onTap: () {},
      ),
      ProfileMenuItem(
        title: "Bantuan",
        icon: Icons.question_mark,
        iconColor: const Color(0xFF09A886),
        backgroundColor: const Color(0xFF5CF6CA),
        onTap: () {},
      ),
      ProfileMenuItem(
        title: "Logout",
        icon: Icons.logout,
        iconColor: Colors.red,
        backgroundColor: const Color(0xFFE97067),
        onTap: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    Text('Konfirmasi Logout'),
                  ],
                ),
                content: const Text('Apakah anda yakin untuk logout?'),
                actions: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                        255,
                        255,
                        162,
                        162,
                      ), // Sets the background color
                      foregroundColor: const Color.fromARGB(
                        255,
                        122,
                        61,
                        57,
                      ), // Sets the text/icon color
                    ),
                    onPressed: () =>
                        Navigator.of(context).pop(false), // Returns false
                    child: const Text('Kembali'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                        255,
                        255,
                        0,
                        0,
                      ), // Sets the background color
                      foregroundColor: Colors.white, // Sets the text/icon color
                    ),
                    onPressed: () =>
                        Navigator.of(context).pop(true), // Returns true
                    child: const Text('Logout'),
                  ),
                ],
              );
            },
          );
          if (result != null && result && context.mounted) {
            AuthService().logout(ref);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) =>
                  false, // This false drops all previous routes
            );
          }
        },
      ),
    ];

    return Card(
      elevation: 3,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color.fromARGB(255, 217, 217, 217),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < menus.length; i++) ...[
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: menus[i].backgroundColor,
                child: Icon(menus[i].icon, color: menus[i].iconColor),
              ),
              title: Text(menus[i].title),
              trailing: const Icon(Icons.chevron_right),
              onTap: menus[i].onTap,
            ),
            if (i != menus.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
    //   child: ListView.separated(
    //     padding: const EdgeInsets.symmetric(vertical: 8),
    //     itemCount: menus.length,
    //     separatorBuilder: (_, __) => const Divider(height: 1),
    //     itemBuilder: (context, index) {
    //       final item = menus[index];

    //       return ListTile(
    //         contentPadding: const EdgeInsets.symmetric(
    //           horizontal: 16,
    //           vertical: 8,
    //         ),
    //         leading: CircleAvatar(
    //           backgroundColor: item.backgroundColor,
    //           child: Icon(
    //             item.icon,
    //             color: item.iconColor,
    //           ),
    //         ),
    //         title: Text(item.title),
    //         trailing: const Icon(Icons.chevron_right),
    //         onTap: item.onTap,
    //       );
    //     },
    //   ),
    // );
  }
}

class ProfilePreview extends ConsumerWidget {
  const ProfilePreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(
      userControllerProvider.select((userModel) => userModel.user?.name),
    );
    print("UseModel: ${ref.watch(userControllerProvider).user?.name}");
    final userRole = ref.watch(
      userControllerProvider.select(
        (userModel) => userModel.user?.userRole?.name,
      ),
    );
    final department =
        ref.watch(userControllerProvider.select((userModel) => userModel.penindakDetail?.department));
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 3,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color.fromARGB(255, 217, 217, 217),
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  "${const String.fromEnvironment('SERVER_BASE_URL', defaultValue: '')}/users/${ref.watch(userControllerProvider.select((um) => um.user?.name))}/profile/photo",
                  headers: {
                    'Authorization':
                        "Bearer ${ref.watch(userControllerProvider.select((um) => um.token))}",
                  },
                ),
              ),

              const SizedBox(height: 12),

              Text(name ?? "", style: Theme.of(context).textTheme.titleLarge),

              const SizedBox(height: 8),

              Chip(label: Text("$userRole - $department")),
            ],
          ),
        ),
      ),
    );
  }
}
