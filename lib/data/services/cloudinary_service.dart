import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../../core/constants/app_constants.dart';

class CloudinaryService {
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    AppConstants.cloudinaryCloudName,
    AppConstants.cloudinaryUploadPreset,
    cache: true,
  );

  Future<String> uploadImage(File file, {String folder = ''}) async {
    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        file.path,
        folder: folder,
        resourceType: CloudinaryResourceType.Image,
      ),
    );
    return response.secureUrl;
  }

  Future<List<String>> uploadMultipleImages(
    List<File> files, {
    String folder = '',
  }) async {
    final urls = <String>[];
    for (final file in files) {
      final url = await uploadImage(file, folder: folder);
      urls.add(url);
    }
    return urls;
  }
}
