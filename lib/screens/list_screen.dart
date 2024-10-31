import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';
import '../models/shopping_list.dart';

class ListScreen extends StatelessWidget {
  final ShoppingList shoppingList;

  const ListScreen({super.key, required this.shoppingList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shoppingList.name),
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
            return const Center(child: Text('Erro ao carregar itens.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum item na lista.'));
          }

          final items = snapshot.data!.docs.map((doc) {
            return Item.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Checkbox(
                  value: item.isBought,
                  onChanged: (bool? value) {
                    _toggleBoughtStatus(context, item, value!);
                  },
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 18,
                    decoration: item.isBought ? TextDecoration.lineThrough : null,
                    color: item.isBought ? Colors.grey : Colors.white,
                  ),
                ),
                subtitle: Text(
                  'Quantidade: ${item.quantity}',
                  style: TextStyle(
                    color: item.isBought ? Colors.grey : Colors.white70,
                  ),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditItemDialog(context, item);
                    } else if (value == 'delete') {
                      _showDeleteItemConfirmation(context, item.id!);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Editar'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Excluir'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _toggleBoughtStatus(BuildContext context, Item item, bool isBought) async {
    FirebaseFirestore.instance
        .collection('shopping_lists')
        .doc(shoppingList.id)
        .collection('items')
        .doc(item.id)
        .update({'isBought': isBought});
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    final itemNameController = TextEditingController();
    final itemQuantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final itemName = itemNameController.text;
              final itemQuantity = int.tryParse(itemQuantityController.text) ?? 1;

              if (itemName.isNotEmpty) {
                final newItem = Item(
                  id: DateTime.now().toString(),
                  name: itemName,
                  quantity: itemQuantity,
                );

                FirebaseFirestore.instance
                    .collection('shopping_lists')
                    .doc(shoppingList.id)
                    .collection('items')
                    .add(newItem.toMap());

                Navigator.pop(context);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditItemDialog(BuildContext context, Item item) async {
    final itemNameController = TextEditingController(text: item.name);
    final itemQuantityController = TextEditingController(text: item.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedName = itemNameController.text;
              final updatedQuantity = int.tryParse(itemQuantityController.text) ?? 1;

              FirebaseFirestore.instance
                  .collection('shopping_lists')
                  .doc(shoppingList.id)
                  .collection('items')
                  .doc(item.id)
                  .update({'name': updatedName, 'quantity': updatedQuantity});

              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteItemConfirmation(BuildContext context, String itemId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Item'),
        content: const Text('Tem certeza que deseja excluir este item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('shopping_lists')
                  .doc(shoppingList.id)
                  .collection('items')
                  .doc(itemId)
                  .delete();

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
