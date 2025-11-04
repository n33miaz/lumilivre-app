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
  late List<Book> _displayedBooks;

  @override
  void initState() {
    super.initState();
    _displayedBooks = widget.books.take(6).toList();
  }

  void _navigateToCategory(BuildContext context, String categoryName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryBooksScreen(categoryName: categoryName),
      ),
    );
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
            scrollDirection: Axis.horizontal,
            itemCount: _displayedBooks.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final book = _displayedBooks[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: BookCard(book: book),
              );
            },
          ),
        ),
      ],
    );
  }
}
