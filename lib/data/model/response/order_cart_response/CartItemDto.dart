import '../../../../domain/model/CartItem.dart';
import '../menu_response/MealDto.dart';

/// meal : {"_id":"65f0a629671f895443718c7a","restaurant":"65ee39a0b3eac564b5db7a81","image":"http://res.cloudinary.com/dlvndc08a/image/upload/v1710269992/meal/mzvhn5kqhyk2jwyw4rb9.jpg","name":"Chicken Shawerma Fattah","price":29.99,"currency":"EGP","description":"Aromatic layers of seasoned rice, crispy pita bread, and tender chicken shawarma, drizzled with a creamy tahini sauce.","rate":4.8,"tags":["chicken","shawarma","rice"],"calories":520,"protein":35,"fat":60,"carbohydrates":100,"isDeleted":false,"createdAt":"2024-03-12T18:59:53.973Z","updatedAt":"2024-03-12T18:59:53.973Z","__v":0}
/// quantity : 2
/// price : 29.99
/// _id : "661c5c788064328a2efd07bd"

class CartItemDto {
  CartItemDto({
    this.meal,
    this.quantity,
    this.price,
    this.totalPrice,
    this.id,
    this.size
  });

  CartItemDto.fromJson(dynamic json) {
    meal = json['meal'] != null ? MealDto.fromJson(json['meal']) : null;
    quantity = json['quantity'];
    price = json['price'];
    totalPrice = json['totalPrice'];
    id = json['_id'];
    size = json['size'];
  }

  MealDto? meal;
  int? quantity;
  num? price;
  num? totalPrice;
  String? id;
  String? size;

  CartItem toCartItem() {
    return CartItem(
      meal: meal?.toMeal(),
      quantity: quantity,
      price: price,
      totalPrice: totalPrice,
      id: id,
      size: size,
    );
  }
}
