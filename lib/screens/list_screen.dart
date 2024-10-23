import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shopping_list.dart';
import '../models/item.dart'; // Importar o modelo Item
import '../providers/list_provider.dart';

class ListScreen extends StatelessWidget {
  final ShoppingList shoppingList;

  const ListScreen(this.shoppingList, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shoppingList.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Lógica para compartilhar a lista
              _showShareDialog(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: shoppingList.items.length,
        itemBuilder: (context, index) {
          final item = shoppingList.items[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text('Quantidade: ${item.quantity}'),
            trailing: Checkbox(
              value: item.isBought,
              onChanged: (value) {
                Provider.of<ListProvider>(context, listen: false)
                    .toggleItemStatus(shoppingList, index);
              },
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
