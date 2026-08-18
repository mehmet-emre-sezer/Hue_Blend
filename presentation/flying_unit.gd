class_name FlyingUnit
extends Node2D

## Dökme animasyonu sırasında tüpler arası "uçan" tek birim (origin merkezli çizilir).

var _color: Color
var _symbol: StringName


func setup(color: Color, symbol: StringName) -> void:
	_color = color
	_symbol = symbol
	queue_redraw()


func _draw() -> void:
	var inner := UnitVisual.unit_inner_size()
	UnitVisual.draw_unit(self, Rect2(-inner / 2.0, inner), _color, _symbol)
