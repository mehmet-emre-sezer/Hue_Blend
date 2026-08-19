class_name GameContent
extends RefCounted

## Renk ve seviye içeriğinin kaynağı. Seviyeler DETERMİNİSTİK ve GARANTİLİ ÇÖZÜLEBİLİR
## üretilir: seed'li rastgele dağıtım yapılır, LevelSolver ile çözülebilirliği doğrulanır;
## çözülemezse bir sonraki seed denenir. RNG-003/X-024, PIPE-009 ile uyumlu.
## Not: Faz 3'te elle tasarlanmış seviyeler eklenebilir; LevelLoader/Validator değişmez.

static func colors() -> ColorRegistry:
	var registry := ColorRegistry.new()
	# Temel renkler
	registry.register(_card(&"red", Color("e0645a"), &"circle"))
	registry.register(_card(&"blue", Color("5a7ae0"), &"square"))
	registry.register(_card(&"yellow", Color("e0c24a"), &"diamond"))
	# İkincil renkler (karışımla elde edilir)
	registry.register(_card(&"green", Color("5ac06a"), &"triangle"))
	registry.register(_card(&"purple", Color("9b5ac0"), &"pentagon"))
	registry.register(_card(&"orange", Color("e0925a"), &"hexagon"))
	# Üçüncül renkler (ikincil + temel → renk ağacı, Aşama 2)
	registry.register(_card(&"teal", Color("3fa6a0"), &"heptagon"))    # yeşil + mavi
	registry.register(_card(&"lime", Color("9fc74a"), &"octagon"))     # yeşil + sarı
	return registry


## TAM karışım kataloğu: temel→ikincil ve ikincil+temel→üçüncül (renk ağacı).
## Seviyeler bunun ALT KÜMESİNİ kullanır (seviye-bazlı sınırlama, main._rules_for_level).
static func mix_rules(registry: ColorRegistry) -> MixRules:
	var rules := MixRules.new()
	# İkincil
	rules.add(&"blue", &"yellow", registry.get_card(&"green"))
	rules.add(&"red", &"blue", registry.get_card(&"purple"))
	rules.add(&"red", &"yellow", registry.get_card(&"orange"))
	# Üçüncül (renk ağacı)
	rules.add(&"green", &"blue", registry.get_card(&"teal"))
	rules.add(&"green", &"yellow", registry.get_card(&"lime"))
	return rules


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
	out.append(_generate(registry, ["red", "blue", "green", "yellow"], 5, 2, 707))
	out.append(_generate(registry, ["red", "blue", "green", "yellow"], 5, 3, 808))
	out.append(_generate(registry, ["red", "blue", "green", "yellow"], 6, 2, 909))
	out.append(_generate(registry, ["red", "blue", "green", "yellow"], 6, 3, 1010))
	# Faz 2: karışımlı seviyeler (her biri yalnız kendi tariflerini açar — seviye-bazlı)
	var full := mix_rules(registry)
	# Öğretici — her biri bir ikincil rengi tanıtır
	out.append(_generate_mixing(registry, full, ["blue", "blue", "yellow", "yellow"], [["blue", "yellow"]], 4, 2, 2001))
	out.append(_generate_mixing(registry, full, ["red", "red", "blue", "blue"], [["red", "blue"]], 4, 2, 2002))
	out.append(_generate_mixing(registry, full, ["red", "red", "yellow", "yellow"], [["red", "yellow"]], 4, 2, 2003))
	# Birleşik — bazı renkler saf kalır, bazıları karıştırılır
	out.append(_generate_mixing(registry, full,
		["blue", "blue", "blue", "blue", "blue", "blue", "yellow", "yellow"], [["blue", "yellow"]], 4, 2, 2004))
	out.append(_generate_mixing(registry, full,
		["red", "red", "red", "red", "red", "red", "blue", "blue"], [["red", "blue"]], 4, 2, 2005))
	# Çok-ikincil — aynı seviyede iki ikincil renk üret
	out.append(_generate_mixing(registry, full,
		["blue", "blue", "red", "red", "yellow", "yellow", "yellow", "yellow"], [["blue", "yellow"], ["red", "yellow"]], 4, 3, 2006))
	# Üçüncül (renk ağacı) — teal = 3:1 mavi:sarı, lime = 1:3 mavi:sarı
	out.append(_generate_mixing(registry, full,
		["blue", "blue", "blue", "yellow"], [["blue", "yellow"], ["green", "blue"]], 4, 3, 2007))
	out.append(_generate_mixing(registry, full,
		["blue", "yellow", "yellow", "yellow"], [["blue", "yellow"], ["green", "yellow"]], 4, 3, 2008))
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
		if not board.is_solved() and solver.is_solvable(level, registry):
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


## Karışım seviyesi: torbayı dağıtır; SEVİYE TARİFLERİYLE çözülebilir AMA karışımsız
## çözülemez olana kadar seed'i artırır (gerçekten karıştırma gerektirir).
static func _generate_mixing(
	registry: ColorRegistry, full_rules: MixRules, bag_ids: Array, mix_pairs: Array,
	capacity: int, empty_tubes: int, seed_value: int
) -> LevelData:
	var scoped := _scoped_rules(registry, full_rules, mix_pairs)
	var typed_pairs := _to_typed_pairs(mix_pairs)
	var solver := LevelSolver.new()
	var attempt := 0
	while attempt < 800:
		var level := _deal_mixing(bag_ids, capacity, empty_tubes, seed_value + attempt)
		if solver.is_solvable(level, registry, scoped) and not solver.is_solvable(level, registry, null):
			level.uses_mixing = true
			level.mix_pairs = typed_pairs
			return level
		attempt += 1
	push_error("Karışımlı seviye üretilemedi (seed %d)" % seed_value)
	var fallback := _deal_mixing(bag_ids, capacity, empty_tubes, seed_value)
	fallback.uses_mixing = true
	fallback.mix_pairs = typed_pairs
	return fallback


## Verilen [a,b] çiftlerinden (tam kataloğun sonucuyla) sınırlı bir MixRules kurar.
static func _scoped_rules(registry: ColorRegistry, full_rules: MixRules, mix_pairs: Array) -> MixRules:
	var scoped := MixRules.new()
	for pair in mix_pairs:
		var a := StringName(pair[0])
		var b := StringName(pair[1])
		var result := full_rules.result_of(a, b)
		if result != null:
			scoped.add(a, b, result)
	return scoped


static func _to_typed_pairs(mix_pairs: Array) -> Array[PackedStringArray]:
	var out: Array[PackedStringArray] = []
	for pair in mix_pairs:
		out.append(PackedStringArray(pair))
	return out


## Torbayı seed'li karıştırıp sırayla tüplere (kapasiteye kadar) doldurur + boş tüpler ekler.
static func _deal_mixing(bag_ids: Array, capacity: int, empty_tubes: int, seed_value: int) -> LevelData:
	var bag := bag_ids.duplicate()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in range(bag.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var temp = bag[i]
		bag[i] = bag[j]
		bag[j] = temp

	var level := LevelData.new()
	level.capacity = capacity
	var tube_arrays: Array[PackedStringArray] = []
	var index := 0
	while index < bag.size():
		var tube := PackedStringArray()
		for k in capacity:
			if index < bag.size():
				tube.append(String(bag[index]))
				index += 1
		tube_arrays.append(tube)
	for e in empty_tubes:
		tube_arrays.append(PackedStringArray())
	level.tubes = tube_arrays
	return level
