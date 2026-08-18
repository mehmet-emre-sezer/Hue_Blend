extends GutTest

## Board.build_move geçerlilik testleri (TDD §13 matrisi: try_build_move geçerli/geçersiz).


func _card(id: StringName) -> ColorCard:
	var c := ColorCard.new()
	c.id = id
	return c


func _tube(capacity: int, ids: Array) -> Tube:
	var t := Tube.new(capacity)
	for id in ids:
		t.push_card(_card(id))
	return t


func test_build_move_gecerli() -> void:
	var board := Board.new([
		_tube(3, [&"red"]),
		_tube(3, []),
	])
	var move := board.build_move(0, 1)
	assert_not_null(move, "boş hedefe geçerli hamle")
	assert_eq(move.moved_count(), 1)


func test_build_move_ayni_tup_null() -> void:
	var board := Board.new([_tube(3, [&"red"]), _tube(3, [])])
	assert_null(board.build_move(0, 0), "aynı tüp geçersiz")


func test_build_move_bos_kaynak_null() -> void:
	var board := Board.new([_tube(3, []), _tube(3, [&"red"])])
	assert_null(board.build_move(0, 1), "boş kaynak geçersiz")


func test_build_move_dolu_hedef_null() -> void:
	var board := Board.new([
		_tube(2, [&"blue"]),
		_tube(2, [&"blue", &"blue"]),  # dolu
	])
	assert_null(board.build_move(0, 1), "dolu hedef geçersiz")


func test_build_move_eslesmeyen_renk_null() -> void:
	var board := Board.new([
		_tube(2, [&"red"]),
		_tube(2, [&"blue"]),
	])
	assert_null(board.build_move(0, 1), "eşleşmeyen üst renk geçersiz")


func test_build_move_gecersiz_index_null() -> void:
	var board := Board.new([_tube(2, [&"red"]), _tube(2, [])])
	assert_null(board.build_move(0, 5), "aralık dışı index geçersiz")
	assert_null(board.build_move(-1, 0), "negatif index geçersiz")


func test_build_move_grup_ve_bosluk_ile_sinirli() -> void:
	# kaynak üstünde 3 kırmızı, hedefte yalnız 2 boşluk → 2 taşınır
	var board := Board.new([
		_tube(4, [&"blue", &"red", &"red", &"red"]),
		_tube(4, [&"red", &"red"]),
	])
	var move := board.build_move(0, 1)
	assert_eq(move.moved_count(), 2, "taşınan = min(üst-grup 3, boş alan 2)")
