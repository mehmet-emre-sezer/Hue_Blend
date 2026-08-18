extends GutTest

## Hamle uygulama + undo round-trip testleri (TDD §13 matrisi: Undo, CMD-010).


func _card(id: StringName) -> ColorCard:
	var c := ColorCard.new()
	c.id = id
	return c


func _tube(capacity: int, ids: Array) -> Tube:
	var t := Tube.new(capacity)
	for id in ids:
		t.push_card(_card(id))
	return t


## Tahtanın renk-id anlık görüntüsü (karşılaştırma için).
func _snapshot(board: Board) -> Array:
	var out := []
	for i in board.tube_count():
		var ids := []
		for card in board.tube(i).cards_snapshot():
			ids.append(card.id)
		out.append(ids)
	return out


func test_apply_kartlari_tasir() -> void:
	var board := Board.new([
		_tube(4, [&"red", &"red", &"blue"]),  # üst = blue (grup 1)
		_tube(4, [&"blue"]),
	])
	var history := MoveHistory.new(board)
	var result := history.apply(board.build_move(0, 1))
	assert_eq(result.moved_count, 1)
	assert_eq(board.tube(0).size(), 2)
	assert_eq(board.tube(1).size(), 2)


func test_undo_round_trip() -> void:
	var board := Board.new([
		_tube(4, [&"red", &"red", &"blue"]),
		_tube(4, [&"blue"]),
		_tube(4, []),
	])
	var before := _snapshot(board)
	var history := MoveHistory.new(board)
	history.apply(board.build_move(0, 1))
	assert_true(history.can_undo())
	history.undo_last()
	assert_eq(_snapshot(board), before, "undo tam olarak eski duruma dönmeli")
	assert_false(history.can_undo(), "geçmiş boşaldı")


func test_undo_coklu_kart() -> void:
	var board := Board.new([
		_tube(4, [&"blue", &"red", &"red"]),  # üst grup = 2 kırmızı
		_tube(4, [&"red"]),
	])
	var before := _snapshot(board)
	var history := MoveHistory.new(board)
	var result := history.apply(board.build_move(0, 1))
	assert_eq(result.moved_count, 2, "üstteki 2 kırmızı birlikte taşınır")
	history.undo_last()
	assert_eq(_snapshot(board), before, "çoklu-kart undo da tam dönmeli")


func test_move_count_takibi() -> void:
	var board := Board.new([_tube(3, [&"red"]), _tube(3, []), _tube(3, [])])
	var history := MoveHistory.new(board)
	assert_eq(history.move_count(), 0)
	history.apply(board.build_move(0, 1))
	assert_eq(history.move_count(), 1)
	history.undo_last()
	assert_eq(history.move_count(), 0)
