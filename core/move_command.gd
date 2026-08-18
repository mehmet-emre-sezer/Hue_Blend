class_name MoveCommand
extends RefCounted

## "Fişli" hamle (Command — CMD-001/010): uygulama VE geri alma bilgisini taşır.
## Snapshot-tabanlı (CMD-013 istisnası): karışım hamlelerinin geri alınması, minimum-delta
## yerine etkilenen iki tüpün önceki/sonraki içeriğiyle güvenle yapılır. Deterministik.
## Board.build_move() tarafından Pour hesabından üretilir.

var _from_idx: int
var _to_idx: int
var _source_before: Array
var _dest_before: Array
var _source_after: Array
var _dest_after: Array
var _moved_count: int
var _poured_color: ColorCard


func _init(
	from_idx: int, to_idx: int,
	source_before: Array, dest_before: Array,
	source_after: Array, dest_after: Array,
	moved_count: int, poured_color: ColorCard
) -> void:
	assert(moved_count > 0, "hamle en az 1 kart taşımalı")
	_from_idx = from_idx
	_to_idx = to_idx
	_source_before = source_before
	_dest_before = dest_before
	_source_after = source_after
	_dest_after = dest_after
	_moved_count = moved_count
	_poured_color = poured_color


func apply(board: Board) -> MoveResult:
	board.tube(_from_idx).replace(_source_after)
	board.tube(_to_idx).replace(_dest_after)
	var dest_solved := board.tube(_to_idx).is_solved()
	return MoveResult.new(
		_from_idx, _to_idx, _moved_count, _poured_color,
		dest_solved, board.is_solved()
	)


func undo(board: Board) -> void:
	board.tube(_from_idx).replace(_source_before)
	board.tube(_to_idx).replace(_dest_before)


func moved_count() -> int:
	return _moved_count


func from_index() -> int:
	return _from_idx


func to_index() -> int:
	return _to_idx


## Animasyonun uçurduğu renk = dökülen (kaynak) renk.
func color() -> ColorCard:
	return _poured_color
