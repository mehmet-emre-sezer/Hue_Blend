extends GutTest

## Tube davranış testleri (TDD §13 matrisi: can_accept, top_run, is_solved, kapasite).

var _red: ColorCard
var _blue: ColorCard


func before_each() -> void:
	_red = _card(&"red")
	_blue = _card(&"blue")


func _card(id: StringName) -> ColorCard:
	var c := ColorCard.new()
	c.id = id
	return c


func test_bos_tup_durumu() -> void:
	var t := Tube.new(4)
	assert_true(t.is_empty())
	assert_false(t.is_full())
	assert_eq(t.size(), 0)
	assert_eq(t.free_space(), 4)
	assert_null(t.top())
	assert_eq(t.top_run_count(), 0)


func test_push_top_pop() -> void:
	var t := Tube.new(4)
	t.push_card(_red)
	t.push_card(_blue)
	assert_eq(t.size(), 2)
	assert_eq(t.top(), _blue, "üst en son eklenen olmalı")
	assert_eq(t.pop_card(), _blue, "pop üstü döner")
	assert_eq(t.top(), _red, "pop sonrası üst değişir")


func test_can_accept_kurallari() -> void:
	var t := Tube.new(2)
	assert_true(t.can_accept(_red), "boş tüp her rengi kabul eder")
	t.push_card(_red)
	assert_true(t.can_accept(_red), "eşleşen üst kabul edilir")
	assert_false(t.can_accept(_blue), "eşleşmeyen üst reddedilir")
	t.push_card(_red)
	assert_false(t.can_accept(_red), "dolu tüp reddeder")
	assert_false(t.can_accept(null), "null reddedilir")


func test_top_run_count() -> void:
	var t := Tube.new(5)
	t.push_card(_blue)
	t.push_card(_red)
	t.push_card(_red)
	assert_eq(t.top_run_count(), 2, "üstteki bitişik aynı-renk grubu = 2")


func test_is_solved() -> void:
	var bos := Tube.new(3)
	assert_true(bos.is_solved(), "boş tüp çözülü sayılır")

	var tam_uniform := Tube.new(2)
	tam_uniform.push_card(_red)
	tam_uniform.push_card(_red)
	assert_true(tam_uniform.is_solved(), "dolu + tek renk = çözülü")

	var tam_karisik := Tube.new(2)
	tam_karisik.push_card(_red)
	tam_karisik.push_card(_blue)
	assert_false(tam_karisik.is_solved(), "dolu ama karışık = çözülü değil")

	var yarim := Tube.new(3)
	yarim.push_card(_red)
	assert_false(yarim.is_solved(), "yarım tek renk = çözülü değil")


func test_snapshot_kopyadir() -> void:
	var t := Tube.new(3)
	t.push_card(_red)
	var snap := t.cards_snapshot()
	snap.append(_blue)  # dışarıda değiştir
	assert_eq(t.size(), 1, "snapshot mutasyonu tüpü etkilememeli")
