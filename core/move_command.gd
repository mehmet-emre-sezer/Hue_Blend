class_name MoveCommand
extends RefCounted

## "Fişli" hamle (Command — CMD-001/010): kendini uygulama VE geri alma bilgisini taşır.
## Deterministik ve minimum durum tutar (CMD-013): kaynak/hedef index, taşınan adet, renk.
## Board.build_move() tarafından üretilir; tek başına geçerlilik varsaymaz.

var _from_idx: int
var _to_idx: int
var _count: int
var _card: ColorCard


func _init(from_idx: int, to_idx: int, count: int, card: ColorCard) -> void:
	assert(count > 0, "hamle en az 1 kart taşımalı")
	_from_idx = from_idx
	_to_idx = to_idx
	_count = count
	_card = card


## Hamleyi uygular: kaynaktan hedefe _count kart taşır, sonucu döner.
func apply(board: Board) -> MoveResult:
	var source := board.tube(_from_idx)
	var dest := board.tube(_to_idx)
	for i in _count:
		dest.push_card(source.pop_card())
	return MoveResult.new(
		_from_idx, _to_idx, _count, _card,
		dest.is_solved(), board.is_solved()
	)


## Hamleyi tersine çevirir: hedeften kaynağa aynı kartları geri taşır (CMD-010).
func undo(board: Board) -> void:
	var source := board.tube(_from_idx)
	var dest := board.tube(_to_idx)
	for i in _count:
		source.push_card(dest.pop_card())


func moved_count() -> int:
	return _count
