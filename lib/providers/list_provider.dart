import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shopping_list.dart';
import '../models/item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<ShoppingList> _lists = [];

  List<ShoppingList> get lists => _lists;

  // Método para carregar listas do usuário atual com base no e-mail no campo `sharedWith`
  Stream<List<ShoppingList>> loadUserLists() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (kDebugMode) {
        print('Usuário não autenticado. Não é possível carregar listas.');
      }
      return Stream.value([]); // Retorna uma lista vazia se o usuário não estiver autenticado
    }

    final userEmail = user.email;

    // Carrega listas criadas pelo usuário e listas compartilhadas com o e-mail do usuário
    return _firestore.collection('shopping_lists')
        .where('sharedWith', arrayContains: userEmail) // Filtra listas com o e-mail do usuário
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ShoppingList.fromFirestore(doc)).toList();
    });
  }

  // Método para criar uma nova lista
  Future<void> createList(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Usuário não autenticado. Não é possível criar lista.');
      return;
    }

    try {
      DocumentReference docRef = await _firestore.collection('shopping_lists').add({
        'name': name,
        'sharedWith': [user.email], // Inclui o e-mail do criador para garantir acesso
        'createdBy': user.uid,
      });

      ShoppingList newList = ShoppingList(
        id: docRef.id,
        name: name,
        items: [],
        sharedWith: [user.email!], // Inclui o e-mail do criador localmente
        createdBy: user.uid,
      );
      _lists.add(newList);
      notifyListeners();
    } catch (e) {
      print('Erro ao criar lista: $e');
    }
  }

  // Método para compartilhar uma lista com outro usuário usando o e-mail do destinatário
  Future<void> shareList(String listId, String email) async {
    final normalizedEmail = email.trim().toLowerCase();

    // Adiciona o e-mail ao campo `sharedWith` no Firestore
    try {
      await _firestore.collection('shopping_lists').doc(listId).update({
        'sharedWith': FieldValue.arrayUnion([normalizedEmail]),
      });

      // Atualiza o objeto local para refletir o compartilhamento com o e-mail
      int index = _lists.indexWhere((list) => list.id == listId);
      if (index != -1) {
        _lists[index].sharedWith.add(normalizedEmail);
        notifyListeners();
      }

      // Envia notificação ao destinatário
      await _firestore.collection('notifications').add({
        'listId': listId,
        'email': normalizedEmail,
        'message': 'Você recebeu uma nova lista compartilhada!',
        'timestamp': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print('Erro ao adicionar e-mail ao campo sharedWith: $e');
      throw e;
    }
  }

  // Método para deletar uma lista
  Future<void> deleteList(String listId) async {
    try {
      await _firestore.collection('shopping_lists').doc(listId).delete();
      _lists.removeWhere((list) => list.id == listId); // Remove a lista da lista local
      notifyListeners(); // Notifica os ouvintes sobre a mudança
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
