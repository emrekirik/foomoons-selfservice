import 'package:altmisdokuzapp/product/utility/base/base_firebase_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class Category with EquatableMixin, IdModel {
  final String? name;
  @override
  final String? id;

  Category({this.name, this.id});

  @override
  List<Object?> get props => [name];

  Category copyWith({
    String? name,
  }) {
    return Category(
      name: name ?? this.name,
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
    );
  }
}
