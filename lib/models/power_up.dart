enum PowerUpType {
  undo('Undo', 'Revert 1 move', 50),
  hammer('Hammer', 'Smash any tile', 100),
  shuffle('Shuffle', 'Rearrange all tiles', 80),
  hint('AI Hint', 'Suggest best move', 40);

  final String title;
  final String description;
  final int coinCost;

  const PowerUpType(this.title, this.description, this.coinCost);
}

class PowerUpInventory {
  static const int maxCapacity = 4;

  int undoCount;
  int hammerCount;
  int shuffleCount;
  int hintCount;

  PowerUpInventory({
    this.undoCount = 2,
    this.hammerCount = 1,
    this.shuffleCount = 1,
    this.hintCount = 2,
  });

  int getCount(PowerUpType type) {
    switch (type) {
      case PowerUpType.undo:
        return undoCount;
      case PowerUpType.hammer:
        return hammerCount;
      case PowerUpType.shuffle:
        return shuffleCount;
      case PowerUpType.hint:
        return hintCount;
    }
  }

  bool isFull(PowerUpType type) => getCount(type) >= maxCapacity;

  void add(PowerUpType type, int amount) {
    switch (type) {
      case PowerUpType.undo:
        undoCount = (undoCount + amount).clamp(0, maxCapacity);
        break;
      case PowerUpType.hammer:
        hammerCount = (hammerCount + amount).clamp(0, maxCapacity);
        break;
      case PowerUpType.shuffle:
        shuffleCount = (shuffleCount + amount).clamp(0, maxCapacity);
        break;
      case PowerUpType.hint:
        hintCount = (hintCount + amount).clamp(0, maxCapacity);
        break;
    }
  }

  bool consume(PowerUpType type) {
    switch (type) {
      case PowerUpType.undo:
        if (undoCount > 0) {
          undoCount--;
          return true;
        }
        return false;
      case PowerUpType.hammer:
        if (hammerCount > 0) {
          hammerCount--;
          return true;
        }
        return false;
      case PowerUpType.shuffle:
        if (shuffleCount > 0) {
          shuffleCount--;
          return true;
        }
        return false;
      case PowerUpType.hint:
        if (hintCount > 0) {
          hintCount--;
          return true;
        }
        return false;
    }
  }

  Map<String, dynamic> toJson() => {
        'undoCount': undoCount,
        'hammerCount': hammerCount,
        'shuffleCount': shuffleCount,
        'hintCount': hintCount,
      };

  factory PowerUpInventory.fromJson(Map<String, dynamic> json) {
    return PowerUpInventory(
      undoCount: (json['undoCount'] as int? ?? 2).clamp(0, maxCapacity),
      hammerCount: (json['hammerCount'] as int? ?? 1).clamp(0, maxCapacity),
      shuffleCount: (json['shuffleCount'] as int? ?? 1).clamp(0, maxCapacity),
      hintCount: (json['hintCount'] as int? ?? 2).clamp(0, maxCapacity),
    );
  }
}
