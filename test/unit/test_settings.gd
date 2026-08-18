extends GutTest

## Settings testleri: varsayılan + round-trip (RES-020/CFG).

const TEST_PATH := "user://test_settings.json"


func after_each() -> void:
	var dir := DirAccess.open("user://")
	if dir != null and dir.file_exists("test_settings.json"):
		dir.remove("test_settings.json")


func test_varsayilanlar_kapali() -> void:
	var settings := Settings.new(TEST_PATH)
	assert_false(settings.reduced_motion, "varsayılan: reduced_motion kapalı")
	assert_false(settings.colorblind_mode, "varsayılan: colorblind_mode kapalı")


func test_reduced_motion_kalici() -> void:
	Settings.new(TEST_PATH).set_reduced_motion(true)
	assert_true(Settings.new(TEST_PATH).reduced_motion, "reduced_motion diske yazılıp okunmalı")


func test_colorblind_kalici() -> void:
	Settings.new(TEST_PATH).set_colorblind_mode(true)
	assert_true(Settings.new(TEST_PATH).colorblind_mode, "colorblind_mode diske yazılıp okunmalı")
