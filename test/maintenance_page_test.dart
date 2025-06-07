import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/models.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:oly_app/pages/maintenance_page.dart';
import 'package:oly_app/services/maintenance_service.dart';

class FakeMaintenanceService extends MaintenanceService {
  FakeMaintenanceService();
  @override
  Future<List<MaintenanceRequest>> fetchRequests() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return [];
  }
}

class ErrorMaintenanceService extends MaintenanceService {
  @override
  Future<List<MaintenanceRequest>> fetchRequests() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    throw Exception('fail');
  }
}

class FakeImagePicker extends ImagePickerPlatform {
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return XFile('picked.png');
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
  testWidgets('Switches between request and conversations tabs', (
    tester,
  ) async {
    final service = FakeMaintenanceService();
    await tester.pumpWidget(
      MaterialApp(home: MaintenancePage(service: service)),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    // Form visible on start
    expect(find.byType(TextField), findsNWidgets(2));

    // Switch to conversations
    await tester.tap(find.text('Conversations'));
    await tester.pumpAndSettle();
    expect(find.text('No conversations yet.'), findsOneWidget);
  });

  testWidgets('Shows snackbar on ticket load error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MaintenancePage(service: ErrorMaintenanceService())),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Failed to load tickets'), findsOneWidget);
  });

  testWidgets('Selecting image updates preview', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    ImagePickerPlatform.instance = FakeImagePicker();
    await tester.pumpWidget(
      MaterialApp(home: MaintenancePage(service: FakeMaintenanceService())),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);

    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    final finder = find.byType(Image);
    expect(finder, findsOneWidget);
    final img = tester.widget<Image>(finder);
    expect((img.image as FileImage).file.path, 'picked.png');
  });
}
