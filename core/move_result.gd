class_name MoveResult
extends RefCounted

## Uygulanmış bir hamlenin sonucu (değer nesnesi / DTO).
## Sunum katmanı bunu okuyup animasyon/ses/kazanç tetikler (TDD §4, K1).
## Salt-veri taşır; domain davranışı içermez.

var from_idx: int
var to_idx: int
var moved_count: int
var color: ColorCard
var dest_tube_solved: bool
var board_solved: bool


func _init(
	from_idx: int,
	to_idx: int,
	moved_count: int,
	color: ColorCard,
	dest_tube_solved: bool,
	board_solved: bool
) -> void:
	self.from_idx = from_idx
	self.to_idx = to_idx
	self.moved_count = moved_count
	self.color = color
	self.dest_tube_solved = dest_tube_solved
	self.board_solved = board_solved
