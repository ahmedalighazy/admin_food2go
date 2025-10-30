import 'dart:io';
import 'package:admin_food2go/core/utils/responsive_ui.dart';
import 'package:admin_food2go/feature/home_screen/profile_tab/cubit/profile_cubit.dart';
import 'package:admin_food2go/feature/home_screen/profile_tab/cubit/profile_state.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../auth/cubit/login_cubit.dart';
import '../../../auth/view/login_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _selectedImage;
  bool _isEditing = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().getProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showAwesomeSnackBar({
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    final materialBanner = MaterialBanner(
      elevation: 0,
      backgroundColor: Colors.transparent,
      forceActionsBelow: true,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
        inMaterialBanner: true,
      ),
      actions: const [SizedBox.shrink()],
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(materialBanner);

    Future.delayed(const Duration(seconds: 3), () {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      if (mounted) {
        _showAwesomeSnackBar(
          title: 'Oops!',
          message: 'Failed to pick image. Please check permissions.',
          contentType: ContentType.failure,
        );
      }
    }
  }

  void _loadProfileData() {
    final profile = context.read<ProfileCubit>().profileModel;
    if (profile != null) {
      _nameController.text = profile.name ?? '';
      _emailController.text = profile.email ?? '';
      _phoneController.text = profile.phone ?? '';
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      await context.read<ProfileCubit>().updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        imageFile: _selectedImage,
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        ),
        title: Text(
          'Log Out',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUI.fontSize(context, 20),
          ),
        ),
        content: Text(
          'Are you sure you want to log out? You will need to sign in again.',
          style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 16)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child:  Text(
              'Log Out',
              style: TextStyle(color:AppColors.colorPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Call logout from LoginCubit
      await context.read<LoginCubit>().logout();

      // Navigate to login screen and clear the navigation stack
      Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routeName,
            (route) => false,
      );

      _showAwesomeSnackBar(
        title: 'Logged Out',
        message: 'You have been logged out successfully.',
        contentType: ContentType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSuccess && _isEditing) {
          _showAwesomeSnackBar(
            title: 'Success!',
            message: 'Your profile has been updated successfully',
            contentType: ContentType.success,
          );

          setState(() {
            _isEditing = false;
            _selectedImage = null;
          });

          _loadProfileData();
        } else if (state is ProfileError) {
          _showAwesomeSnackBar(
            title: 'Error!',
            message: state.message,
            contentType: ContentType.failure,
          );
        } else if (state is ProfileSuccess && !_isEditing) {
          _loadProfileData();
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading && !_isEditing) {
          return ProfileShimmer();
        }

        final profile = context.read<ProfileCubit>().profileModel;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: ResponsiveUI.spacing(context, 10)),

                  // Profile Header Card with Modern Design
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.colorPrimary,
                          AppColors.colorPrimaryDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.colorPrimary.withOpacity(0.4),
                          blurRadius: ResponsiveUI.value(context, 24),
                          offset: Offset(0, ResponsiveUI.value(context, 12)),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative circles
                        Positioned(
                          top: ResponsiveUI.value(context, -50),
                          right: ResponsiveUI.value(context, -50),
                          child: Container(
                            width: ResponsiveUI.value(context, 150),
                            height: ResponsiveUI.value(context, 150),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: ResponsiveUI.value(context, -30),
                          left: ResponsiveUI.value(context, -30),
                          child: Container(
                            width: ResponsiveUI.value(context, 100),
                            height: ResponsiveUI.value(context, 100),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: EdgeInsets.all(ResponsiveUI.padding(context, 28)),
                          child: Column(
                            children: [
                              // Profile Image with enhanced design
                              Stack(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(ResponsiveUI.value(context, 6)),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Colors.white.withOpacity(0.8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: ResponsiveUI.value(context, 20),
                                          offset: Offset(0, ResponsiveUI.value(context, 8)),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: ResponsiveUI.value(context, 3),
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: ResponsiveUI.value(context, 65),
                                        backgroundColor: Colors.grey.shade100,
                                        backgroundImage: _selectedImage != null
                                            ? FileImage(_selectedImage!)
                                            : (profile?.image != null &&
                                            profile!.image!.isNotEmpty
                                            ? NetworkImage(profile.image!)
                                            : null) as ImageProvider?,
                                        child: (_selectedImage == null &&
                                            (profile?.image == null ||
                                                profile!.image!.isEmpty))
                                            ? Icon(
                                          Icons.person_rounded,
                                          size: ResponsiveUI.value(
                                              context, 65),
                                          color: AppColors.colorPrimary
                                              .withOpacity(0.5),
                                        )
                                            : null,
                                      ),
                                    ),
                                  ),
                                  if (_isEditing)
                                    Positioned(
                                      bottom: ResponsiveUI.value(context, 5),
                                      right: ResponsiveUI.value(context, 5),
                                      child: GestureDetector(
                                        onTap: _pickImage,
                                        child: Container(
                                          padding: EdgeInsets.all(
                                            ResponsiveUI.padding(context, 10),
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.colorPrimary,
                                                AppColors.colorPrimaryDark,
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                blurRadius: ResponsiveUI.value(context, 12),
                                                offset: Offset(0, ResponsiveUI.value(context, 4)),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.camera_alt_rounded,
                                            size:
                                            ResponsiveUI.value(context, 20),
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              SizedBox(height: ResponsiveUI.spacing(context, 20)),

                              // Name
                              Text(
                                profile?.name ?? 'Admin User',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 26),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: ResponsiveUI.value(context, 8),
                                      offset: Offset(0, ResponsiveUI.value(context, 2)),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: ResponsiveUI.spacing(context, 8)),

                              // Email with icon
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email_rounded,
                                    size: ResponsiveUI.value(context, 16),
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  SizedBox(width: ResponsiveUI.spacing(context, 8)),
                                  Flexible(
                                    child: Text(
                                      profile?.email ?? 'email@example.com',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize:
                                        ResponsiveUI.fontSize(context, 15),
                                        color: Colors.white.withOpacity(0.95),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (profile?.phone != null &&
                                  profile!.phone!.isNotEmpty) ...[
                                SizedBox(height: ResponsiveUI.spacing(context, 6)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone_rounded,
                                      size: ResponsiveUI.value(context, 16),
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    SizedBox(
                                        width: ResponsiveUI.spacing(context, 8)),
                                    Text(
                                      profile.phone!,
                                      style: TextStyle(
                                        fontSize:
                                        ResponsiveUI.fontSize(context, 15),
                                        color: Colors.white.withOpacity(0.95),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 28)),

                  // Profile Information Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: ResponsiveUI.value(context, 20),
                          offset: Offset(0, ResponsiveUI.value(context, 8)),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with Edit Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(
                                    ResponsiveUI.padding(context, 8),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.colorPrimaryLight,
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveUI.borderRadius(context, 10),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: AppColors.colorPrimary,
                                    size: ResponsiveUI.value(context, 20),
                                  ),
                                ),
                                SizedBox(
                                    width: ResponsiveUI.spacing(context, 12)),
                                Text(
                                  'Profile Information',
                                  style: TextStyle(
                                    fontSize:
                                    ResponsiveUI.fontSize(context, 20),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: _isEditing
                                    ? Colors.red.shade50
                                    : AppColors.colorPrimaryLight,
                                borderRadius: BorderRadius.circular(
                                  ResponsiveUI.borderRadius(context, 12),
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = !_isEditing;
                                    if (_isEditing) {
                                      _loadProfileData();
                                    } else {
                                      _selectedImage = null;
                                    }
                                  });
                                },
                                icon: Icon(
                                  _isEditing
                                      ? Icons.close_rounded
                                      : Icons.edit_rounded,
                                  color: _isEditing
                                      ? Colors.red.shade700
                                      : AppColors.colorPrimary,
                                  size: ResponsiveUI.value(context, 22),
                                ),
                                tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: ResponsiveUI.spacing(context, 24)),

                        // Name Field
                        _buildModernTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person_outline_rounded,
                          enabled: _isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            if (value.length < 3) {
                              return 'Name must be at least 3 characters';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: ResponsiveUI.spacing(context, 18)),

                        // Email Field
                        _buildModernTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          icon: Icons.email_outlined,
                          enabled: _isEditing,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: ResponsiveUI.spacing(context, 18)),

                        // Phone Field
                        _buildModernTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          enabled: _isEditing,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (value.length < 10) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),

                        if (_isEditing) ...[
                          SizedBox(height: ResponsiveUI.spacing(context, 18)),


                          // Update Button
                          Container(
                            width: double.infinity,
                            height: ResponsiveUI.value(context, 54),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.colorPrimary,
                                  AppColors.colorPrimaryDark,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                ResponsiveUI.borderRadius(context, 14),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  AppColors.colorPrimary.withOpacity(0.4),
                                  blurRadius: ResponsiveUI.value(context, 16),
                                  offset: Offset(0, ResponsiveUI.value(context, 8)),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed:
                              state is ProfileLoading ? null : _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveUI.borderRadius(context, 14),
                                  ),
                                ),
                              ),
                              child: state is ProfileLoading
                                  ? SizedBox(
                                height: ResponsiveUI.value(context, 24),
                                width: ResponsiveUI.value(context, 24),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: ResponsiveUI.value(context, 2.5),
                                ),
                              )
                                  : Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: ResponsiveUI.value(context, 22),
                                  ),
                                  SizedBox(
                                      width:
                                      ResponsiveUI.spacing(context, 10)),
                                  Text(
                                    'Update Profile',
                                    style: TextStyle(
                                      fontSize:
                                      ResponsiveUI.fontSize(context, 17),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 40)),

                  // Logout Button
                  Container(
                    width: double.infinity,
                    height: ResponsiveUI.value(context, 54),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.colorPrimary,
                          AppColors.colorPrimary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 14),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: ResponsiveUI.value(context, 16),
                          offset: Offset(0, ResponsiveUI.value(context, 8)),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUI.borderRadius(context, 14),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                            size: ResponsiveUI.value(context, 22),
                          ),
                          SizedBox(width: ResponsiveUI.spacing(context, 10)),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: ResponsiveUI.fontSize(context, 17),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 20)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        fontSize: ResponsiveUI.fontSize(context, 16),
        color: enabled ? Colors.black87 : Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled ? AppColors.colorPrimary : Colors.grey.shade500,
          fontSize: ResponsiveUI.fontSize(context, 14),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Container(
          margin: EdgeInsets.only(right: ResponsiveUI.spacing(context, 12)),
          child: Icon(
            icon,
            color: enabled ? AppColors.colorPrimary : Colors.grey.shade400,
            size: ResponsiveUI.value(context, 22),
          ),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled
            ? AppColors.colorPrimaryLight.withOpacity(0.3)
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 14),
          ),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 14),
          ),
          borderSide: BorderSide(
            color: AppColors.colorPrimaryLight.withOpacity(0.5),
            width: ResponsiveUI.value(context, 1.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 14),
          ),
          borderSide: BorderSide(
            color: AppColors.colorPrimary,
            width: ResponsiveUI.value(context, 2),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 14),
          ),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: ResponsiveUI.value(context, 1.5),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 14),
          ),
          borderSide: BorderSide(
            color: Colors.red,
            width: ResponsiveUI.value(context, 2),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 16),
          vertical: ResponsiveUI.padding(context, 18),
        ),
      ),
    );
  }
}

// Shimmer Widget for Loading
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return OverviewShimmer();
  }
}