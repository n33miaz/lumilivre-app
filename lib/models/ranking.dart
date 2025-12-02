class RankingItem {
  final String matricula;
  final String nome;
  final int emprestimosCount;

  RankingItem({
    required this.matricula,
    required this.nome,
    required this.emprestimosCount,
  });

  factory RankingItem.fromJson(Map<String, dynamic> json) {
    return RankingItem(
      matricula: json['matricula'] ?? '',
      nome: json['nome'] ?? 'Aluno',
      emprestimosCount: json['emprestimosCount'] ?? 0,
    );
  }
}

class FilterItem {
  final int id;
  final String nome;

  FilterItem({required this.id, required this.nome});

  factory FilterItem.fromJson(Map<String, dynamic> json) {
    return FilterItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      nome: json['nome'] ?? '',
    );
  }
}
