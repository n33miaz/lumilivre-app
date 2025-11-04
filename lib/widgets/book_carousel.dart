import 'package:flutter/material.dart';
import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/screens/category_books.dart';
import 'package:lumilivre/widgets/book_card.dart';

class BookCarousel extends StatefulWidget {
  final String title;
  final List<Book> books;

  const BookCarousel({super.key, required this.title, required this.books});

  @override
  State<BookCarousel> createState() => _BookCarouselState();
}

class _BookCarouselState extends State<BookCarousel> {
  final PageController _pageController = PageController(
    viewportFraction: 0.4,
  ); 
  late List<Book> _displayedBooks;
  bool _hasMoreHorizontal = true;

  @override
  void initState() {
    super.initState();
    _displayedBooks = widget.books.take(6).toList();
    _hasMoreHorizontal = widget.books.length > 6;

    _pageController.addListener(() {
      if (_pageController.position.pixels >=
          _pageController.position.maxScrollExtent - 200) {
        _loadMoreBooks();
      }
    });
  }

  void _loadMoreBooks() {
    if (!_hasMoreHorizontal) return;

    setState(() {
      final nextEnd = (_displayedBooks.length + 6).clamp(
        0,
        widget.books.length,
      );
      _displayedBooks = widget.books.sublist(0, nextEnd);
      if (_displayedBooks.length == widget.books.length) {
        _hasMoreHorizontal = false;
      }
    });
  }

  void _navigateToCategory(BuildContext context, String categoryName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryBooksScreen(categoryName: categoryName),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _navigateToCategory(context, widget.title),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: ListView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            itemCount: _displayedBooks.length + (_hasMoreHorizontal ? 1 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              if (index == _displayedBooks.length) {
                return const Center(
                  child: SizedBox(
                    width: 40,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final book = _displayedBooks[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: BookCard(book: book),
              );
            },
          ),
        ),
      ],
    );
  }
}
