extends GutTest

## Çözücünün karışımı doğru kullandığını kanıtlar: bu seviye YALNIZCA karışımla çözülür.
## (kapasite 2; 1 mavi + 1 sarı → 2 yeşil ile tek tüp dolar; karışımsız takılı kalır.)

func _colors() -> ColorRegistry:
	var reg := ColorRegistry.new()
	for id in [&"blue", &"yellow", &"green"]:
		var card := ColorCard.new()
		card.id = id
		reg.register(card)
	return reg


func _rules(colors: ColorRegistry) -> MixRules:
	var rules := MixRules.new()
	rules.add(&"blue", &"yellow", colors.get_card(&"green"))
	return rules


func _level() -> LevelData:
	var level := LevelData.new()
	level.capacity = 2
	var tubes: Array[PackedStringArray] = []
	tubes.append(PackedStringArray(["blue"]))
	tubes.append(PackedStringArray(["yellow"]))
	tubes.append(PackedStringArray([]))
	level.tubes = tubes
	return level


func test_karisimla_cozulur() -> void:
	var colors := _colors()
	assert_true(
		LevelSolver.new().is_solvable(_level(), colors, _rules(colors)),
		"karışım açıkken çözülebilir olmalı"
	)


func test_karisimsiz_cozulemez() -> void:
	var colors := _colors()
	assert_false(
		LevelSolver.new().is_solvable(_level(), colors, null),
		"karışım olmadan çözülemez olmalı"
	)


## Renk ağacı: teal = önce yeşil (mavi+sarı), sonra yeşil+mavi. 3 mavi + 1 sarı → 4 teal.
func _teal_level() -> LevelData:
	var level := LevelData.new()
	level.capacity = 4
	var tubes: Array[PackedStringArray] = []
	tubes.append(PackedStringArray(["blue", "blue", "blue", "yellow"]))
	tubes.append(PackedStringArray([]))
	tubes.append(PackedStringArray([]))
	level.tubes = tubes
	return level


func test_renk_agaci_teal_uretilir() -> void:
	var colors := GameContent.colors()
	var rules := MixRules.new()
	rules.add(&"blue", &"yellow", colors.get_card(&"green"))
	rules.add(&"green", &"blue", colors.get_card(&"teal"))
	assert_true(LevelSolver.new().is_solvable(_teal_level(), colors, rules), "renk ağacıyla teal üretilebilir")


func test_teal_recipe_olmadan_cozulemez() -> void:
	var colors := GameContent.colors()
	var only_green := MixRules.new()
	only_green.add(&"blue", &"yellow", colors.get_card(&"green"))  # teal recipe YOK
	assert_false(LevelSolver.new().is_solvable(_teal_level(), colors, only_green), "teal recipe olmadan çözülemez")
