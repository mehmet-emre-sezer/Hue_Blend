class_name MoveResult
extends RefCounted

## Uygulanmış bir hamlenin sonucu (değer nesnesi / DTO).
## Sunum katmanı bunu okuyup animasyon/ses/kazanç tetikler (TDD §4, K1).
## Salt-veri taşır; domain davranışı içermez.

var from_idx: int
var to_idx: int
var moved_count: int
var color: ColorCard        # dökülen renk (animasyon için)
var result_color: ColorCard # karışım sonucu oluşan renk (keşif için)
var dest_tube_solved: bool
var board_solved: bool
var mixed: bool  # bu hamlede karışım oldu mu (görsel geri bildirim için)


func _init(
	from_idx: int,
	to_idx: int,
	moved_count: int,
	color: ColorCard,
	result_color: ColorCard,
	dest_tube_solved: bool,
	board_solved: bool,
	mixed: bool
) -> void:
	self.from_idx = from_idx
	self.to_idx = to_idx
	self.moved_count = moved_count
	self.color = color
	self.result_color = result_color
	self.dest_tube_solved = dest_tube_solved
	self.board_solved = board_solved
	self.mixed = mixed
