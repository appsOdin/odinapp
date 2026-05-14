import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/article_detail_model.dart';
import '../../services/article_detail_service.dart';
import '../../theme/app_theme.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final ArticleDetailService _detailService = ArticleDetailService();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '₡',
    decimalDigits: 2,
    customPattern: '¤ #,##0.00',
  );
  int _currentImagePage = 0;

  late Future<ArticleDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _detailService.getArticleDetail(
      articleId: widget.articleId,
    );
  }

  void _retry() {
    setState(() {
      _detailFuture = _detailService.getArticleDetail(
        articleId: widget.articleId,
      );
    });
  }

  Uint8List? _decodeBase64Image(String rawPicture) {
    final value = rawPicture.trim();
    if (value.isEmpty || value.toLowerCase() == 'null') {
      return null;
    }

    try {
      // Soporta tanto base64 puro como data URI (data:image/...;base64,xxx)
      final base64Part = value.contains(',') ? value.split(',').last : value;
      final compact = base64Part.replaceAll(RegExp(r'\s+'), '');
      final remainder = compact.length % 4;
      final normalized = remainder == 0
          ? compact
          : '$compact${'=' * (4 - remainder)}';

      try {
        return base64Decode(normalized);
      } catch (_) {
        // Algunos backends devuelven variante URL-safe con '-' y '_'.
        return base64Url.decode(normalized);
      }
    } catch (_) {
      return null;
    }
  }

  Widget _buildImageBox({required Uint8List? imageBytes}) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageBytes == null
            ? const Center(child: Text('Este artículo no tiene imagen'))
            : Image.memory(imageBytes, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildImagesSection(List<Picture> pictures) {
    final images = pictures
        .where((picture) => picture.hasImage)
        .map((picture) => _decodeBase64Image(picture.picture))
        .whereType<Uint8List>()
        .toList(growable: false);

    if (images.isEmpty) {
      return _buildImageBox(imageBytes: null);
    }

    if (images.length == 1) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  _FullscreenImageViewer(images: images, initialIndex: 0),
            ),
          );
        },
        child: _buildImageBox(imageBytes: images.first),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => _currentImagePage = index);
            },
            itemBuilder: (context, index) {
              final imageBytes = images[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _FullscreenImageViewer(
                        images: images,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: _buildImageBox(imageBytes: imageBytes),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text('Imagen ${_currentImagePage + 1} de ${images.length}'),
      ],
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Detalle del artículo',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<ArticleDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No pudimos cargar el detalle del artículo.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _retry,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final detail = snapshot.data;
          if (detail == null) {
            return Center(
              child: ElevatedButton(
                onPressed: _retry,
                child: const Text('Reintentar'),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagesSection(detail.pictures),
                const SizedBox(height: 16),
                _buildSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información del artículo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Código: ${detail.id}'),
                      const SizedBox(height: 8),
                      Text(
                        'Descripción: ${detail.description}',
                        softWrap: true,
                      ),
                      const SizedBox(height: 8),
                      Text('Precio: ${_currencyFormat.format(detail.price)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Disponibilidad en bodegas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (detail.stocks.isEmpty)
                        const Text('No hay inventario disponible')
                      else
                        ...detail.stocks.map((stock) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(stock.name, softWrap: true),
                                ),
                                const SizedBox(width: 12),
                                Text(stock.available.toStringAsFixed(2)),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FullscreenImageViewer extends StatefulWidget {
  final List<Uint8List> images;
  final int initialIndex;

  const _FullscreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1}/${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: Image.memory(widget.images[index], fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}
