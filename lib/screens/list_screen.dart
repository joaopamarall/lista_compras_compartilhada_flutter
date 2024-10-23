import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shopping_list.dart';
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
            icon: Icon(Icons.share),
            onPressed: () {
              // Lógica para compartilhar a lista
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
        child: Icon(Icons.add),
        onPressed: () {
          // Abrir tela de adicionar item
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
          title: Text('Adicionar Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                decoration: InputDecoration(labelText: 'Nome do Item'),
              ),
              TextField(
                controller: itemQuantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantidade'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Adicionar'),
              onPressed: () {
                final itemName = itemNameController.text;
                final itemQuantity =
                    int.tryParse(itemQuantityController.text) ?? 1;
                if (itemName.isNotEmpty) {
                  Provider.of<ListProvider>(context, listen: false)
                      .addItem(shoppingList, itemName, itemQuantity);
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
