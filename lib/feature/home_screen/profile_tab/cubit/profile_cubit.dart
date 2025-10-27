import 'dart:io';
import 'package:admin_food2go/core/services/end_point.dart';
import 'package:admin_food2go/feature/home_screen/profile_tab/cubit/profile_state.dart';
import 'package:admin_food2go/feature/home_screen/profile_tab/model/profile_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/dio_helper.dart';
import '../../../../core/utils/error_handler.dart';
import 'package:admin_food2go/core/services/role_manager.dart';
import 'package:admin_food2go/core/services/cache_helper.dart.dart';
import 'package:admin_food2go/feature/auth/model/user_login.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  ProfileModel? profileModel;

  // جلب بيانات البروفايل
  Future<void> getProfile() async {
    emit(ProfileLoading());

    try {
      // Try API call first
      final response = await DioHelper.getData(
        url: EndPoint.profile, // Use common endpoint
      );

      print('📦 Response Status: ${response.statusCode}');
      print('📦 Response Data: ${response.data}');
      print('📦 Response Data Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        // تحقق من بنية الـ response
        if (response.data is Map<String, dynamic>) {
          // إذا كانت البيانات داخل key اسمه 'data'
          if (response.data.containsKey('data')) {
            profileModel = ProfileModel.fromJson(response.data['data']);
          }
          // إذا كانت البيانات مباشرة بدون key
          else {
            profileModel = ProfileModel.fromJson(response.data);
          }
        } else {
          profileModel = ProfileModel.fromJson(response.data);
        }

        print('✅ Profile loaded successfully: ${profileModel?.name}');
        emit(ProfileSuccess());
        return; // Success, no fallback
      } else {
        print('⚠️ API failed, trying fallback to cached data');
        // Fallback to cached data
        await _loadFromCache();
        if (profileModel != null) {
          emit(ProfileSuccess());
        } else {
          emit(ProfileError(message: 'Failed to load profile data'));
        }
        return;
      }
    } on DioException catch (e) {
      print('⚠️ DioException, trying fallback to cached data');
      // Fallback to cached data on any Dio error
      await _loadFromCache();
      if (profileModel != null) {
        emit(ProfileSuccess());
      } else {
        final errorMessage = ErrorHandler.handleError(e);
        emit(ProfileError(message: errorMessage));
      }
    } catch (error) {
      print('❌ Error in getProfile: $error, trying fallback');
      // Fallback to cached data
      await _loadFromCache();
      if (profileModel != null) {
        emit(ProfileSuccess());
      } else {
        final errorMessage = ErrorHandler.handleError(error);
        emit(ProfileError(message: errorMessage));
      }
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final cachedAdmin = await CacheHelper.getModel<Admin>(
        key: 'admin',
        fromJson: (json) => Admin.fromJson(json),
      );

      if (cachedAdmin != null) {
        // Create ProfileModel from cached Admin data
        profileModel = ProfileModel(
          name: cachedAdmin.name,
          email: cachedAdmin.email,
          phone: cachedAdmin.phone,
          image: cachedAdmin.image,
          // Add other fields as needed, mapping from Admin
        );
        print('✅ Loaded profile from cache: ${profileModel?.name}');
      }
    } catch (e) {
      print('❌ Failed to load from cache: $e');
    }
  }

  // تحديث بيانات البروفايل
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? password,
    File? imageFile,
  }) async {
    emit(ProfileLoading());

    try {
      FormData formData = FormData();

      // إضافة البيانات النصية
      if (name != null && name.isNotEmpty) {
        formData.fields.add(MapEntry('name', name));
      }
      if (email != null && email.isNotEmpty) {
        formData.fields.add(MapEntry('email', email));
      }
      if (phone != null && phone.isNotEmpty) {
        formData.fields.add(MapEntry('phone', phone));
      }
      if (password != null && password.isNotEmpty) {
        formData.fields.add(MapEntry('password', password));
      }

      // إضافة الصورة إن وجدت
      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
            ),
          ),
        );
      }

      print('📤 Updating profile with data: ${formData.fields}');

      final response = await DioHelper.postData(
        url: EndPoint.UpdateProfile,
        data: formData,
      );

      print('📦 Update Response Status: ${response.statusCode}');
      print('📦 Update Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // تحديث البيانات المحلية
        await getProfile();
      } else {
        emit(ProfileError(message: 'Failed to update profile'));
      }
    } catch (error) {
      print('❌ Error in updateProfile: $error');
      final errorMessage = ErrorHandler.handleError(error);
      emit(ProfileError(message: errorMessage));
    }
  }

  // تحديث بيانات محددة فقط
  Future<void> updateProfileData(Map<String, dynamic> data) async {
    emit(ProfileLoading());

    try {
      FormData formData = FormData.fromMap(data);

      final response = await DioHelper.postData(
        url: EndPoint.UpdateProfile,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await getProfile();
        emit(ProfileSuccess());
      } else {
        emit(ProfileError(message: 'Failed to update profile'));
      }
    } catch (error) {
      print('❌ Error in updateProfileData: $error');
      final errorMessage = ErrorHandler.handleError(error);
      emit(ProfileError(message: errorMessage));
    }
  }
}