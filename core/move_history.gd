class_name MoveHistory
extends RefCounted

## Uygulanan hamlelerin yığını + undo orkestrasyonu (CMD-011: geçmiş, UI'dan ayrık).
## Bir Board'a bağlıdır; hamleleri uygular, kaydeder, geri alır.

var _board: Board
var _stack: Array[MoveCommand] = []


func _init(board: Board) -> void:
	_board = board


## Hamleyi uygular, geçmişe ekler, sonucu döner.
func apply(move: MoveCommand) -> MoveResult:
	var result := move.apply(_board)
	_stack.append(move)
	return result


func can_undo() -> bool:
	return not _stack.is_empty()


## Son hamleyi çıkarmadan döner (undo animasyonu bilgisi için).
func peek() -> MoveCommand:
	assert(can_undo(), "peek için hamle yok")
	return _stack[-1]


## Son hamleyi geri alır.
func undo_last() -> void:
	assert(can_undo(), "geri alınacak hamle yok")
	var move: MoveCommand = _stack.pop_back()
	move.undo(_board)


func move_count() -> int:
	return _stack.size()
