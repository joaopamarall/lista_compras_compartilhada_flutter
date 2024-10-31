import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';
import '../models/shopping_list.dart';

class ItemScreen extends StatelessWidget {
  final ShoppingList shoppingList;

  const ItemScreen({super.key, required this.shoppingList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itens da Lista: ${shoppingList.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddItemDialog(context, shoppingList),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('shopping_lists')
            .doc(shoppingList.id)
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: const Text('Erro ao carregar itens.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum item na lista.'));
          }

          // Mapeia os documentos do Firestore para objetos `Item`
          final items = snapshot.data!.docs.map((doc) {
            return Item.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('Quantidade: ${item.quantity}'),
                trailing: Icon(
                  item.isBought
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                ),
                onTap: () {
                  FirebaseFirestore.instance
                      .collection('shopping_lists')
                      .doc(shoppingList.id)
                      .collection('items')
                      .doc(item.id)
                      .update({'isBought': !item.isBought});
                },
                onLongPress: () => _showEditItemDialog(context, shoppingList, item),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, ShoppingList shoppingList) {
    final itemNameController = TextEditingController();
    final itemQuantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                decoration: const InputDecoration(labelText: 'Nome do Item'),
              ),
              TextField(
                controller: itemQuantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Adicionar'),
              onPressed: () {
                final itemName = itemNameController.text;
                final itemQuantity = int.tryParse(itemQuantityController.text) ?? 1;

                if (itemName.isNotEmpty) {
                  final newItem = Item(
                    name: itemName,
                    quantity: itemQuantity,
                  );

                  FirebaseFirestore.instance
                      .collection('shopping_lists')
                      .doc(shoppingList.id)
                      .collection('items')
                      .add(newItem.toMap());

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialog(BuildContext context, ShoppingList shoppingList, Item item) {
    final itemNameController = TextEditingController(text: item.name);
    final itemQuantityController = TextEditingController(
      text: item.quantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                decoration: const InputDecoration(labelText: 'Nome do Item'),
              ),
              TextField(
                controller: itemQuantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Salvar'),
              onPressed: () {
                final updatedName = itemNameController.text;
                final updatedQuantity = int.tryParse(itemQuantityController.text) ?? 1;

                if (updatedName.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('shopping_lists')
                      .doc(shoppingList.id)
                      .collection('items')
                      .doc(item.id)
                      .update({
                    'name': updatedName,
                    'quantity': updatedQuantity,
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
