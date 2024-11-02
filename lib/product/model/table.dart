import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:altmisdokuzapp/product/utility/base/base_firebase_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class CoffeTable with EquatableMixin, IdModel {
  final String? area;
  final String? tableId;
  final String? qrUrl;
  final List<Menu>? billItems;
  @override
  final String? id;

  CoffeTable({this.tableId, this.billItems, this.id, this.qrUrl, this.area});

  @override
  List<Object?> get props => [tableId, billItems, id, qrUrl, area];

  CoffeTable copyWith(
      {String? id,
      String? tableId,
      List<Menu>? billItems,
      String? qrUrl,
      String? area}) {
    return CoffeTable(
        tableId: tableId ?? this.tableId,
        billItems: billItems ?? this.billItems,
        id: id,
        qrUrl: qrUrl ?? this.qrUrl,
        area: area ?? this.area);
  }

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'billItems': billItems?.map((item) => item.toJson()).toList(),
      'id': id,
      'qrUrl': qrUrl,
      'area': area
    };
  }

  static CoffeTable fromJson(Map<String, dynamic> json) {
    return CoffeTable(
        tableId: json['tableId'] as String?,
        billItems: (json['billItems'] as List<dynamic>?)
            ?.map((item) => Menu.fromJson(item as Map<String, dynamic>))
            .toList(),
        id: json['id'] as String?,
        qrUrl: json['qrUrl'] as String?,
        area: json['area'] as String?);
  }
}
