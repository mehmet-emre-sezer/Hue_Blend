class_name GameContent
extends RefCounted

## GEÇİCİ iskele (ARCH-022/023): renkleri ve ilk seviyeyi KODLA üretir.
## M2'de veri-odaklı .tres dosyalarına taşınacak; LevelLoader/Validator DEĞİŞMEYECEK
## (ikisi de LevelData üstünde çalışıyor, kaynağın .tres mi kod mu olduğu fark etmez).

static func colors() -> ColorRegistry:
	var registry := ColorRegistry.new()
	registry.register(_card(&"red", Color("e0645a"), &"circle"))
	registry.register(_card(&"blue", Color("5a7ae0"), &"square"))
	registry.register(_card(&"green", Color("5ac06a"), &"triangle"))
	registry.register(_card(&"yellow", Color("e0c24a"), &"diamond"))
	return registry


static func level_one() -> LevelData:
	var level := LevelData.new()
	level.capacity = 4
	var tubes: Array[PackedStringArray] = []
	tubes.append(PackedStringArray(["red", "blue", "red", "blue"]))
	tubes.append(PackedStringArray(["blue", "red", "blue", "red"]))
	tubes.append(PackedStringArray([]))
	tubes.append(PackedStringArray([]))
	level.tubes = tubes
	return level


static func _card(id: StringName, color: Color, symbol: StringName) -> ColorCard:
	var card := ColorCard.new()
	card.id = id
	card.display_color = color
	card.symbol_id = symbol
	return card
