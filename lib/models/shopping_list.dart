import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class ShoppingList {
  String id;
  String name;
  List<Item> items;
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

    return ShoppingList(
      id: doc.id,
      name: data['name'] ?? '',
      items: [], // Inicializamos vazio e carregamos separadamente os itens da subcoleção
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
    );
  }

  // Método para converter o objeto em um mapa para o Firestore, sem incluir `items`
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sharedWith': sharedWith,
    };
  }
}
