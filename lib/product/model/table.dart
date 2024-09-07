import 'package:altmisdokuzapp/product/model/menu.dart';
import 'package:altmisdokuzapp/product/utility/base/base_firebase_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class CoffeTable with EquatableMixin, IdModel {
  final int? tableId;
  final String? qrUrl;
  final List<Menu>? billItems;
  @override
  final String? id;

  CoffeTable({this.tableId, this.billItems, this.id, this.qrUrl});

  @override
  List<Object?> get props => [tableId, billItems, id, qrUrl];

  CoffeTable copyWith({
    String? id,
    int? tableId,
    List<Menu>? billItems,
    String? qrUrl,
  }) {
    return CoffeTable(
      tableId: tableId ?? this.tableId,
      billItems: billItems ?? this.billItems,
      id: id,
      qrUrl: qrUrl ?? this.qrUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'billItems': billItems?.map((item) => item.toJson()).toList(),
      'id': id,
      'qrUrl': qrUrl,
    };
  }

  static CoffeTable fromJson(Map<String, dynamic> json) {
    return CoffeTable(
      tableId: json['tableId'] as int?,
      billItems: (json['billItems'] as List<dynamic>?)
          ?.map((item) => Menu.fromJson(item as Map<String, dynamic>))
          .toList(),
      id: json['id'] as String?,
      qrUrl: json['qrUrl'] as String?,
    );
  }
}
