import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/study_group_service.dart';

final studyGroupServiceProvider =
    Provider<StudyGroupService>((ref) => StudyGroupService());

final studyGroupsProvider = FutureProvider<List<StudyGroup>>(
  (ref) async {
    final service = ref.watch(studyGroupServiceProvider);
    return service.fetchGroups();
  },
  dependencies: [studyGroupServiceProvider],
);
