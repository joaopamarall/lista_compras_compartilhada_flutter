import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/shopping_list.dart';
import '../providers/list_provider.dart';


class ItemScreen extends StatelessWidget {
  final ShoppingList shoppingList;

  const ItemScreen(this.shoppingList, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itens da Lista: ${shoppingList.name}'),
      ),
      body: ListView.builder(
        itemCount: shoppingList.items.length,
        itemBuilder: (context, index) {
          final item = shoppingList.items[index];
          return ListTile(
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
                  icon: Icon(Icons.edit),
                  onPressed: () => _showEditItemDialog(context, item, index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddItemDialog(context),
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
                  final newItem = Item(
                    id: DateTime.now().toString(),
                    name: itemName,
                    quantity: itemQuantity,
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

  void _showEditItemDialog(BuildContext context, item, int index) {
    final itemNameController = TextEditingController(text: item.name);
    final itemQuantityController = TextEditingController(
      text: item.quantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Item'),
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
              child: Text('Salvar'),
              onPressed: () {
                final updatedName = itemNameController.text;
                final updatedQuantity =
                    int.tryParse(itemQuantityController.text) ?? 1;

                if (updatedName.isNotEmpty) {
                  final updatedItem = Item(
                    id: item.id,
                    name: updatedName,
                    quantity: updatedQuantity,
                    isBought: item.isBought,
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
}
