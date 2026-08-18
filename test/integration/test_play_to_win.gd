extends GutTest

## KRİTİK AKIŞ integration testi (TDD §13): seviye doğrula → yükle → oyna → kazan.
## Tüm çekirdek+içerik modüllerinin birlikte doğru çalıştığını uçtan uca kanıtlar.


func _registry() -> ColorRegistry:
	var reg := ColorRegistry.new()
	for id in [&"red", &"blue"]:
		var card := ColorCard.new()
		card.id = id
		reg.register(card)
	return reg


func _level(capacity: int, tube_arrays: Array) -> LevelData:
	var level := LevelData.new()
	level.capacity = capacity
	var tubes: Array[PackedStringArray] = []
	for arr in tube_arrays:
		tubes.append(PackedStringArray(arr))
	level.tubes = tubes
	return level


func _snapshot(board: Board) -> Array:
	var out := []
	for i in board.tube_count():
		var ids := []
		for card in board.tube(i).cards_snapshot():
			ids.append(card.id)
		out.append(ids)
	return out


func _play(board: Board, history: MoveHistory, from_idx: int, to_idx: int) -> MoveResult:
	var move := board.build_move(from_idx, to_idx)
	assert_not_null(move, "hamle geçerli olmalı: %d→%d" % [from_idx, to_idx])
	return history.apply(move)


func test_seviye_yukle_oyna_kazan() -> void:
	var colors := _registry()
	# kapasite 2; red x2, blue x2. 3 hamlelik çözüm var.
	var level := _level(2, [["red", "blue"], ["blue", "red"], []])

	# 1) doğrula
	assert_eq(LevelValidator.new().validate(level, colors).size(), 0, "seviye geçerli olmalı")

	# 2) yükle
	var board := LevelLoader.new().load_board(level, colors)
	var history := MoveHistory.new(board)
	assert_false(board.is_solved(), "başlangıçta çözülü değil")

	# 3) oyna: red→boş, blue→blue, red→red
	_play(board, history, 1, 2)
	_play(board, history, 0, 1)
	var last := _play(board, history, 0, 2)

	# 4) kazanç
	assert_true(last.board_solved, "son hamle kazancı bildirmeli")
	assert_true(board.is_solved(), "tahta çözülmüş olmalı")
	assert_eq(history.move_count(), 3)


func test_kazanctan_sonra_hepsini_geri_al() -> void:
	var colors := _registry()
	var level := _level(2, [["red", "blue"], ["blue", "red"], []])
	var board := LevelLoader.new().load_board(level, colors)
	var start := _snapshot(board)

	var history := MoveHistory.new(board)
	_play(board, history, 1, 2)
	_play(board, history, 0, 1)
	_play(board, history, 0, 2)
	assert_true(board.is_solved())

	# tüm hamleleri geri al → başlangıç durumu
	while history.can_undo():
		history.undo_last()
	assert_eq(_snapshot(board), start, "tüm undo'lar başlangıca dönmeli")
