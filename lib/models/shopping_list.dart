import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class ShoppingList {
  String id;
  String name;
  List<Item> items;
  List<String> sharedWith; // Lista de e-mails para compartilhamento
  String createdBy; // ID do usuário que criou a lista

  ShoppingList({
    required this.id,
    required this.name,
    required this.items,
    required this.sharedWith,
    required this.createdBy,
  });

  // Método para criar uma instância a partir de um documento do Firestore
  factory ShoppingList.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Carrega a lista de e-mails no campo `sharedWith`
    List<String> sharedWith = [];
    if (data['sharedWith'] != null) {
      sharedWith = List<String>.from(data['sharedWith']);
    }

    return ShoppingList(
      id: doc.id,
      name: data['name'] ?? '',
      items: [], // Inicializa vazio e carrega separadamente os itens da subcoleção
      sharedWith: sharedWith,
      createdBy: data['createdBy'] ?? '',
    );
  }

  // Método para carregar os itens de uma lista específica
  Future<void> loadItems() async {
    try {
      final itemsSnapshot = await FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(id)
          .collection('items') // Subcoleção "items"
          .get();

      items = itemsSnapshot.docs.map((QueryDocumentSnapshot doc) {
        return Item.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList(); // Cria a lista de itens
    } catch (e) {
      print('Erro ao carregar itens: $e');
    }
  }

  // Método para converter o objeto em um mapa para o Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sharedWith': sharedWith, // Agora salva e-mails diretamente
      'createdBy': createdBy,
    };
  }
}
