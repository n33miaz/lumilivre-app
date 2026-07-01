class RankingItem {
  final String registrationNumber;
  final String fullName;
  final int loanCount;

  RankingItem({
    required this.registrationNumber,
    required this.fullName,
    required this.loanCount,
  });

  factory RankingItem.fromJson(Map<String, dynamic> json) {
    return RankingItem(
      registrationNumber: json['registrationNumber'] ?? json['matricula'] ?? '',
      fullName: json['fullName'] ?? json['nome'] ?? 'Leitor',
      loanCount: json['loanCount'] ?? json['emprestimosCount'] ?? 0,
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
      nome: json['nome'] ?? json['name'] ?? '',
    );
  }
}
