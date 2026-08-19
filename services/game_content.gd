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
	registry.register(_card(&"teal", Color("3fa6a0"), &"heptagon"))       # yeşil + mavi
	registry.register(_card(&"lime", Color("9fc74a"), &"octagon"))        # yeşil + sarı
	registry.register(_card(&"amber", Color("e0a84a"), &"ring"))          # turuncu + sarı
	registry.register(_card(&"vermilion", Color("e07040"), &"cross"))     # turuncu + kırmızı
	registry.register(_card(&"magenta", Color("c04a9b"), &"star"))        # mor + kırmızı
	registry.register(_card(&"violet", Color("7a5ac0"), &"plus"))         # mor + mavi
	return registry


## "Eser" mozaiği: her çözülen seviye bir sonraki (boş olmayan) hücreyi açar.
## "" = boş (desenin dışı). 18 dolu hücre → ~18 seviyede tamamlanır.
static func artwork_rows() -> Array:
	return [
		["red", "magenta", "", "magenta", "red"],
		["red", "red", "vermilion", "red", "red"],
		["orange", "red", "red", "red", "orange"],
		["", "vermilion", "red", "vermilion", ""],
		["", "", "red", "", ""],
	]


## Eserdeki toplam dolu (boş olmayan) hücre sayısı.
static func artwork_cell_count() -> int:
	var total := 0
	for row in artwork_rows():
		for id in row:
			if id != "":
				total += 1
	return total


## Temel renkler (her zaman bilinir — başlangıç paleti).
static func primary_ids() -> Array:
	return [&"red", &"blue", &"yellow"]


## Karışımla KEŞFEDİLEBİLİR renkler (koleksiyon ekranı sırası): ikincil sonra üçüncül.
static func discoverable_ids() -> Array:
	return [
		&"green", &"purple", &"orange",
		&"teal", &"lime", &"amber", &"vermilion", &"magenta", &"violet",
	]


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
	rules.add(&"orange", &"yellow", registry.get_card(&"amber"))
	rules.add(&"orange", &"red", registry.get_card(&"vermilion"))
	rules.add(&"purple", &"red", registry.get_card(&"magenta"))
	rules.add(&"purple", &"blue", registry.get_card(&"violet"))
	return rules


## Artan zorlukta seviye listesi. Zorluk RENK SAYISINDAN gelir (3→6, boş tüp hep 2 =
## klasik su-sort gerilimi); ayrıca 'easy_floor' ile birkaç hamlede biten trivial dağıtımlar
## elenir (maymun-testi). Karışım seviyeleri bir sıralama bulmacasına gömülü ve daha hacimli.
static func levels() -> Array[LevelData]:
	var registry := colors()
	var out: Array[LevelData] = []
	# Sıralama (karışımsız) — renk sayısı artar, boş tüp 2'de sabit, zorluk tabanı yükselir.
	out.append(_generate(registry, ["red", "blue", "yellow"], 4, 2, 101, 2))
	out.append(_generate(registry, ["red", "blue", "green"], 4, 2, 202, 3))
	out.append(_generate(registry, ["red", "blue", "yellow", "green"], 4, 2, 303, 4))
	out.append(_generate(registry, ["red", "blue", "yellow", "orange"], 4, 2, 404, 4))
	out.append(_generate(registry, ["red", "blue", "yellow", "green", "purple"], 4, 2, 505, 5))
	out.append(_generate(registry, ["red", "blue", "yellow", "green", "orange"], 4, 2, 606, 5))
	out.append(_generate(registry, ["red", "blue", "yellow", "green", "purple", "orange"], 4, 2, 707, 6))
	out.append(_generate(registry, ["red", "blue", "yellow", "green", "purple", "orange"], 4, 2, 808, 6))
	out.append(_generate(registry, ["red", "blue", "yellow", "green", "purple", "orange"], 4, 2, 909, 7))
	out.append(_generate(registry, ["red", "blue", "yellow", "green", "purple", "orange"], 4, 2, 1010, 7))
	# Faz 2: karışımlı seviyeler (her biri yalnız kendi tariflerini açar — seviye-bazlı).
	var full := mix_rules(registry)
	# Öğretici — her biri bir ikincil rengi nazikçe tanıtır. Küçük hacim (2+2): renk sayıları
	# kapasitenin katı DEĞİL, o yüzden karışımsız çözülemez (mekanik burada öğretilir).
	out.append(_generate_mixing(registry, full, _bag([["blue", 2], ["yellow", 2]]), [["blue", "yellow"]], 4, 2, 2001, 0))
	out.append(_generate_mixing(registry, full, _bag([["red", 2], ["blue", 2]]), [["red", "blue"]], 4, 2, 2002, 0))
	out.append(_generate_mixing(registry, full, _bag([["red", 2], ["yellow", 2]]), [["red", "yellow"]], 4, 2, 2003, 0))
	# Birleşik — bazı renkler saf kalır, bazıları karıştırılır.
	out.append(_generate_mixing(registry, full, _bag([["blue", 6], ["yellow", 2]]), [["blue", "yellow"]], 4, 2, 2004, 4))
	out.append(_generate_mixing(registry, full, _bag([["red", 6], ["blue", 2]]), [["red", "blue"]], 4, 2, 2005, 4))
	# Çok-ikincil — aynı seviyede iki ikincil renk üret.
	out.append(_generate_mixing(registry, full, _bag([["blue", 2], ["red", 2], ["yellow", 4]]),
		[["blue", "yellow"], ["red", "yellow"]], 4, 3, 2006, 4))
	# Üçüncül (renk ağacı) — 3:1 oranı ağaç yoluyla, hacim 2 tüp (8 birim).
	out.append(_generate_mixing(registry, full, _bag([["blue", 6], ["yellow", 2]]),
		[["blue", "yellow"], ["green", "blue"]], 4, 3, 2007, 4))  # teal
	out.append(_generate_mixing(registry, full, _bag([["blue", 2], ["yellow", 6]]),
		[["blue", "yellow"], ["green", "yellow"]], 4, 3, 2008, 4))  # lime
	out.append(_generate_mixing(registry, full, _bag([["red", 2], ["yellow", 6]]),
		[["red", "yellow"], ["orange", "yellow"]], 4, 3, 2009, 4))  # amber
	out.append(_generate_mixing(registry, full, _bag([["red", 6], ["yellow", 2]]),
		[["red", "yellow"], ["orange", "red"]], 4, 3, 2010, 4))  # vermilion
	out.append(_generate_mixing(registry, full, _bag([["red", 6], ["blue", 2]]),
		[["red", "blue"], ["purple", "red"]], 4, 3, 2011, 4))  # magenta
	out.append(_generate_mixing(registry, full, _bag([["red", 2], ["blue", 6]]),
		[["red", "blue"], ["purple", "blue"]], 4, 3, 2012, 4))  # violet
	return out


## Renk-adet çiftlerinden düz bir torba listesi kurar: _bag([["blue",4],["yellow",4]]).
static func _bag(pairs: Array) -> Array:
	var out: Array = []
	for pair in pairs:
		for i in int(pair[1]):
			out.append(String(pair[0]))
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
	empty_tubes: int, seed_value: int, easy_floor: int = 0
) -> LevelData:
	var solver := LevelSolver.new()
	var loader := LevelLoader.new()
	var attempt := 0
	while attempt < 600:
		var level := _random_deal(color_ids, capacity, empty_tubes, seed_value + attempt)
		var board := loader.load_board(level, registry)
		# Çözülebilir + başlangıçta çözülü değil + 'easy_floor' hamlede çözülecek kadar
		# BASİT değil (maymun-testi: birkaç rastgele hamlede biten seviyeleri ele).
		if not board.is_solved() and solver.is_solvable(level, registry) \
				and not solver.is_solvable_within(level, registry, null, easy_floor, 30000):
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
	capacity: int, empty_tubes: int, seed_value: int, easy_floor: int = 0
) -> LevelData:
	var scoped := _scoped_rules(registry, full_rules, mix_pairs)
	var typed_pairs := _to_typed_pairs(mix_pairs)
	var solver := LevelSolver.new()
	var attempt := 0
	while attempt < 1200:
		var level := _deal_mixing(bag_ids, capacity, empty_tubes, seed_value + attempt)
		# Karışımla çözülebilir + karışımsız çözülemez (gerçekten karıştırma gerektirir)
		# + 'easy_floor' hamlede bitecek kadar basit değil (trivial karışım seviyelerini ele).
		if solver.is_solvable(level, registry, scoped) \
				and not solver.is_solvable(level, registry, null) \
				and not solver.is_solvable_within(level, registry, scoped, easy_floor, 30000):
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
