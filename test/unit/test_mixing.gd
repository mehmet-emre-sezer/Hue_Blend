extends GutTest

## Faz 2 Aşama 1 — arayüzde 1:1 karışım testleri (kullanıcı spesifikasyonu).

var _green: ColorCard


func _card(id: StringName) -> ColorCard:
	var c := ColorCard.new()
	c.id = id
	return c


func _tube(capacity: int, ids: Array) -> Tube:
	var t := Tube.new(capacity)
	for id in ids:
		t.push_card(_card(id))
	return t


func _rules() -> MixRules:
	_green = _card(&"green")
	var rules := MixRules.new()
	rules.add(&"blue", &"yellow", _green)
	return rules


func _ids(board: Board, i: int) -> Array:
	var out := []
	for card in board.tube(i).cards_snapshot():
		out.append(card.id)
	return out


func test_bir_bir_iki_yesil() -> void:
	var board := Board.new([_tube(4, [&"blue"]), _tube(4, [&"yellow"])], _rules())
	board.build_move(0, 1).apply(board)
	assert_eq(_ids(board, 1), [&"green", &"green"], "1 mavi + 1 sarı = 2 yeşil")
	assert_true(board.tube(0).is_empty(), "kaynak boşalır")


func test_fazla_dokulen_ustte() -> void:
	# 2 mavi → 1 sarı: 1 çift yeşil, fazla mavi ÜSTTE
	var board := Board.new([_tube(4, [&"blue", &"blue"]), _tube(4, [&"yellow"])], _rules())
	board.build_move(0, 1).apply(board)
	assert_eq(_ids(board, 1), [&"green", &"green", &"blue"], "fazla mavi üstte kalır")


func test_fazla_hedef_altta() -> void:
	# 1 mavi → 2 sarı: 1 çift yeşil, fazla sarı ALTTA
	var board := Board.new([_tube(4, [&"blue"]), _tube(4, [&"yellow", &"yellow"])], _rules())
	board.build_move(0, 1).apply(board)
	assert_eq(_ids(board, 1), [&"yellow", &"green", &"green"], "fazla sarı altta kalır")


func test_yari_yariya_tam_doldurur() -> void:
	# 2 mavi + 2 sarı = 4 yeşil (kapasite 4 dolar)
	var board := Board.new([_tube(4, [&"blue", &"blue"]), _tube(4, [&"yellow", &"yellow"])], _rules())
	var result := board.build_move(0, 1).apply(board)
	assert_eq(_ids(board, 1), [&"green", &"green", &"green", &"green"], "tüp tamamen yeşil dolar")
	assert_true(result.dest_tube_solved, "hedef tüp çözülür")


func test_karisim_undo_round_trip() -> void:
	var board := Board.new([_tube(4, [&"blue", &"blue"]), _tube(4, [&"yellow"])], _rules())
	var before0 := _ids(board, 0)
	var before1 := _ids(board, 1)
	var move := board.build_move(0, 1)
	move.apply(board)
	move.undo(board)
	assert_eq(_ids(board, 0), before0, "karışım undo: kaynak eski hâline döner")
	assert_eq(_ids(board, 1), before1, "karışım undo: hedef eski hâline döner")


func test_uyumsuz_renk_null() -> void:
	# tablo yalnız blue+yellow; red+blue tanımsız → hamle geçersiz
	var board := Board.new([_tube(4, [&"red"]), _tube(4, [&"blue"])], _rules())
	assert_null(board.build_move(0, 1), "tanımsız karışım hamlesi geçersiz")
