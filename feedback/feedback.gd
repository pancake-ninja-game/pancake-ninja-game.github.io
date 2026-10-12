class_name Feedback
extends Node2D

const THEME: Theme = preload("res://theme.tres")

const POPUP_WIDTH: int = 460
const POPUP_OFFSET: Vector2 = Vector2(0, -60)
const POPUP_RISE: int = 80
const PERFECT_COLOR: Color = Color(0.35, 1, 0.45)
const FAIL_COLOR: Color = Color(1, 0.3, 0.25)
const SCREEN_FLASH_ALPHA: float = 0.35

var streak: int = 0

@onready var screen_flash: ColorRect = $ScreenFlash
@onready var scrap_sound: AudioStreamPlayer = $ScrapSound


# Shows text that pops in at the given point, floats up and fades out
func popup(text: String, color: Color, at: Vector2, font_size: int) -> void:
	var label: Label = Label.new()
	label.theme = THEME
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 12)
	label.size = Vector2(POPUP_WIDTH, font_size * 2)
	label.pivot_offset = label.size / 2
	label.scale = Vector2(0.3, 0.3)
	
	# Keep the whole popup on screen
	var x: float = clampf(at.x, POPUP_WIDTH / 2.0, globals.WINDOW_WIDTH - POPUP_WIDTH / 2.0)
	label.position = Vector2(x, at.y) - label.pivot_offset
	add_child(label)
	
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "position:y", label.position.y - POPUP_RISE, 0.9)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.3).set_delay(0.6)
	tween.tween_callback(label.queue_free)


func fail(text: String, at: Vector2) -> void:
	streak = 0
	popup(text, FAIL_COLOR, at + POPUP_OFFSET, 40)
	scrap_sound.play()
	
	var tween: Tween = screen_flash.create_tween()
	tween.tween_property(screen_flash, "color:a", 0.0, 0.4).from(SCREEN_FLASH_ALPHA)


func _on_main_sheet_stacked(at: Vector2) -> void:
	streak += 1
	
	var text: String = "PERFECT!"
	if streak > 1:
		text = "PERFECT x%d" % streak
	
	popup(text, PERFECT_COLOR, at + POPUP_OFFSET, 30 + mini(streak, 7) * 2)


func _on_main_sheets_scrapped(count: int, at: Vector2) -> void:
	var text: String = "SCRAP!"
	if count > 1:
		text = "SCRAP x%d" % count
	
	fail(text, at)


func _on_main_sheet_missed(at: Vector2) -> void:
	fail("MISSED!", at)


func _on_main_game_started() -> void:
	streak = 0
