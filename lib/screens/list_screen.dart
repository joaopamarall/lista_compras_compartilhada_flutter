import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shopping_list.dart';
import '../models/item.dart'; // Importar o modelo Item
import '../providers/list_provider.dart';

class ListScreen extends StatelessWidget {
  final ShoppingList shoppingList;

  const ListScreen({super.key, required this.shoppingList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shoppingList.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _showShareDialog(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: shoppingList.items.length,
        itemBuilder: (context, index) {
          final item = shoppingList.items[index];
          return Dismissible(
            key: Key(item.id ?? index.toString()),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await _showDeleteItemConfirmation(context);
            },
            onDismissed: (direction) {
              Provider.of<ListProvider>(context, listen: false)
                  .deleteItem(shoppingList, index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Item ${item.name} removido')),
              );
            },
            child: ListTile(
              title: Text(item.name),
              subtitle: Text('Quantidade: ${item.quantity}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: item.isBought,
                    onChanged: (value) {
                      Provider.of<ListProvider>(context, listen: false)
                          .toggleItemStatus(shoppingList, index);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditItemDialog(context, item, index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddItemDialog(context);
        },
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
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
                final itemQuantity =
                    int.tryParse(itemQuantityController.text) ?? 1;

                if (itemName.isNotEmpty) {
                  final newItem = Item(
                    name: itemName,
                    quantity: itemQuantity,
                    isBought: false,
                  );

                  Provider.of<ListProvider>(context, listen: false)
                      .addItem(shoppingList, newItem, itemQuantity);

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialog(BuildContext context, Item item, int index) {
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
                final updatedQuantity =
                    int.tryParse(itemQuantityController.text) ?? 1;

                if (updatedName.isNotEmpty) {
                  final updatedItem = item.copyWith(
                    name: updatedName,
                    quantity: updatedQuantity,
                  );

                  Provider.of<ListProvider>(context, listen: false)
                      .editItem(shoppingList, index, updatedItem);

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showDeleteItemConfirmation(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Compartilhar Lista'),
          content: const Text('Função de compartilhamento em desenvolvimento.'),
          actions: [
            TextButton(
              child: const Text('Fechar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
