extends GutTest

## Eser mozaiği: hücreler kayıtlı renklere işaret etmeli, sayaç tutarlı olmalı.

func test_eser_hucreleri_gecerli_ve_sayilir() -> void:
	var colors := GameContent.colors()
	var count := 0
	for row in GameContent.artwork_rows():
		for id in row:
			if id != "":
				assert_true(colors.has(StringName(id)), "eser rengi kayıtlı olmalı: %s" % id)
				count += 1
	assert_true(count > 0, "en az bir eser hücresi")
	assert_eq(count, GameContent.artwork_cell_count(), "sayaç dolu hücre sayısıyla tutarlı")
