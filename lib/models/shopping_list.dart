import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingList {
  String id;
  String name;
  List<Item> items; // Certifique-se de que 'items' seja uma lista de 'Item'
  List<String> sharedWith;

  ShoppingList({
    required this.id,
    required this.name,
    required this.items,
    required this.sharedWith,
  });

  // Método para criar uma instância a partir de um documento do Firestore
  factory ShoppingList.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Converte os itens do Firestore para objetos 'Item'
    List<Item> itemList = [];
    if (data['items'] != null) {
      List<dynamic> itemsData = data['items'];
      itemList = itemsData.map((item) => Item.fromMap(item)).toList();
    }

    return ShoppingList(
      id: doc.id,
      name: data['name'] ?? '',
      items: itemList,
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
    );
  }

  // Método para converter o objeto em um mapa para o Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'items': items.map((item) => item.toMap()).toList(),
      'sharedWith': sharedWith,
    };
  }
}

class Item {
  String? id;
  String name;
  int quantity;
  bool isBought;

  Item({
    this.id,
    required this.name,
    required this.quantity,
    this.isBought = false,
  });

  // Método para criar um item a partir de um mapa
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 1,
      isBought: map['isBought'] ?? false,
    );
  }

  // Método para converter o item em um mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'isBought': isBought,
    };
  }

  // Método para alternar o status de compra do item
  void toggleBoughtStatus() {
    isBought = !isBought;
  }
}
