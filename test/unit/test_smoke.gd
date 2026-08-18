extends GutTest

## M0 duman testi: test altyapısının ayakta olduğunu doğrular.
## Gerçek çekirdek testleri M1'de gelecek (test_tube, test_board, ...).
func test_gut_calisiyor() -> void:
	assert_true(true, "GUT test altyapısı çalışıyor")
