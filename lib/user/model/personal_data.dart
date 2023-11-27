import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:equatable/equatable.dart';

class PersonalData extends Equatable {
  final String name;
  final String surname;

  const PersonalData({required this.name, required this.surname});

  String get fullName => '$name $surname';
  String get displayName => '$name ${surname.characters.first}.';

  @override
  List<Object?> get props => [name, surname];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
    };
  }

  factory PersonalData.fromMap(Map<String, dynamic> map) {
    return PersonalData(
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PersonalData.fromJson(String source) => PersonalData.fromMap(json.decode(source));
}
