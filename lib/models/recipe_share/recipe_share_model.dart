class RecipeShareModel {
  final String? recipeName;
  final List<String>? ingredients;
  final List<String>? instructions;
  final String? cookingTime;
  final String? difficultyLevel;
  final String? cuisineType;
  final List<String>? imageUrls;
  final DateTime sharingDateTime;

  RecipeShareModel({
    this.recipeName,
    this.ingredients,
    this.instructions,
    this.cookingTime,
    this.difficultyLevel,
    this.cuisineType,
    this.imageUrls,
    required this.sharingDateTime,
  });

  factory RecipeShareModel.fromJson(Map<String, dynamic> json) {
    return RecipeShareModel(
      recipeName: json['recipeName'],
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      cookingTime: json['cookingTime'],
      difficultyLevel: json['difficultyLevel'],
      cuisineType: json['cuisineType'],
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((url) => url.toString())
              .toList() ??
          [],
      sharingDateTime: json['sharingDateTime'] != null
          ? DateTime.parse(json['sharingDateTime'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipeName': recipeName,
      'ingredients': ingredients,
      'instructions': instructions,
      'cookingTime': cookingTime,
      'difficultyLevel': difficultyLevel,
      'cuisineType': cuisineType,
      'imageUrls': imageUrls, // Changed imageUrl to imageUrls
      'sharingDateTime': sharingDateTime.toIso8601String(),
    };
  }
}
