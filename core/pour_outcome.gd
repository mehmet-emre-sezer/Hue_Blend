class_name PourOutcome
extends RefCounted

## Bir dökme/karıştırma işleminin saf sonucu (değer nesnesi).
## Kaynak/hedef tüplerin YENİ içerikleri + animasyon/geri bildirim bilgisi.

var source_after: Array   # kaynak tüpün yeni içeriği (Array[ColorCard])
var dest_after: Array     # hedef tüpün yeni içeriği
var moved_count: int      # kaynaktan taşınan birim sayısı
var poured_color: ColorCard   # dökülen renk (animasyon için)
var result_color: ColorCard   # hedef üstünde oluşan renk (karışımsa ikincil)


func _init(
	source_after_: Array, dest_after_: Array, moved_count_: int,
	poured_color_: ColorCard, result_color_: ColorCard
) -> void:
	source_after = source_after_
	dest_after = dest_after_
	moved_count = moved_count_
	poured_color = poured_color_
	result_color = result_color_
