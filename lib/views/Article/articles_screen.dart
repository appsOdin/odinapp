import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/article_model.dart';
import '../../services/article_service.dart';
import '../../theme/app_theme.dart';
import 'article_detail_screen.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  static const int _itemsPerPage = 20;

  final ArticleService _articleService = ArticleService();
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '₡',
    decimalDigits: 2,
    customPattern: '¤ #,##0.00',
  );

  late final Future<List<Article>> _articlesFuture;
  String _searchQuery = '';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _articlesFuture = _articleService.getAllArticles(context);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _currentPage = 1;
    });
  }

  List<Article> _filterArticles(List<Article> articles) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return articles;
    }

    return articles
        .where((article) {
          return article.id.toLowerCase().contains(query) ||
              article.description.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Artículos', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar artículo...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Article>>(
                future: _articlesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error al cargar artículos: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final articles = snapshot.data ?? const <Article>[];
                  final filteredArticles = _filterArticles(articles);

                  if (filteredArticles.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron artículos.'),
                    );
                  }

                  final totalPages = (filteredArticles.length / _itemsPerPage)
                      .ceil();
                  final safeCurrentPage = _currentPage.clamp(1, totalPages);
                  if (safeCurrentPage != _currentPage) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _currentPage = safeCurrentPage);
                      }
                    });
                  }

                  final startIndex = (safeCurrentPage - 1) * _itemsPerPage;
                  final endIndex = (startIndex + _itemsPerPage).clamp(
                    0,
                    filteredArticles.length,
                  );
                  final pageItems = filteredArticles.sublist(
                    startIndex,
                    endIndex,
                  );

                  return Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF5F5F5),
                                  border: Border(
                                    bottom: BorderSide(color: Colors.black12),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'ARTICULO',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        'DESCRIPCIÓN',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'PRECIO',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ACCIONES',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: pageItems.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final article = pageItems[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(article.id),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              article.description,
                                              softWrap: true,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              _currencyFormat.format(
                                                article.price,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.visibility,
                                                ),
                                                tooltip: 'Ver detalle',
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute<void>(
                                                      builder: (_) =>
                                                          const ArticleDetailScreen(),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: safeCurrentPage > 1
                                ? () {
                                    setState(() => _currentPage--);
                                  }
                                : null,
                            child: const Text('Anterior'),
                          ),
                          const SizedBox(width: 12),
                          Text('Página $safeCurrentPage de $totalPages'),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: safeCurrentPage < totalPages
                                ? () {
                                    setState(() => _currentPage++);
                                  }
                                : null,
                            child: const Text('Siguiente'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
