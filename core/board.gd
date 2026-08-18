class_name Board
extends RefCounted

## Tahta: tüplerin sahibi ve TEK otoritatif mutable durum (COMP-005, X-008).
## Saf mantık — Godot düğümü bilmez, headless test edilebilir (TDD §3).

var _tubes: Array[Tube] = []


func _init(tubes: Array) -> void:
	assert(not tubes.is_empty(), "board en az bir tüp ister")
	for tube in tubes:
		_tubes.append(tube)


func tube_count() -> int:
	return _tubes.size()


func tube(index: int) -> Tube:
	return _tubes[index]


## Kaynaktan hedefe GEÇERLİ bir hamle kurar; geçersizse null. MUTASYON YOK (saf).
## Su-ayırma kuralı: üst-bitişik aynı-renk grubu, üstü uyan/boş + yer olan tüpe;
## taşınan adet = min(kaynak üst-grup, hedef boş alan).
func build_move(from_idx: int, to_idx: int) -> MoveCommand:
	if from_idx == to_idx:
		return null
	if not _is_valid_index(from_idx) or not _is_valid_index(to_idx):
		return null
	var source := _tubes[from_idx]
	var dest := _tubes[to_idx]
	if source.is_empty():
		return null
	var card := source.top()
	if not dest.can_accept(card):
		return null
	var count := mini(source.top_run_count(), dest.free_space())
	if count <= 0:
		return null
	return MoveCommand.new(from_idx, to_idx, count, card)


## Tahta çözülmüş mü: her tüp çözülü (boş VEYA dolu+tek renk).
func is_solved() -> bool:
	for tube in _tubes:
		if not tube.is_solved():
			return false
	return true


func _is_valid_index(index: int) -> bool:
	return index >= 0 and index < _tubes.size()
