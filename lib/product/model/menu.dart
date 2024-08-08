import 'package:altmisdokuzapp/product/utility/base/base_firebase_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class Menu with EquatableMixin, IdModel {
  final String? title;
  final int? price;
  final String? image;
  @override
  final String? id;
  final String? status;
  final int? preparationTime;
  final String? category;

  const Menu({
    this.title,
    this.price,
    this.image,
    this.id,
    this.status = 'yeni',
    this.preparationTime,
    this.category,
  });

  @override
  List<Object?> get props =>
      [title, price, image, id, status, preparationTime, category];

  Menu copyWith({
    String? title,
    int? price,
    String? image,
    String? id,
    String? status,
    int? preparationTime,
    String? category,
  }) {
    return Menu(
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      id: id ?? this.id,
      status: status ?? this.status,
      preparationTime: preparationTime ?? this.preparationTime,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'image': image,
      'id': id,
      'status': status,
      'preparationTime': preparationTime,
      'category': category,
    };
  }

  static Menu fromJson(Map<String, dynamic> json) {
    return Menu(
      title: json['title'] as String?,
      price: _parseToInt(json['price']),
      image: json['image'] as String?,
      id: json['id'] as String?,
      status: json['status'] as String?,
      preparationTime: json['preparationTime'] != null
          ? (json['preparationTime'] as int) * 60
          : null,
      category: json['category'] as String?,
    );
  }

  static int? _parseToInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value);
    } else {
      return null;
    }
  }
}
