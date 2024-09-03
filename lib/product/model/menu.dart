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
  List<Object?> get props => [
        title,
        price,
        image,
        status,
        preparationTime,
        category,
        id,
      ];

  Menu copyWith({
    String? title,
    int? price,
    String? image,
    String? status,
    int? preparationTime,
    String? category,
    String? id,
  }) {
    return Menu(
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      status: status ?? this.status,
      preparationTime: preparationTime ?? this.preparationTime,
      category: category ?? this.category,
      id: id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include id here
      'title': title,
      'price': price,
      'image': image,
      'status': status,
      'preparationTime': preparationTime,
      'category': category,
    };
  }

  static Menu fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] as String?,
      title: json['title'] as String?,
      price: _parseToInt(json['price']),
      image: json['image'] as String?,
      status: json['status'] as String?,
      preparationTime: json['preparationTime'] != null
          ? (json['preparationTime'] as int)
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
