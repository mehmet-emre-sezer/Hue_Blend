class_name Board
extends RefCounted

## Tahta: tüplerin sahibi ve TEK otoritatif mutable durum (COMP-005, X-008).
## Saf mantık — Godot düğümü bilmez, headless test edilebilir (TDD §3).

var _tubes: Array[Tube] = []
var _mix_rules: MixRules  # null → karışım yok (Faz 1 davranışı)


func _init(tubes: Array, mix_rules: MixRules = null) -> void:
	assert(not tubes.is_empty(), "board en az bir tüp ister")
	for tube in tubes:
		_tubes.append(tube)
	_mix_rules = mix_rules


func tube_count() -> int:
	return _tubes.size()


func tube(index: int) -> Tube:
	return _tubes[index]


## Kaynaktan hedefe GEÇERLİ bir hamle kurar; geçersizse null. MUTASYON YOK (saf).
## Saf dökme (aynı renk/boş) veya karışım (uyumlu temel renkler) — kural Pour'da.
func build_move(from_idx: int, to_idx: int) -> MoveCommand:
	if from_idx == to_idx:
		return null
	if not _is_valid_index(from_idx) or not _is_valid_index(to_idx):
		return null
	var source := _tubes[from_idx]
	var dest := _tubes[to_idx]
	var outcome := Pour.compute(source.cards_snapshot(), dest.cards_snapshot(), dest.capacity(), _mix_rules)
	if outcome == null:
		return null
	var mixed := not outcome.poured_color.same_as(outcome.result_color)
	return MoveCommand.new(
		from_idx, to_idx,
		source.cards_snapshot(), dest.cards_snapshot(),
		outcome.source_after, outcome.dest_after,
		outcome.moved_count, outcome.poured_color, mixed
	)


## Tahta çözülmüş mü: her tüp çözülü (boş VEYA dolu+tek renk).
func is_solved() -> bool:
	for tube in _tubes:
		if not tube.is_solved():
			return false
	return true


func _is_valid_index(index: int) -> bool:
	return index >= 0 and index < _tubes.size()
