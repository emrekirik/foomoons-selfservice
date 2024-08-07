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
  final Menu? menu;

  @override
  final String? id;

  const Order(
      {this.title,
      this.price,
      this.image,
      this.id,
      this.piece,
      this.preperationTime,
      this.tableId,
      this.status = 'yeni',
      this.menu});

  int? get effectivePreparationTime {
    if (preperationTime != null) {
      return preperationTime;
    } else if (menu != null) {
      return menu!.preparationTime;
    }
    return null;
  }

  @override
  List<Object?> get props =>
      [title, price, image, id, preperationTime, piece, tableId, status, menu];

  Order copyWith({
    String? title,
    int? price,
    String? image,
    String? piece,
    int? preperationTime,
    String? tableId,
    String? status,
    Menu? menu,
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
      menu: menu ?? this.menu,
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
      'menu': menu?.toJson(),
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
          ? (json['preperationTime'] as int) * 60
          : null,
      tableId: json['tableId'] as String?,
      status: json['status'] as String?,
      id: json['id'] as String?,
      menu: json['menu'] != null
          ? Menu.fromJson(json['menu'] as Map<String, dynamic>)
          : null,
    );
  }
}
