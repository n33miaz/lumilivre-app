import '../models/book.dart';

const mock = 'images/mock.png';

final List<Book> mockBooks = [
  Book(
    id: '1',
    title: 'A Hipótese do Amor',
    author: 'Ali Hazelwood',
    imageUrl: 'images/mock.png',
  ),
  Book(
    id: '2',
    title: 'A Última Músicaaaaaaaaaaaaaaa',
    author: 'Nicholas Sparks',
    imageUrl: mock,
  ),
  Book(
    id: '3',
    title: 'Ventos de Amor',
    author: 'Silvia Spadoni',
    imageUrl: mock,
  ),
  Book(
    id: '4',
    title: 'É Assim que Acaba',
    author: 'Colleen Hoover',
    imageUrl: mock,
  ),
  Book(
    id: '5',
    title: 'O Homem de Giz',
    author: 'C. J. Tudor',
    imageUrl: mock,
  ),
];
