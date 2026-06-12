// lib/game/level_generator.dart
import 'dart:math';
import 'tile.dart';
import 'circuit_checker.dart';

class SwapLevel {
  final int index;
  final int gridSize;
  final int sourceIndex;
  final int bulbIndex;
  final String difficulty;
  final int parMoves;
  final List<Tile> initialTiles;
  late List<Tile> tiles;

  SwapLevel({
    required this.index,
    required this.gridSize,
    required this.sourceIndex,
    required this.bulbIndex,
    required this.difficulty,
    required this.parMoves,
    required this.initialTiles,
  }) {
    tiles = initialTiles.map((t) => t.clone()).toList();
  }

  void reset() => tiles = initialTiles.map((t) => t.clone()).toList();
}

class LevelGenerator {
  static SwapLevel generate(int levelIndex) {
    int size;
    String difficulty;
    int scrambleSwaps;
    if (levelIndex < 50) {
      size = 5;
      difficulty = 'Easy';
      scrambleSwaps = 8 + levelIndex ~/ 10;
    } else if (levelIndex < 100) {
      size = 6;
      difficulty = 'Medium';
      scrambleSwaps = 14 + (levelIndex - 50) ~/ 10;
    } else {
      size = 7;
      difficulty = 'Hard';
      scrambleSwaps = 20 + (levelIndex - 100) ~/ 8;
    }

    final rng = Random(levelIndex * 5099 + levelIndex * 31 + 7);

    // Source & bulb on border, far apart
    final border = _borderCells(size)..shuffle(rng);
    final src = border[0];
    final far = border.sublist(1)
      ..sort((a, b) =>
          _manhattan(b, src, size).compareTo(_manhattan(a, src, size)));
    final bulb = far[rng.nextInt((far.length * 0.3).ceil().clamp(1, far.length))];

    // DFS path from source to bulb
    List<int> path = _dfsPath(src, bulb, size, rng) ?? _bfsPath(src, bulb, size);

    // Optionally add a decoy branch off the path for visual richness
    final masks = List<int>.filled(size * size, 0);
    for (int i = 0; i < path.length - 1; i++) {
      final d = _dir(path[i], path[i + 1], size);
      masks[path[i]] |= 1 << d;
      masks[path[i + 1]] |= 1 << ((d + 2) % 4);
    }

    final solved = List<Tile>.generate(size * size, (i) {
      if (i == src) return Tile(type: TileType.source, mask: masks[i]);
      if (i == bulb) return Tile(type: TileType.bulb, mask: masks[i]);
      if (masks[i] == 0) return Tile(type: TileType.empty, mask: 0);
      return Tile(type: TileType.wire, mask: masks[i]);
    });

    // Scramble by performing random adjacent swaps among non-locked cells
    final tiles = solved.map((t) => t.clone()).toList();
    int done = 0;
    int guard = 0;
    while (done < scrambleSwaps && guard < scrambleSwaps * 30) {
      guard++;
      final a = rng.nextInt(size * size);
      final nbrs = _neighbors(a, size);
      final b = nbrs[rng.nextInt(nbrs.length)];
      if (tiles[a].isLocked || tiles[b].isLocked) continue;
      if (tiles[a].type == TileType.empty && tiles[b].type == TileType.empty) {
        continue;
      }
      final tmp = tiles[a];
      tiles[a] = tiles[b];
      tiles[b] = tmp;
      done++;
    }

    // Ensure not accidentally solved
    final powered = CircuitChecker.check(
        tiles: tiles, gridSize: size, sourceIndex: src);
    if (powered.contains(bulb)) {
      // one extra disruptive swap on a wire tile
      for (int a = 0; a < size * size; a++) {
        if (tiles[a].type != TileType.wire) continue;
        for (final b in _neighbors(a, size)) {
          if (tiles[b].isLocked) continue;
          final tmp = tiles[a];
          tiles[a] = tiles[b];
          tiles[b] = tmp;
          final p2 = CircuitChecker.check(
              tiles: tiles, gridSize: size, sourceIndex: src);
          if (!p2.contains(bulb)) {
            done++;
            return SwapLevel(
              index: levelIndex,
              gridSize: size,
              sourceIndex: src,
              bulbIndex: bulb,
              difficulty: difficulty,
              parMoves: done,
              initialTiles: tiles,
            );
          }
          // revert
          final tmp2 = tiles[a];
          tiles[a] = tiles[b];
          tiles[b] = tmp2;
        }
      }
    }

    return SwapLevel(
      index: levelIndex,
      gridSize: size,
      sourceIndex: src,
      bulbIndex: bulb,
      difficulty: difficulty,
      parMoves: done,
      initialTiles: tiles,
    );
  }

  // ── helpers ────────────────────────────────────────────
  static List<int> _borderCells(int s) {
    final out = <int>[];
    for (int c = 0; c < s; c++) out.add(c);
    for (int r = 1; r < s - 1; r++) {
      out.add(r * s);
      out.add(r * s + s - 1);
    }
    for (int c = 0; c < s; c++) out.add((s - 1) * s + c);
    return out;
  }

  static int _manhattan(int a, int b, int s) =>
      ((a ~/ s) - (b ~/ s)).abs() + ((a % s) - (b % s)).abs();

  static List<int> _neighbors(int i, int s) {
    final r = i ~/ s, c = i % s;
    return [
      if (r > 0) i - s,
      if (c < s - 1) i + 1,
      if (r < s - 1) i + s,
      if (c > 0) i - 1,
    ];
  }

  static int _dir(int from, int to, int s) {
    if (to == from - s) return 0;
    if (to == from + 1) return 1;
    if (to == from + s) return 2;
    return 3;
  }

  static List<int>? _dfsPath(int start, int end, int s, Random rng) {
    final path = <int>[start];
    final visited = <int>{start};
    bool dfs() {
      if (path.last == end) return true;
      final nbrs = _neighbors(path.last, s)
          .where((n) => !visited.contains(n))
          .toList()
        ..shuffle(rng);
      for (final n in nbrs) {
        visited.add(n);
        path.add(n);
        if (dfs()) return true;
        path.removeLast();
        visited.remove(n);
      }
      return false;
    }

    for (int attempt = 0; attempt < 20; attempt++) {
      path
        ..clear()
        ..add(start);
      visited
        ..clear()
        ..add(start);
      if (dfs() && path.length >= 4) return List<int>.from(path);
    }
    return null;
  }

  static List<int> _bfsPath(int start, int end, int s) {
    final prev = <int, int>{};
    final q = <int>[start];
    final vis = <int>{start};
    while (q.isNotEmpty) {
      final cur = q.removeAt(0);
      if (cur == end) break;
      for (final n in _neighbors(cur, s)) {
        if (vis.add(n)) {
          prev[n] = cur;
          q.add(n);
        }
      }
    }
    final out = <int>[];
    int? cur = end;
    while (cur != null) {
      out.insert(0, cur);
      cur = prev[cur];
    }
    return out;
  }
}
