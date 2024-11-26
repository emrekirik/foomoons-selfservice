import 'package:foomoons/product/utility/base/base_firebase_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class Category with EquatableMixin, IdModel {
  final String? name;
  @override
  final String? id;

  Category({this.name, this.id});

  @override
  List<Object?> get props => [name, id];

  Category copyWith({
    String? name,
    String? id, // Added the id to the copyWith method
  }) {
    return Category(
      name: name ?? this.name,
      id: id ?? this.id, // Ensure the id is copied as well
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  static Category fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String?,
      id: json['id'] as String?, // Ensure the id is parsed from JSON
    );
  }
}
