import 'package:altmisdokuzapp/product/utility/base/base_firebase_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class CoffeTable with EquatableMixin, BaseFirebaseModel<CoffeTable>, IdModel {
  final int? tableId;
  @override
  final String? id;

  CoffeTable({this.tableId, this.id});

  @override
  List<Object?> get props => [tableId, id];

  CoffeTable copyWith({
    int? tableId,
  }) {
    return CoffeTable(tableId: tableId ?? this.tableId, id: id);
  }

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
    };
  }

  @override
  CoffeTable fromJson(Map<String, dynamic> json) {
    return CoffeTable(
      tableId: json['tableId'] as int?,
      id: json['id'] as String?,
    );
  }
}
