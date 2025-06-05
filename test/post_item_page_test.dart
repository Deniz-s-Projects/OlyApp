import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:oly_app/pages/post_item_page.dart';

class FakeImagePicker extends ImagePickerPlatform {
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return XFile('picked_image.png');
  }

  @override
  Future<LostDataResponse> getLostData() async => LostDataResponse.empty();

  @override
  Future<List<XFile>> getMultiImageWithOptions({
    MultiImagePickerOptions options = const MultiImagePickerOptions(),
  }) async {
    return <XFile>[];
  }

  @override
  Future<List<XFile>> getMedia({required MediaOptions options}) async =>
      <XFile>[];

  @override
  Future<XFile?> getVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    return null;
  }
}

void main() {
  testWidgets('Selecting image updates preview', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    ImagePickerPlatform.instance = FakeImagePicker();

    await tester.pumpWidget(const MaterialApp(home: PostItemPage()));
    expect(find.byType(Image), findsNothing);

    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);
    final imageWidget = tester.widget<Image>(imageFinder);
    expect((imageWidget.image as FileImage).file.path, 'picked_image.png');
  });
}
