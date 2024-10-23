class Item {
  String? id; // Permite que o 'id' seja nulo inicialmente
  String name;
  int quantity;
  bool isBought;

  Item({
    this.id, // 'id' pode ser opcional durante a criação
    required this.name,
    required this.quantity,
    this.isBought = false,
  });

  // Método para criar um item a partir de um documento do Firestore
  factory Item.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Item(
      id: documentId, // Atribui o ID do documento do Firestore
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 1,
      isBought: data['isBought'] ?? false,
    );
  }

  // Método para converter o item em um mapa para o Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'isBought': isBought,
    };
  }

  // Método para criar um item a partir de um mapa
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 1,
      isBought: map['isBought'] ?? false,
    );
  }

  // Método para alternar o status de compra do item
  void toggleBoughtStatus() {
    isBought = !isBought;
  }

  // Método de clonagem
  Item copyWith({
    String? id,
    String? name,
    int? quantity,
    bool? isBought,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isBought: isBought ?? this.isBought,
    );
  }

  // Implementação de igualdade de objetos
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Item &&
        other.id == id &&
        other.name == name &&
        other.quantity == quantity &&
        other.isBought == isBought;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ quantity.hashCode ^ isBought.hashCode;
  }
}
