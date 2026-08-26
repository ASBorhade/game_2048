class Tile {
  final int id;
  int value;
  int row;
  int col;
  int? previousRow;
  int? previousCol;
  int? mergedIntoId;
  bool isNew;
  bool isMerged;

  Tile({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
    this.previousRow,
    this.previousCol,
    this.mergedIntoId,
    this.isNew = false,
    this.isMerged = false,
  });

  Tile copyWith({
    int? id,
    int? value,
    int? row,
    int? col,
    int? previousRow,
    int? previousCol,
    int? mergedIntoId,
    bool? isNew,
    bool? isMerged,
  }) {
    return Tile(
      id: id ?? this.id,
      value: value ?? this.value,
      row: row ?? this.row,
      col: col ?? this.col,
      previousRow: previousRow ?? this.previousRow,
      previousCol: previousCol ?? this.previousCol,
      mergedIntoId: mergedIntoId ?? this.mergedIntoId,
      isNew: isNew ?? this.isNew,
      isMerged: isMerged ?? this.isMerged,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'row': row,
      'col': col,
    };
  }

  factory Tile.fromJson(Map<String, dynamic> json) {
    return Tile(
      id: json['id'] as int,
      value: json['value'] as int,
      row: json['row'] as int,
      col: json['col'] as int,
      isNew: false,
      isMerged: false,
    );
  }
}
