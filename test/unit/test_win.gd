extends GutTest

## Board kazanç (is_solved) testleri (TDD §13 matrisi: Kazanç).


func _card(id: StringName) -> ColorCard:
	var c := ColorCard.new()
	c.id = id
	return c


func _tube(capacity: int, ids: Array) -> Tube:
	var t := Tube.new(capacity)
	for id in ids:
		t.push_card(_card(id))
	return t


func test_tum_tupler_cozulu_kazanc() -> void:
	var board := Board.new([
		_tube(2, [&"red", &"red"]),    # dolu + tek renk
		_tube(2, [&"blue", &"blue"]),  # dolu + tek renk
		_tube(2, []),                   # boş
	])
	assert_true(board.is_solved(), "hepsi çözülü → kazanç")


func test_karisik_tup_kazanc_degil() -> void:
	var board := Board.new([
		_tube(2, [&"red", &"blue"]),  # dolu ama karışık
		_tube(2, []),
	])
	assert_false(board.is_solved(), "karışık tüp varken kazanç yok")


func test_yarim_tup_kazanc_degil() -> void:
	var board := Board.new([
		_tube(3, [&"red", &"red"]),  # tek renk ama yarım
		_tube(3, []),
	])
	assert_false(board.is_solved(), "yarım tüp kazanç değil")


func test_hamle_ile_kazanca_ulasma() -> void:
	# tek hamleyle kazanılabilir kurulum
	var board := Board.new([
		_tube(2, [&"red"]),
		_tube(2, [&"red"]),
	])
	assert_false(board.is_solved())
	var history := MoveHistory.new(board)
	var result := history.apply(board.build_move(0, 1))
	assert_true(result.board_solved, "sonuç kazancı bildirmeli")
	assert_true(board.is_solved(), "hamle sonrası tahta çözülü")
