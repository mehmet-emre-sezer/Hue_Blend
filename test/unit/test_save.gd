extends GutTest

## SaveService testleri (TDD §13 matrisi: Save round-trip + sürüm; RES-020/026).

const TEST_PATH := "user://test_save.json"


func after_each() -> void:
	var dir := DirAccess.open("user://")
	if dir != null and dir.file_exists("test_save.json"):
		dir.remove("test_save.json")


func test_kayit_yoksa_sifir() -> void:
	assert_eq(SaveService.new(TEST_PATH).load_level_index(), 0, "kayıt yokken 0")


func test_yaz_oku_round_trip() -> void:
	SaveService.new(TEST_PATH).save_progress(3)
	assert_eq(SaveService.new(TEST_PATH).load_level_index(), 3, "yazılan değer okunmalı")


func test_bozuk_kayit_sifir() -> void:
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string("bu gecerli json degil {")
	file = null
	assert_eq(SaveService.new(TEST_PATH).load_level_index(), 0, "bozuk kayıt → 0")


func test_uyumsuz_surum_sifir() -> void:
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version": 999, "level_index": 5}))
	file = null
	assert_eq(SaveService.new(TEST_PATH).load_level_index(), 0, "uyumsuz sürüm → 0")
