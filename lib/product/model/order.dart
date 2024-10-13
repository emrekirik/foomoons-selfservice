import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:altmisdokuzapp/product/utility/base/base_firebase_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class Order with EquatableMixin, BaseFirebaseModel<Order>, IdModel {
  final String? title;
  final int? price;
  final String? image;
  final String? piece;
  final int? preperationTime;
  final String? tableId;
  final String? status;
  final String? productId;

  @override
  final String? id;

  const Order({
    this.title,
    this.price,
    this.image,
    this.id,
    this.piece,
    this.preperationTime,
    this.tableId,
    this.status = 'yeni',
    this.productId,
  });

  @override
  List<Object?> get props => [
        title,
        price,
        image,
        id,
        preperationTime,
        piece,
        tableId,
        status,
        productId,
      ];

  /// Eşitlik operatörünü manuel olarak override ediyoruz
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Order) return false;

    return other.title == title &&
        other.price == price &&
        other.image == image &&
        other.id == id &&
        other.piece == piece &&
        other.preperationTime == preperationTime &&
        other.tableId == tableId &&
        other.status == status &&
        other.productId == productId;
  }

  /// hashCode fonksiyonunu manuel olarak override ediyoruz
  @override
  int get hashCode {
    return title.hashCode ^
        price.hashCode ^
        image.hashCode ^
        id.hashCode ^
        piece.hashCode ^
        preperationTime.hashCode ^
        tableId.hashCode ^
        status.hashCode ^
        productId.hashCode;
  }

  Order copyWith({
    String? title,
    int? price,
    String? image,
    String? piece,
    int? preperationTime,
    String? tableId,
    String? status,
    Menu? menu,
    String? productId,
  }) {
    return Order(
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      piece: piece ?? this.piece,
      preperationTime: preperationTime ?? this.preperationTime,
      tableId: tableId ?? this.tableId,
      status: status ?? this.status,
      id: id,
      productId: productId ?? this.productId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'image': image,
      'piece': piece,
      'preperationTime': preperationTime,
      'tableId': tableId,
      'status': status,
      'productId': productId,
    };
  }

  @override
  Order fromJson(Map<String, dynamic> json) {
    return Order(
      title: json['title'] as String?,
      price: json['price'] != null ? json['price'] as int : null,
      image: json['image'] as String?,
      piece: json['piece'] as String?,
      preperationTime: json['preperationTime'] != null
          ? (json['preperationTime'] as int)
          : null,
      tableId: json['tableId'] as String?,
      status: json['status'] as String?,
      id: json['id'] as String?,
      productId: json['productId'] as String?,
    );
  }
}
