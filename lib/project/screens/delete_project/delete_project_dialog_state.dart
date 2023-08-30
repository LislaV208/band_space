import 'package:band_space/project/model/project_model.dart';
import 'package:band_space/project/repository/project_repository.dart';
import 'package:flutter/material.dart';

class DeleteProjectDialogState with ChangeNotifier {
  DeleteProjectDialogState(this._projectRepository);

  final ProjectRepository _projectRepository;

  bool _deleteInProgress = false;

  bool get deleteInProgress => _deleteInProgress;

  Future<bool> deleteProject(ProjectModel project) async {
    _deleteInProgress = true;
    notifyListeners();

    var isFail = false;

    try {
      await _projectRepository.deleteProject(project);
    } on Exception catch (_) {
      isFail = true;
    }

    _deleteInProgress = false;
    notifyListeners();

    return !isFail;
  }
}
