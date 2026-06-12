// lib/game/game_state.dart
import 'package:flutter/material.dart';
import 'tile.dart';
import 'level_generator.dart';
import 'circuit_checker.dart';
import '../utils/preferences.dart';
import '../utils/audio_manager.dart';

class GameState extends ChangeNotifier {
  late SwapLevel level;
  int moves = 0;
  bool isComplete = false;
  int stars = 0;
  int currentLevelIndex = 0;
  bool initialized = false;
  int? selectedIndex; // tile awaiting a swap partner

  void loadLevel(int index) {
    currentLevelIndex = index;
    level = LevelGenerator.generate(index);
    moves = 0;
    isComplete = false;
    stars = 0;
    selectedIndex = null;
    initialized = true;
    _updatePowered();
    notifyListeners();
  }

  bool _adjacent(int a, int b) {
    final s = level.gridSize;
    final dr = (a ~/ s - b ~/ s).abs();
    final dc = (a % s - b % s).abs();
    return dr + dc == 1;
  }

  void tapTile(int index) {
    if (isComplete) return;
    final t = level.tiles[index];
    if (t.isLocked) return;

    if (selectedIndex == null) {
      if (t.type == TileType.empty) return; // can't pick up empty space
      selectedIndex = index;
      notifyListeners();
      return;
    }

    if (selectedIndex == index) {
      selectedIndex = null; // deselect
      notifyListeners();
      return;
    }

    if (_adjacent(selectedIndex!, index)) {
      final a = selectedIndex!;
      final tmp = level.tiles[a];
      level.tiles[a] = level.tiles[index];
      level.tiles[index] = tmp;
      selectedIndex = null;
      moves++;
      AudioManager.instance.playSwap();
      _updatePowered();
      notifyListeners();
    } else {
      // re-select if it's a movable tile
      selectedIndex = t.type == TileType.empty ? null : index;
      notifyListeners();
    }
  }

  void _updatePowered() {
    final powered = CircuitChecker.check(
      tiles: level.tiles,
      gridSize: level.gridSize,
      sourceIndex: level.sourceIndex,
    );
    for (int i = 0; i < level.tiles.length; i++) {
      level.tiles[i].isPowered = powered.contains(i);
    }
    if (powered.contains(level.bulbIndex) && !isComplete) {
      isComplete = true;
      stars = _calcStars();
      AudioManager.instance.playComplete();
      Preferences.instance.saveLevelResult(currentLevelIndex, stars);
    }
  }

  int _calcStars() {
    if (moves <= level.parMoves) return 3;
    if (moves <= level.parMoves * 2) return 2;
    return 1;
  }

  void restartLevel() {
    level.reset();
    moves = 0;
    isComplete = false;
    stars = 0;
    selectedIndex = null;
    _updatePowered();
    notifyListeners();
  }

  void nextLevel() {
    if (currentLevelIndex < 149) loadLevel(currentLevelIndex + 1);
  }
}
