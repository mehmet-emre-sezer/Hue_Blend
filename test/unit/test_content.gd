extends GutTest

## GameContent üretilen tüm seviyeler: geçerli, çözülmemiş, çözülebilir (PIPE-009).
## Karışım seviyeleri için doğru mix_rules ile doğrulanır.

func test_uretilen_seviyeler_gecerli_ve_cozulebilir() -> void:
	var colors := GameContent.colors()
	var mix := GameContent.mix_rules(colors)
	var levels := GameContent.levels()
	assert_true(levels.size() > 0, "en az bir seviye üretilmeli")

	var validator := LevelValidator.new()
	var loader := LevelLoader.new()
	var solver := LevelSolver.new()
	for i in levels.size():
		var rules: MixRules = mix if levels[i].uses_mixing else null
		var errors := validator.validate(levels[i], colors, rules)
		assert_eq(errors.size(), 0, "seviye %d geçerli olmalı: %s" % [i, ", ".join(errors)])
		var board := loader.load_board(levels[i], colors, rules)
		assert_false(board.is_solved(), "seviye %d başlangıçta çözülü olmamalı" % i)
		assert_true(solver.is_solvable(levels[i], colors, rules), "seviye %d çözülebilir olmalı" % i)


func test_karisim_seviyeleri_karisim_gerektirir() -> void:
	var colors := GameContent.colors()
	var mix := GameContent.mix_rules(colors)
	var solver := LevelSolver.new()
	var mixing_count := 0
	for level in GameContent.levels():
		if not level.uses_mixing:
			continue
		mixing_count += 1
		assert_false(
			solver.is_solvable(level, colors, null),
			"karışım seviyesi karışımsız çözülememeli (gerçekten karıştırma gerektirir)"
		)
	assert_true(mixing_count > 0, "en az bir karışım seviyesi olmalı")


## Zorluk tabanı: üst seviyeler birkaç rastgele hamlede bitecek kadar basit OLMAMALI
## (kullanıcının "maymun oyunu" geri bildirimine karşı regresyon kilidi).
func test_ust_seviyeler_trivial_degil() -> void:
	var colors := GameContent.colors()
	var levels := GameContent.levels()
	var solver := LevelSolver.new()
	# Son iki sıralama seviyesi (6 renk): 3 hamlede çözülmemeli.
	assert_false(solver.is_solvable_within(levels[8], colors, null, 3, 40000),
		"9. seviye 3 hamlede çözülmemeli")
	assert_false(solver.is_solvable_within(levels[9], colors, null, 3, 40000),
		"10. seviye 3 hamlede çözülmemeli")
