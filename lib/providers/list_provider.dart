import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shopping_list.dart';
import '../models/item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<ShoppingList> _lists = [];
  ShoppingList? _recentlyDeletedList;

  List<ShoppingList> get lists => _lists;

  // Método para carregar listas do usuário atual
  Future<void> loadUserLists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (kDebugMode) {
        print('Usuário não autenticado. Não é possível carregar listas.');
      }
      return;
    }

    try {
      // Carrega listas criadas pelo usuário
      QuerySnapshot querySnapshot = await _firestore
          .collection('shopping_lists')
          .where('createdBy', isEqualTo: user.uid)
          .get();

      // Carrega listas compartilhadas com o usuário
      QuerySnapshot sharedListsSnapshot = await _firestore
          .collection('shopping_lists')
          .where('sharedWith', arrayContains: user.uid)
          .get();

      // Limpa a lista antes de carregar novas
      _lists.clear();

      // Adiciona listas criadas pelo usuário
      for (var doc in querySnapshot.docs) {
        _lists.add(ShoppingList.fromFirestore(doc));
      }

      // Adiciona listas compartilhadas
      for (var doc in sharedListsSnapshot.docs) {
        _lists.add(ShoppingList.fromFirestore(doc));
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar listas: $e');
      }
    }
  }

  // Método para criar uma nova lista
  Future<void> createList(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (kDebugMode) {
        print('Usuário não autenticado. Não é possível criar lista.');
      }
      return;
    }

    try {
      DocumentReference docRef = await _firestore.collection('shopping_lists').add({
        'name': name,
        'sharedWith': [],
        'createdBy': user.uid,
      });
      ShoppingList newList = ShoppingList(
        id: docRef.id,
        name: name,
        items: [],
        sharedWith: [],
        createdBy: user.uid,
      );
      _lists.add(newList);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao criar lista: $e');
      }
    }
  }

  // Método para compartilhar uma lista com outro usuário
  Future<void> shareList(String listId, String email) async {
    try {
      // Busca o usuário pelo email
      final userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // Obtem o ID do usuário que receberá a lista
        String recipientUserId = userSnapshot.docs.first.id;

        // Adiciona o ID à lista de compartilhamento
        await _firestore.collection('shopping_lists').doc(listId).update({
          'sharedWith': FieldValue.arrayUnion([recipientUserId]),
        });

        int index = _lists.indexWhere((list) => list.id == listId);
        if (index != -1) {
          _lists[index].sharedWith.add(recipientUserId);
          notifyListeners();
        }
      } else {
        throw Exception('Usuário não encontrado.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao compartilhar lista: $e');
      }
    }
  }

  // Método para deletar uma lista
  Future<void> deleteList(String listId) async {
    try {
      await _firestore.collection('shopping_lists').doc(listId).delete();
      _lists.removeWhere((list) => list.id == listId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao excluir lista: $e');
      }
    }
  }

  // Método para editar uma lista existente
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
}
