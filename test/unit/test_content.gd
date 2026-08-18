extends GutTest

## GameContent üretilen seviyelerin geçerli ve çözülmemiş olduğunu doğrular (PIPE-009).
## (Çözülebilirlik üretim yöntemiyle garanti — çözülmüş tahtadan geri karıştırma.)

func test_uretilen_seviyeler_gecerli_ve_cozulmemis() -> void:
	var colors := GameContent.colors()
	var levels := GameContent.levels()
	assert_true(levels.size() > 0, "en az bir seviye üretilmeli")

	var validator := LevelValidator.new()
	var loader := LevelLoader.new()
	var solver := LevelSolver.new()
	for i in levels.size():
		var errors := validator.validate(levels[i], colors)
		assert_eq(errors.size(), 0, "seviye %d geçerli olmalı: %s" % [i, ", ".join(errors)])
		var board := loader.load_board(levels[i], colors)
		assert_false(board.is_solved(), "seviye %d başlangıçta çözülü olmamalı" % i)
		assert_true(solver.is_solvable(levels[i], colors), "seviye %d çözülebilir olmalı" % i)
