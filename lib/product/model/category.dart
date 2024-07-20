import 'package:altmisdokuzapp/product/utility/base/base_firebase_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class Category with EquatableMixin, BaseFirebaseModel<Category>, IdModel {
  @override
  final String? id;
  final String? name;

  const Category({
    this.id,
    this.name,
  });

  @override
  List<Object?> get props => [id, name];

  Category copyWith({
    String? name,
  }) {
    return Category(
      name: name ?? this.name,
      id: id,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  Category fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );
  }
}
