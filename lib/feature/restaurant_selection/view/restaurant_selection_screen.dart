import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../cubit/restaurant_cubit.dart';
import '../cubit/restaurant_state.dart';
import '../../auth/view/login_screen.dart';
import '../../../../core/utils/responsive_ui.dart';

class RestaurantSelectionScreen extends StatefulWidget {
  static const routeName = '/restaurant-selection';

  const RestaurantSelectionScreen({super.key});

  @override
  State<RestaurantSelectionScreen> createState() => _RestaurantSelectionScreenState();
}

class _RestaurantSelectionScreenState extends State<RestaurantSelectionScreen> {
  late TextEditingController restaurantIdController;

  @override
  void initState() {
    super.initState();
    restaurantIdController = TextEditingController();
  }

  @override
  void dispose() {
    restaurantIdController.dispose();
    super.dispose();
  }

  void showAwesomeSnackbar({
    required BuildContext context,
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(158, 9, 15, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 24.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: ResponsiveUI.screenHeight(context) * 0.08),

                // Logo and Title
                Container(
                  width: ResponsiveUI.value(context, 100),
                  height: ResponsiveUI.value(context, 100),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromRGBO(158, 9, 15, 1),
                        const Color.fromRGBO(120, 7, 11, 1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: ResponsiveUI.value(context, 20),
                        offset: Offset(0, ResponsiveUI.value(context, 10)),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 32)),
                Text(
                  'Food2Go Admin',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 34),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                Text(
                  'Select your restaurant',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 16),
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: ResponsiveUI.screenHeight(context) * 0.06),

                // Restaurant ID Card
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveUI.contentMaxWidth(context),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 28)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: ResponsiveUI.value(context, 30),
                          offset: Offset(0, ResponsiveUI.value(context, 10)),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 32)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Restaurant ID Field
                        Text(
                          'Restaurant ID',
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 14),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 10)),
                        TextField(
                          controller: restaurantIdController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter restaurant ID ',
                            prefixIcon: Icon(
                              Icons.store_rounded,
                              color: const Color.fromRGBO(158, 9, 15, 1),
                              size: ResponsiveUI.iconSize(context, 22),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 14)),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 14)),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 14)),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(158, 9, 15, 1),
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: ResponsiveUI.padding(context, 16),
                              horizontal: ResponsiveUI.padding(context, 16),
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 24)),

                        // Continue Button
                        BlocConsumer<RestaurantCubit, RestaurantState>(
                          listener: (context, state) {
                            if (state is RestaurantSuccess) {
                              showAwesomeSnackbar(
                                context: context,
                                title: 'Success!',
                                message: 'Restaurant configured successfully',
                                contentType: ContentType.success,
                              );
                              Future.delayed(const Duration(seconds: 1), () {
                                Navigator.of(context).pushReplacementNamed(
                                  LoginScreen.routeName,
                                );
                              });
                            } else if (state is RestaurantError) {
                              showAwesomeSnackbar(
                                context: context,
                                title: 'Error!',
                                message: state.message,
                                contentType: ContentType.failure,
                              );
                            }
                          },
                          builder: (context, state) {
                            return SizedBox(
                              width: double.infinity,
                              height: ResponsiveUI.value(context, 56),
                              child: ElevatedButton(
                                onPressed: state is RestaurantLoading
                                    ? null
                                    : () {
                                  if (restaurantIdController.text.isNotEmpty) {
                                    context.read<RestaurantCubit>().setRestaurantId(
                                      restaurantId: restaurantIdController.text,
                                    );
                                  } else {
                                    showAwesomeSnackbar(
                                      context: context,
                                      title: 'Warning!',
                                      message: 'Please enter restaurant ID',
                                      contentType: ContentType.warning,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(158, 9, 15, 1),
                                  disabledBackgroundColor: const Color.fromRGBO(158, 9, 15, 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 14)),
                                  ),
                                  elevation: ResponsiveUI.value(context, 8),
                                ),
                                child: state is RestaurantLoading
                                    ? SizedBox(
                                  width: ResponsiveUI.value(context, 20),
                                  height: ResponsiveUI.value(context, 20),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: ResponsiveUI.value(context, 2.5),
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: ResponsiveUI.fontSize(context, 16),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: ResponsiveUI.spacing(context, 8)),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: ResponsiveUI.iconSize(context, 20),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 24)),

                // Info Card
                Container(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white.withOpacity(0.8),
                        size: ResponsiveUI.iconSize(context, 24),
                      ),
                      SizedBox(width: ResponsiveUI.spacing(context, 12)),
                      Expanded(
                        child: Text(
                          'Enter your restaurant ID to configure the admin panel',
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 13),
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 16)),
                Text(
                  '© 2024 Food2Go. All rights reserved.',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 12),
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}