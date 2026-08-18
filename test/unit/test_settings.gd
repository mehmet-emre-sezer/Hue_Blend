extends GutTest

## Settings testleri: varsayılan + round-trip (RES-020/CFG).

const TEST_PATH := "user://test_settings.json"


func after_each() -> void:
	var dir := DirAccess.open("user://")
	if dir != null and dir.file_exists("test_settings.json"):
		dir.remove("test_settings.json")


func test_varsayilan_kapali() -> void:
	assert_false(Settings.new(TEST_PATH).reduced_motion, "varsayılan: reduced_motion kapalı")


func test_ayar_kalici() -> void:
	var settings := Settings.new(TEST_PATH)
	settings.set_reduced_motion(true)
	assert_true(Settings.new(TEST_PATH).reduced_motion, "ayar diske yazılıp okunmalı")
