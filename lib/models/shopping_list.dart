import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class ShoppingList {
  String id;
  String name;
  List<Item> items;
  List<String> sharedWith;
  String createdBy; // Campo para armazenar o ID do usuário que criou a lista

  ShoppingList({
    required this.id,
    required this.name,
    required this.items,
    required this.sharedWith,
    required this.createdBy, // Adiciona createdBy como parâmetro obrigatório
  });

  // Método para criar uma instância a partir de um documento do Firestore
  factory ShoppingList.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ShoppingList(
      id: doc.id,
      name: data['name'] ?? '',
      items: [], // Inicializamos vazio e carregamos separadamente os itens da subcoleção
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
      createdBy: data['createdBy'] ?? '', // Recupera o campo createdBy do Firestore
    );
  }

  // Método para converter o objeto em um mapa para o Firestore, sem incluir `items`
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sharedWith': sharedWith,
      'createdBy': createdBy, // Adiciona createdBy ao map
    };
  }
}
