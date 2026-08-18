extends GutTest

## LevelValidator testleri (TDD §13 matrisi: seviye doğrulayıcı, PIPE-009).


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


func _validate(level: LevelData) -> PackedStringArray:
	return LevelValidator.new().validate(level, _registry())


func test_gecerli_seviye_hatasiz() -> void:
	var errors := _validate(_level(2, [["red", "red"], ["blue", "blue"], []]))
	assert_eq(errors.size(), 0, "geçerli seviye hata üretmemeli")


func test_kapasite_sifir_hata() -> void:
	assert_true(_validate(_level(0, [["red"]])).size() > 0, "kapasite 0 hata")


func test_bos_tup_listesi_hata() -> void:
	assert_true(_validate(_level(2, [])).size() > 0, "tüpsüz seviye hata")


func test_kapasite_asimi_hata() -> void:
	assert_true(_validate(_level(2, [["red", "red", "red"]])).size() > 0, "kapasite aşımı hata")


func test_bilinmeyen_renk_hata() -> void:
	assert_true(_validate(_level(2, [["mor", "mor"]])).size() > 0, "bilinmeyen renk hata")


func test_bolunmeyen_renk_sayisi_hata() -> void:
	# red toplam 3, kapasite 2 → 3 % 2 != 0
	assert_true(_validate(_level(2, [["red", "red"], ["red"]])).size() > 0, "bölünmeyen renk sayısı hata")
