class Vegetable {
  final int id;
  final String name;
  final String imageUrl;

  Vegetable({required this.id, required this.name, required this.imageUrl});

  factory Vegetable.fromJson(Map<String, dynamic> json) {
    return Vegetable(
      id: json['id'],
      name: json['name'],
      imageUrl: "https://spoonacular.com/cdn/ingredients_100x100/${json['image']}",
    );
  }
}
