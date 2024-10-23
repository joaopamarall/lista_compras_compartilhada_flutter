import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shopping_list.dart';

class ListProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ShoppingList> _lists = [];
  ShoppingList? _recentlyDeletedList;

  List<ShoppingList> get lists => _lists;

// Método para buscar listas do Firestore
  Future<void> fetchLists() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('shopping_lists').get();
      List<ShoppingList> fetchedLists = [];
      for (var doc in snapshot.docs) {
        ShoppingList list = ShoppingList.fromFirestore(doc);
        fetchedLists.add(list);
      }
      _lists = fetchedLists;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar listas: $e');
      }
    }
  }

  // Criar uma nova lista
  Future<void> createList(String name) async {
    try {
      DocumentReference docRef = await _firestore.collection('shopping_lists').add({
        'name': name,
        'sharedWith': [],
      });
      ShoppingList newList = ShoppingList(
        id: docRef.id,
        name: name,
        items: [],
        sharedWith: [],
      );
      _lists.add(newList);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao criar lista: $e');
      }
    }
  }

  // Atualizar uma lista existente
  Future<void> updateList(String listId, String newName) async {
    try {
      await _firestore.collection('shopping_lists').doc(listId).update({
        'name': newName,
      });
      int index = _lists.indexWhere((list) => list.id == listId);
      if (index != -1) {
        _lists[index].name = newName;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar lista: $e');
      }
    }
  }

  // Excluir uma lista e armazená-la para possível restauração
  Future<void> deleteList(String listId) async {
    try {
      int index = _lists.indexWhere((list) => list.id == listId);
      if (index != -1) {
        _recentlyDeletedList = _lists[index]; // Armazena a lista excluída
        await _firestore.collection('shopping_lists').doc(listId).delete();
        _lists.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao excluir lista: $e');
      }
    }
  }

  // Restaurar a última lista excluída
  void undoDeleteList() {
    if (_recentlyDeletedList != null) {
      _lists.add(_recentlyDeletedList!);
      _recentlyDeletedList = null;
      notifyListeners();
    }
  }

  // Método para adicionar uma nova lista
  Future<void> addList(String name) async {
    try {
      DocumentReference docRef = await _firestore.collection('shopping_lists').add({
        'name': name,
        'sharedWith': [],
      });
      _lists.add(
        ShoppingList(id: docRef.id, name: name, items: [], sharedWith: []),
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao adicionar lista: $e');
      }
    }
  }

  // Método para editar uma lista existente
  Future<void> editList(String listId, String newName) async {
    try {
      await _firestore.collection('shopping_lists').doc(listId).update({'name': newName});
      int index = _lists.indexWhere((list) => list.id == listId);
      if (index != -1) {
        _lists[index].name = newName;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao editar lista: $e');
      }
    }
  }

  // Método para adicionar um novo item a uma lista
  Future<void> addItem(ShoppingList list, newItem, int itemQuantity) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('shopping_lists')
          .doc(list.id)
          .collection('items')
          .add(newItem.toMap());
      newItem.id = docRef.id;
      list.items.add(newItem);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao adicionar item: $e');
      }
    }
  }

  // Método para editar um item em uma lista
  Future<void> editItem(ShoppingList list, int index, updatedItem) async {
    try {
      await _firestore
          .collection('shopping_lists')
          .doc(list.id)
          .collection('items')
          .doc(updatedItem.id)
          .update(updatedItem.toMap());
      list.items[index] = updatedItem;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao editar item: $e');
      }
    }
  }

  Future<void> deleteItem(ShoppingList list, int index) async {
    try {
      // Verifica se o ID do item é válido antes de excluir
      String? itemId = list.items[index].id;

      if (itemId!.isNotEmpty) {
        await _firestore
            .collection('shopping_lists')
            .doc(list.id)
            .collection('items')
            .doc(itemId)
            .delete();

        // Remove o item da lista local
        list.items.removeAt(index);
        notifyListeners();
      } else {
        if (kDebugMode) {
          print('Erro: ID do item é inválido ou não encontrado.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao excluir item: $e');
      }
    }
  }

  // Método para alternar o status de compra de um item
  void toggleItemStatus(ShoppingList list, int index) {
    list.items[index].toggleBoughtStatus();
    notifyListeners();

    // Atualiza o Firestore
    _firestore
        .collection('shopping_lists')
        .doc(list.id)
        .collection('items')
        .doc(list.items[index].id)
        .update({'isBought': list.items[index].isBought});
  }
}
