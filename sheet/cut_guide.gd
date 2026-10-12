class_name CutGuide
extends Node2D

enum Style { HIDDEN, FAINT, LINE, ZONE }

# Matches the sheet's OkArea collision shape
const ZONE_SIZE: Vector2 = Vector2(80, 220)
const ZONE_COLOR: Color = Color(0.25, 1, 0.45)
const FAINT_COLOR: Color = Color(1, 1, 1, 0.25)
const DASH_LENGTH: float = 12
const PULSE_SPEED: float = 8

@export var style: Style = Style.FAINT

var pulse_time: float = 0


func _process(delta: float) -> void:
	if style != Style.ZONE:
		return
	
	pulse_time += delta
	queue_redraw()


func set_style(new_style: Style) -> void:
	if new_style == style:
		return
	
	style = new_style
	queue_redraw()


func _draw() -> void:
	var half: Vector2 = ZONE_SIZE / 2
	var top: Vector2 = Vector2(0, -half.y)
	var bottom: Vector2 = Vector2(0, half.y)
	
	match style:
		Style.ZONE:
			var pulse: float = 0.5 + 0.5 * sin(pulse_time * PULSE_SPEED)
			var zone: Rect2 = Rect2(-half, ZONE_SIZE)
			draw_rect(zone, Color(ZONE_COLOR, 0.2 + 0.25 * pulse))
			draw_rect(zone, ZONE_COLOR, false, 3)
			draw_dashed_line(top, bottom, Color.WHITE, 3, DASH_LENGTH)
			# Marks at both ends, since cuts work both up and down
			draw_cut_arrow(top - Vector2(0, 6), Vector2.DOWN)
			draw_cut_arrow(bottom + Vector2(0, 6), Vector2.UP)
		Style.LINE:
			draw_dashed_line(top, bottom, ZONE_COLOR, 4, DASH_LENGTH)
		Style.FAINT:
			draw_dashed_line(top, bottom, FAINT_COLOR, 2, DASH_LENGTH)


# Arrow pointing in the given direction, with its tip at the given point
func draw_cut_arrow(tip: Vector2, direction: Vector2) -> void:
	var back: Vector2 = tip - direction * 26
	var side: Vector2 = Vector2(20, 0)
	var points: PackedVector2Array = PackedVector2Array([
		tip,
		back - side,
		back + side,
	])
	draw_colored_polygon(points, ZONE_COLOR)
	
	points.append(tip)
	draw_polyline(points, Color.BLACK, 3)
