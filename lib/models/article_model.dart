class Article {
  final String id;
  final String description;
  final double price;

  const Article({
    required this.id,
    required this.description,
    required this.price,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['PRICE'];
    final parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse('$rawPrice') ?? 0.0;

    return Article(
      id: (json['ID'] ?? '').toString(),
      description: (json['DESCRIPTION'] ?? '').toString(),
      price: parsedPrice,
    );
  }
}
