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
  final int? stock;
  final int? piece; // Yeni eklenen özellik

  const Menu({
    this.title,
    this.price,
    this.image,
    this.id,
    this.status = 'yeni',
    this.preparationTime,
    this.category,
    this.stock,
    this.piece, // Constructor'a ekleyin
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
        stock,
        piece, // Listeye ekleyin
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Menu) return false;

    return other.title == title &&
        other.price == price &&
        other.image == image &&
        other.status == status &&
        other.preparationTime == preparationTime &&
        other.category == category &&
        other.id == id &&
        other.stock == stock &&
        other.piece == piece; // Eşitlik kontrolüne ekleyin
  }

  @override
  int get hashCode {
    return title.hashCode ^
        price.hashCode ^
        image.hashCode ^
        status.hashCode ^
        preparationTime.hashCode ^
        category.hashCode ^
        id.hashCode ^
        stock.hashCode ^
        piece.hashCode; // HashCode'a ekleyin
  }

  /// Copy this instance with new values, while preserving existing ones if not provided
  Menu copyWith({
    String? title,
    int? price,
    String? image,
    String? status,
    int? preparationTime,
    String? category,
    String? id,
    int? stock,
    int? piece, // copyWith methoduna ekleyin
  }) {
    return Menu(
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      status: status ?? this.status,
      preparationTime: preparationTime ?? this.preparationTime,
      category: category ?? this.category,
      id: id ?? this.id,
      stock: stock ?? this.stock,
      piece: piece ?? this.piece, // Değer atama yapın
    );
  }

  /// Convert this Menu instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'image': image,
      'status': status,
      'preparationTime': preparationTime,
      'category': category,
      'stock': stock,
      'piece': piece, // JSON dönüşümüne ekleyin
    };
  }

  /// Create a Menu instance from a JSON map
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
      stock: _parseToInt(json['stock']),
      piece: _parseToInt(json['piece']), // JSON'dan `piece` değerini alın
    );
  }

  /// Helper method to safely parse price values to int
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
