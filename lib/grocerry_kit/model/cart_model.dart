class CartModel {
  List<CartItemModel> items = [];

  CartModel();

  CartModel.fromMap(Map map) {
    items = (map['items'] as List).map((e) => CartItemModel.fromMap(e)).toList();
  }

  Map toMap() {
    return {
      'items': items.map((e) => e.toMap()).toList(),
    };
  }
}

class CartItemModel {
  double price;
  double subtotal;
  int momOption;
  int quantity;
  int productStock;
  String image;
  String productID;
  String name;
  String catID;
  String storeId;
  String subcatID;
  String description;
  bool isInStock;

  CartItemModel.fromMap(Map map) {
    this.price = map['price'];
    this.image = map['image'];
    this.quantity = map['quantity'];
    this.productID = map['productID'];
    this.momOption = map['momOption'];
    this.name = map['name'];
    this.catID = map['catID'];
    this.storeId = map['storeId'];
    this.subcatID = map['subcatID'];
    this.subtotal = map['subtotal'];
    this.description = map['description'];
    this.productStock = map['productStock'];
    this.isInStock = map['isInStock'];
  }

  Map toMap() {
    return {
      'price': this.price,
      'image': this.image,
      'productID': this.productID,
      'momOption': this.momOption,
      'name': this.name,
      'quantity': this.quantity,
      'catID': this.catID,
      'storeId': this.storeId,
      'subcatID': this.subcatID,
      'subtotal': this.subtotal,
      'description': this.description,
      'productStock': this.productStock,
      'isInStock': this.isInStock,
    };
  }
}
