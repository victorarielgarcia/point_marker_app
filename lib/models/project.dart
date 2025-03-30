class Project {
  final String id;
  final String name;
  final String companyId;

  Project({
    required this.id,
    required this.name,
    required this.companyId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'companyId': companyId,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      companyId: json['companyId'],
    );
  }
}
