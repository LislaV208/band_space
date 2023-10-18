import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

class LoopSection extends Equatable implements Comparable<LoopSection> {
  final int start;
  final int end;

  const LoopSection({
    required this.start,
    required this.end,
  });

  @override
  List<Object?> get props => [start, end];

  @override
  int compareTo(other) => start - other.start;
}

class LoopSectionsManager {
  final _loopSections = <LoopSection>[];
  var _joinedLoopSections = <LoopSection>[];

  final _loopSectionsController = BehaviorSubject<List<LoopSection>>();

  List<LoopSection> get sections => _loopSections;
  List<LoopSection> get joinedSections => _joinedLoopSections;

  Stream<List<LoopSection>> get loopSectionsStream => _loopSectionsController.stream;

  void addSection(LoopSection section) {
    _loopSections.add(section);
    _loopSectionsController.add(_loopSections);

    _updateJoinedLoopSections();
  }

  void updateLoopSection(LoopSection current, LoopSection updated) {
    final index = _loopSections.indexOf(current);

    if (index >= 0) {
      _loopSections[index] = updated;
      _loopSectionsController.add(_loopSections);

      _updateJoinedLoopSections();
    }
  }

  void removeSection(LoopSection section) {
    final isRemoved = _loopSections.remove(section);
    if (isRemoved) {
      _loopSectionsController.add(_loopSections);

      _updateJoinedLoopSections();
    }
  }

  Future<void> dispose() async {
    _loopSections.clear();
    _joinedLoopSections.clear();

    await _loopSectionsController.close();
  }

  void _updateJoinedLoopSections() {
    final joinedSections = <LoopSection>[];

    int? tempStart;
    int? tempEnd;

    _loopSections.sort();

    final sectionsCount = _loopSections.length;
    if (sectionsCount == 1) {
      joinedSections.add(_loopSections.first);
    } else {
      for (var i = 0; i < _loopSections.length - 1; ++i) // -1 bo pomijamy ostatni element
      {
        final currentSection = _loopSections[i];
        final nextSection = _loopSections[i + 1];

        if (currentSection.end == nextSection.start) {
          // jesteśmy w trakcie łączenia

          tempStart ??= currentSection.start;
          tempEnd = nextSection.end;
        } else {
          if (tempStart != null && tempEnd != null) {
            // kończymy łączenie
            joinedSections.add(LoopSection(start: tempStart, end: tempEnd));

            tempStart = null;
            tempEnd = null;
          } else {
            joinedSections.add(currentSection);
          }
          if (tempStart == null && tempEnd == null) {
            // jezeli ostatnia sekcja jest ostatnią, to dodajemy równiez ją
            if (i + 1 == _loopSections.length - 1) {
              joinedSections.add(nextSection);
            }
          }
        }
      }
    }

    if (tempStart != null && tempEnd != null) {
      joinedSections.add(LoopSection(start: tempStart, end: tempEnd));
    }

    _joinedLoopSections = joinedSections;
  }
}
