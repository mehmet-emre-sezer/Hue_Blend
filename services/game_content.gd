class_name GameContent
extends RefCounted

## Renk ve seviye içeriğinin kaynağı. Seviyeler DETERMİNİSTİK ve GARANTİLİ ÇÖZÜLEBİLİR
## üretilir: seed'li rastgele dağıtım yapılır, LevelSolver ile çözülebilirliği doğrulanır;
## çözülemezse bir sonraki seed denenir. RNG-003/X-024, PIPE-009 ile uyumlu.
## Not: Faz 3'te elle tasarlanmış seviyeler eklenebilir; LevelLoader/Validator değişmez.

static func colors() -> ColorRegistry:
	var registry := ColorRegistry.new()
	registry.register(_card(&"red", Color("e0645a"), &"circle"))
	registry.register(_card(&"blue", Color("5a7ae0"), &"square"))
	registry.register(_card(&"green", Color("5ac06a"), &"triangle"))
	registry.register(_card(&"yellow", Color("e0c24a"), &"diamond"))
	return registry


## Artan zorlukta seviye listesi (renk sayısı ve kapasite arttıkça zorlaşır).
static func levels() -> Array[LevelData]:
	var registry := colors()
	var out: Array[LevelData] = []
	out.append(_generate(registry, ["red", "blue"], 4, 2, 101))
	out.append(_generate(registry, ["red", "blue", "green"], 4, 2, 202))
	out.append(_generate(registry, ["red", "blue", "green"], 4, 2, 303))
	out.append(_generate(registry, ["red", "blue", "green", "yellow"], 4, 2, 404))
	out.append(_generate(registry, ["red", "blue", "green", "yellow"], 5, 2, 505))
	out.append(_generate(registry, ["red", "blue", "green", "yellow"], 4, 3, 606))
	return out


static func _card(id: StringName, color: Color, symbol: StringName) -> ColorCard:
	var card := ColorCard.new()
	card.id = id
	card.display_color = color
	card.symbol_id = symbol
	return card


## Seed'li rastgele dağıtım üretir; çözülebilir VE çözülü-değil olana kadar seed'i artırır.
static func _generate(
	registry: ColorRegistry, color_ids: Array, capacity: int,
	empty_tubes: int, seed_value: int
) -> LevelData:
	var solver := LevelSolver.new()
	var loader := LevelLoader.new()
	var attempt := 0
	while attempt < 500:
		var level := _random_deal(color_ids, capacity, empty_tubes, seed_value + attempt)
		var board := loader.load_board(level, registry)
		if not board.is_solved() and solver.is_solvable(level):
			return level
		attempt += 1
	push_error("Çözülebilir seviye üretilemedi (seed %d)" % seed_value)
	return _random_deal(color_ids, capacity, empty_tubes, seed_value)


## Her renkten tam 'capacity' adet içeren bir torbayı seed'li karıştırıp tüplere paylaştırır.
static func _random_deal(color_ids: Array, capacity: int, empty_tubes: int, seed_value: int) -> LevelData:
	var bag: Array = []
	for id in color_ids:
		for i in capacity:
			bag.append(String(id))

	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in range(bag.size() - 1, 0, -1):  # Fisher-Yates
		var j := rng.randi_range(0, i)
		var temp = bag[i]
		bag[i] = bag[j]
		bag[j] = temp

	var level := LevelData.new()
	level.capacity = capacity
	var tube_arrays: Array[PackedStringArray] = []
	var index := 0
	for c in color_ids.size():
		var tube := PackedStringArray()
		for k in capacity:
			tube.append(bag[index])
			index += 1
		tube_arrays.append(tube)
	for e in empty_tubes:
		tube_arrays.append(PackedStringArray())
	level.tubes = tube_arrays
	return level
