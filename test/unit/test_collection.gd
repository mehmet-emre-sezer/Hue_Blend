extends GutTest

## Collection testleri: ilk keşif + kalıcılık (renk açma meta).

const TEST_PATH := "user://test_collection.json"


func after_each() -> void:
	var dir := DirAccess.open("user://")
	if dir != null and dir.file_exists("test_collection.json"):
		dir.remove("test_collection.json")


func test_ilk_kesif_true_sonra_false() -> void:
	var collection := Collection.new(TEST_PATH)
	assert_true(collection.discover(&"green"), "ilk keşif true dönmeli")
	assert_false(collection.discover(&"green"), "aynı renk ikinci kez false")
	assert_true(collection.has(&"green"))
	assert_eq(collection.count(), 1)


func test_kesif_kalicidir() -> void:
	Collection.new(TEST_PATH).discover(&"teal")
	assert_true(Collection.new(TEST_PATH).has(&"teal"), "keşif diske yazılıp okunmalı")
