extends GutTest

## LevelLoader testleri (TDD §13 matrisi: LevelData→Board doğru kurulur).


func _registry() -> ColorRegistry:
	var reg := ColorRegistry.new()
	for id in [&"red", &"blue", &"green"]:
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


func test_load_board_dogru_kurar() -> void:
	var board := LevelLoader.new().load_board(_level(3, [["red", "red"], ["blue"], []]), _registry())
	assert_eq(board.tube_count(), 3)
	assert_eq(board.tube(0).size(), 2)
	assert_eq(board.tube(1).size(), 1)
	assert_true(board.tube(2).is_empty())
	assert_eq(board.tube(0).top().id, &"red", "dip→üst sıralaması: üst son eleman")
	assert_eq(board.tube(1).top().id, &"blue")


func test_load_paylasimli_kart_referansi() -> void:
	# aynı id → registry'den aynı paylaşılan örnek (flyweight, FLY-001)
	var board := LevelLoader.new().load_board(_level(2, [["red"], ["red"]]), _registry())
	assert_same(board.tube(0).top(), board.tube(1).top(), "aynı id → paylaşılan kart örneği")
