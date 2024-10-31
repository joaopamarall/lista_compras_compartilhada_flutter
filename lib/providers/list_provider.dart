import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shopping_list.dart';
import '../models/item.dart';

class ListProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<ShoppingList> _lists = [];
  ShoppingList? _recentlyDeletedList;

  List<ShoppingList> get lists => _lists;

  // Método para criar uma nova lista
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
      await _firestore.collection('shopping_lists').doc(listId).update({'name': newName});
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
        _recentlyDeletedList = _lists[index];
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

  // Método para adicionar um novo item a uma lista
  Future<void> addItem(ShoppingList list, Item newItem) async {
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

  // Método para excluir um item de uma lista
  Future<void> deleteItem(ShoppingList list, int index) async {
    try {
      String? itemId = list.items[index].id;
      if (itemId != null && itemId.isNotEmpty) {
        await _firestore
            .collection('shopping_lists')
            .doc(list.id)
            .collection('items')
            .doc(itemId)
            .delete();

        list.items.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao excluir item: $e');
      }
    }
  }
}
