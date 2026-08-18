extends GutTest

## ColorCard + ColorRegistry davranış testleri (TDD §13 matrisi: "Renk kaydı").

var _red: ColorCard
var _blue: ColorCard


func before_each() -> void:
	_red = ColorCard.new()
	_red.id = &"red"
	_red.symbol_id = &"circle"
	_blue = ColorCard.new()
	_blue.id = &"blue"
	_blue.symbol_id = &"square"


func test_register_ve_get() -> void:
	var reg := ColorRegistry.new()
	reg.register(_red)
	assert_eq(reg.get_card(&"red"), _red, "kayıtlı kart geri dönmeli")
	assert_true(reg.has(&"red"))
	assert_eq(reg.size(), 1)


func test_bilinmeyen_id_null_doner() -> void:
	var reg := ColorRegistry.new()
	reg.register(_red)
	assert_null(reg.get_card(&"yesil"), "bilinmeyen ID null dönmeli")
	assert_false(reg.has(&"yesil"))


func test_cift_id_ilk_kayit_korunur() -> void:
	var reg := ColorRegistry.new()
	reg.register(_red)
	var red_ikinci := ColorCard.new()
	red_ikinci.id = &"red"
	reg.register(red_ikinci)  # çift ID — yok sayılmalı
	assert_eq(reg.size(), 1, "çift ID eklenmemeli")
	assert_eq(reg.get_card(&"red"), _red, "ilk kayıt korunmalı")


func test_same_as_kimlige_gore() -> void:
	var red_kopya := ColorCard.new()
	red_kopya.id = &"red"
	assert_true(_red.same_as(red_kopya), "aynı id → same_as true")
	assert_false(_red.same_as(_blue), "farklı id → false")
	assert_false(_red.same_as(null), "null → false")
