import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

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
