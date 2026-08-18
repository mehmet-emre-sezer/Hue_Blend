class_name ColorCard
extends Resource

## Bir rengin Type Object'i (TYPE-001): kimlik + görsel + erişilebilirlik sembolü.
## Veri-odaklı (.tres olarak tanımlanır), yüklendikten sonra değişmez kabul edilir (TYPE-005).
## Faz 2'de karıştırma bilgisi buraya VERİ olarak eklenecek — çekirdek değişmeyecek.

## Kararlı benzersiz kimlik (RES-005). StringName ucuz karşılaştırma sağlar (STR-002).
@export var id: StringName

## Ekranda gösterilen renk.
@export var display_color: Color = Color.WHITE

## Erişilebilirlik: renk körü oyuncular için desen/sembol kimliği (TDD §2.3).
## Birim renge EK olarak bununla da ayrışır.
@export var symbol_id: StringName


## İki kartın aynı rengi temsil edip etmediği — kimliğe göre (adres değil, RES-005/X-011).
func same_as(other: ColorCard) -> bool:
	return other != null and other.id == id
