import '../models/models.dart';
import 'api_service.dart';

class StudyGroupService extends ApiService {
  StudyGroupService({super.client});

  Future<List<StudyGroup>> fetchGroups() async {
    return get('/studygroups', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => StudyGroup.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<StudyGroup> createGroup(StudyGroup group) async {
    return post('/studygroups', group.toJson(), (json) {
      return StudyGroup.fromJson(json['data'] as Map<String, dynamic>);
    });
  }

  Future<StudyGroup> joinGroup(String id) async {
    return post('/studygroups/$id/join', const {}, (json) {
      return StudyGroup.fromJson(json['data'] as Map<String, dynamic>);
    });
  }

  Future<StudyGroup> leaveGroup(String id) async {
    return post('/studygroups/$id/leave', const {}, (json) {
      return StudyGroup.fromJson(json['data'] as Map<String, dynamic>);
    });
  }
}
