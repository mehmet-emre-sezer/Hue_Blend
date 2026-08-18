class_name LevelLoader
extends RefCounted

## LevelData + ColorRegistry → çalışır Board kurar.
## Doğrulanmış seviye bekler; yine de bilinmeyen id'ye karşı dev-guard (ERR-004).

func load_board(level: LevelData, colors: ColorRegistry) -> Board:
	var tubes: Array[Tube] = []
	for tube_ids in level.tubes:
		var tube := Tube.new(level.capacity)
		for id_str in tube_ids:
			var card := colors.get_card(StringName(id_str))
			assert(card != null, "Bilinmeyen renk id yüklenemez: %s" % id_str)
			tube.push_card(card)
		tubes.append(tube)
	return Board.new(tubes)
