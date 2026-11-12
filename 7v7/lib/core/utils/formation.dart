/// Diziliş, mevki ve saha koordinatı kuralları (7V7_HANDOFF.md §5.1, §2.8, §5.2-1).
library;

enum Line { gk, def, mid, att }

class Formation {
  const Formation(this.id, this.def, this.mid, this.att);
  final String id;
  final int def;
  final int mid;
  final int att;

  int count(Line l) => switch (l) {
        Line.gk => 1,
        Line.def => def,
        Line.mid => mid,
        Line.att => att,
      };

  static const all = [
    Formation('3-3', 3, 0, 3),
    Formation('3-1-2', 3, 1, 2),
    Formation('3-2-1', 3, 2, 1),
    Formation('2-3-1', 2, 3, 1),
    Formation('2-1-3', 2, 1, 3),
  ];

  static Formation? byId(String? id) {
    for (final f in all) {
      if (f.id == id) return f;
    }
    return null;
  }
}

/// Bir mevki: `id` (gk, d1..d3, m1..m3, a1..a3), çizgisi, çizgideki sırası ve
/// çizgideki toplam kişi sayısı.
class Slot {
  const Slot(this.id, this.line, this.k, this.n);
  final String id;
  final Line line;
  final int k;
  final int n;
}

/// Kaleci her zaman ilk; sonra defans, orta saha, hücum.
List<Slot> slotsOf(String? formationId) {
  final f = Formation.byId(formationId);
  if (f == null) return const [];
  final out = <Slot>[const Slot('gk', Line.gk, 1, 1)];
  for (final (p, c, line) in [
    ('d', f.def, Line.def),
    ('m', f.mid, Line.mid),
    ('a', f.att, Line.att),
  ]) {
    for (var i = 1; i <= c; i++) {
      out.add(Slot('$p$i', line, i, c));
    }
  }
  return out;
}

Slot slotInfo(String? formationId, String id) {
  for (final s in slotsOf(formationId)) {
    if (s.id == id) return s;
  }
  // Dizilişte olmayan mevki: kimlikten çıkar.
  final line = switch (id.isEmpty ? 'g' : id[0]) {
    'd' => Line.def,
    'm' => Line.mid,
    'a' => Line.att,
    _ => Line.gk,
  };
  return Slot(id, line, int.tryParse(id.substring(1)) ?? 1, 1);
}

/// Yelek numarası: kaleci 1, sonra sırasıyla 2–7.
int bibNumber(String? formationId, String slotId) {
  final list = slotsOf(formationId);
  final i = list.indexWhere((s) => s.id == slotId);
  return i < 0 ? 0 : i + 1;
}

/// Mevki adı: çizgide 1 kişi varsa numarasız ("Orta Saha"), birden fazlaysa
/// numaralı ("Defans 2"). [lineName] çizginin yerelleştirilmiş adı.
String positionName(Slot s, String Function(Line) lineName) =>
    s.n > 1 ? '${lineName(s.line)} ${s.k}' : lineName(s.line);

/// Mevki merkezinin saha içindeki yüzde koordinatı (x, y).
({double x, double y}) slotXY(String formationId, Slot s) {
  final f = Formation.byId(formationId)!;
  final lines = [Line.def, Line.mid, Line.att].where((l) => f.count(l) > 0).toList();
  final ys = lines.length == 3 ? const [67.0, 43.0, 19.0] : const [62.0, 25.0];
  final y = s.line == Line.gk ? 87.0 : ys[lines.indexOf(s.line)];
  final xs = switch (s.n) {
    1 => const [50.0],
    2 => const [30.0, 70.0],
    _ => const [17.0, 50.0, 83.0],
  };
  return (x: xs[s.k - 1], y: y);
}

/// Diziliş değişimi sonucu (§5.2-1).
class FormationChange<P> {
  const FormationChange(this.players, this.moved, this.inviteMoves);

  /// Yeni dizilişteki oyuncular (mevki → oyuncu).
  final Map<String, P> players;

  /// Taşınanlar: (oyuncu ya da davet, yeni mevki). Oyuncular önce, sonra davetler.
  final List<(Object, Slot)> moved;

  /// Bekleyen davetlerin taşınması: eski mevki → yeni mevki.
  final Map<String, String> inviteMoves;
}

/// Yeni dizilişte olmayan mevkilerdeki oyuncular ve bekleyen davetler, yeni
/// dizilişin boş mevkilerine sırayla taşınır. Bekleyen davetin tuttuğu
/// mevkiye oyuncu taşınmaz. Yer kalmazsa oyuncu düşer (7 kişide olmaz).
FormationChange<P> changeFormation<P>({
  required String? from,
  required String to,
  required Map<String, P> players,
  required Map<String, Object> pendingBySlot,
}) {
  final slots = slotsOf(to);
  final ids = slots.map((s) => s.id).toSet();
  final next = <String, P>{};
  final moved = <(Object, Slot)>[];
  final inviteMoves = <String, String>{};
  final held = pendingBySlot.keys.where(ids.contains).toSet();
  for (final s in slots) {
    final p = players[s.id];
    if (p != null) next[s.id] = p;
  }
  Slot? free() {
    for (final s in slots) {
      if (!next.containsKey(s.id) && !held.contains(s.id)) return s;
    }
    return null;
  }

  final order = slotsOf(from).map((s) => s.id).toList();
  int rank(String id) {
    final i = order.indexOf(id);
    return i < 0 ? 99 : i;
  }

  final displaced = players.keys.where((k) => !ids.contains(k)).toList()
    ..sort((a, b) => rank(a).compareTo(rank(b)));
  for (final k in displaced) {
    final open = free();
    if (open == null) continue;
    next[open.id] = players[k] as P;
    moved.add((players[k] as Object, open));
  }
  for (final e in pendingBySlot.entries.where((e) => !ids.contains(e.key))) {
    final open = free();
    if (open == null) continue;
    held.add(open.id);
    inviteMoves[e.key] = open.id;
    moved.add((e.value, open));
  }
  return FormationChange(next, moved, inviteMoves);
}
