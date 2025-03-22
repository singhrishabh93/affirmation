import 'package:affirmation/services/authentication_service.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:affirmation/screens/Auth/signIn_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    setState(() {
      userData = user;
      isLoading = false;
    });
  }

  Future<void> _signOut() async {
    setState(() {
      isLoading = true;
    });

    await AuthService.signOut();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: SafeArea(
        child: isLoading
            ? Center(child: Lottie.asset('assets/loader.json', height: 50),)
            : Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Close button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 30, 0, 0),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Close',
                            style: GoogleFonts.merriweather(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Profile heading
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        child: Text(
                          'Profile',
                          style: GoogleFonts.merriweather(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Profile picture and name
                      Center(
                        child: Column(
                          children: [
                            userData != null && userData!['photoURL'] != null
                                ? Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: userData!['photoURL'],
                                        placeholder: (context, url) =>
                                            Center(
                                          child: Lottie.asset('assets/loader.json', height: 50),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.black54,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFD5EAE4),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 16),
                            Text(
                              userData?['displayName'] ?? 'User',
                              style: GoogleFonts.merriweather(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userData?['email'] ?? '',
                              style: GoogleFonts.merriweather(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Sign out button
                      Center(
                        child: GestureDetector(
                          onTap: _signOut,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                'Sign Out',
                                style: GoogleFonts.merriweather(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // App version
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Version 1.0.0',
                            style: GoogleFonts.merriweather(
                              fontSize: 14,
                              color: Colors.black38,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Notification icon at top right corner
                  Positioned(
                    top: 55,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(FeatherIcons.bell),
                        color: Colors.black87,
                        onPressed: () {
                          // Replace this with:
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            isDismissible: true,
                            builder: (context) => const ProfileScreen(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
