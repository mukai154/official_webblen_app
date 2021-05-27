class SearchResult {
  String? id;
  String? type;
  String? name;
  String? additionalData;

  SearchResult({
    this.id,
    this.type,
    this.name,
    this.additionalData,
  });

  SearchResult.fromMap(Map<String, dynamic> data)
      : this(
          id: data['id'],
          type: data['type'],
          name: data['name'],
          additionalData: data['additionalData'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'type': this.type,
        'name': this.name,
        'additionalData': this.additionalData,
      };
}
