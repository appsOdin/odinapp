class Picture {
  final String picture;
  final String ext;

  const Picture({required this.picture, required this.ext});

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      picture: (json['PICTURE'] ?? '').toString(),
      ext: (json['EXT'] ?? '').toString(),
    );
  }

  bool get hasImage => picture.trim().isNotEmpty;
}

class Stock {
  final String name;
  final double available;

  const Stock({required this.name, required this.available});

  factory Stock.fromJson(Map<String, dynamic> json) {
    final rawAvailable = json['AVAILABLE'];
    final parsedAvailable = rawAvailable is num
        ? rawAvailable.toDouble()
        : double.tryParse('$rawAvailable') ?? 0.0;

    return Stock(
      name: (json['NAME'] ?? '').toString(),
      available: parsedAvailable,
    );
  }
}

class ArticleDetail {
  final String id;
  final String description;
  final double price;
  final List<Picture> pictures;
  final List<Stock> stocks;

  const ArticleDetail({
    required this.id,
    required this.description,
    required this.price,
    required this.pictures,
    required this.stocks,
  });

  factory ArticleDetail.fromApiData(Map<String, dynamic> data) {
    final dynamic articleListRaw = data['atricle'] ?? data['article'];
    final List<Map<String, dynamic>> articleList = articleListRaw is List
        ? articleListRaw.whereType<Map<String, dynamic>>().toList(
            growable: false,
          )
        : const <Map<String, dynamic>>[];

    final Map<String, dynamic> mainArticle = articleList.isNotEmpty
        ? articleList.first
        : <String, dynamic>{};

    final rawPrice = mainArticle['PRICE'];
    final parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse('$rawPrice') ?? 0.0;

    final dynamic picturesRaw = data['pictures'];
    final pictures = picturesRaw is List
        ? picturesRaw
              .whereType<Map<String, dynamic>>()
              .map(Picture.fromJson)
              .toList(growable: false)
        : const <Picture>[];

    final dynamic stocksRaw = data['stocks'];
    final stocks = stocksRaw is List
        ? stocksRaw
              .whereType<Map<String, dynamic>>()
              .map(Stock.fromJson)
              .toList(growable: false)
        : const <Stock>[];

    return ArticleDetail(
      id: (mainArticle['ID'] ?? '').toString(),
      description: (mainArticle['DESCRIPTION'] ?? '').toString(),
      price: parsedPrice,
      pictures: pictures,
      stocks: stocks,
    );
  }
}
