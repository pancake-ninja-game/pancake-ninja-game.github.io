class_name Feedback
extends Node2D

const THEME: Theme = preload("res://theme.tres")

const POPUP_WIDTH: int = 460
const POPUP_OFFSET: Vector2 = Vector2(0, -60)
const POPUP_RISE: int = 80
const PERFECT_COLOR: Color = Color(0.35, 1, 0.45)
const FAIL_COLOR: Color = Color(1, 0.3, 0.25)
const SCREEN_FLASH_ALPHA: float = 0.35
const ANNOUNCE_COLOR: Color = Color(1, 0.85, 0.2)
# Above the line, so the banner doesn't hide the sheets
const ANNOUNCE_Y: int = 190
const ANNOUNCE_HEIGHT: int = 140
const ANNOUNCE_HOLD: float = 1.4

var streak: int = 0

@onready var screen_flash: ColorRect = $ScreenFlash
@onready var scrap_sound: AudioStreamPlayer = $ScrapSound


func make_label(text: String, color: Color, font_size: int, width: float) -> Label:
	var label: Label = Label.new()
	label.theme = THEME
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 12)
	label.size = Vector2(width, font_size * 2)
	label.pivot_offset = label.size / 2
	return label


# Shows text that pops in at the given point, floats up and fades out
func popup(text: String, color: Color, at: Vector2, font_size: int) -> void:
	var label: Label = make_label(text, color, font_size, POPUP_WIDTH)
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


# Shows a banner across the screen that snaps open, holds, and fades out
func announce(title: String, subtitle: String) -> void:
	var banner: ColorRect = ColorRect.new()
	banner.color = Color(0, 0, 0, 0.65)
	# Let swipes through, the game keeps going underneath
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.size = Vector2(globals.WINDOW_WIDTH, ANNOUNCE_HEIGHT)
	banner.position = Vector2(0, ANNOUNCE_Y - ANNOUNCE_HEIGHT / 2.0)
	banner.pivot_offset = banner.size / 2
	banner.scale = Vector2(1, 0)
	add_child(banner)
	
	var title_label: Label = make_label(title, ANNOUNCE_COLOR, 52, globals.WINDOW_WIDTH)
	title_label.position = Vector2(0, 0)
	banner.add_child(title_label)
	
	var subtitle_label: Label = make_label(subtitle, Color.WHITE, 30, globals.WINDOW_WIDTH)
	subtitle_label.position = Vector2(0, ANNOUNCE_HEIGHT - subtitle_label.size.y - 10)
	banner.add_child(subtitle_label)
	
	var tween: Tween = banner.create_tween()
	tween.tween_property(banner, "scale:y", 1.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(title_label, "scale", Vector2.ONE, 0.35).from(Vector2(1.6, 1.6)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(ANNOUNCE_HOLD)
	tween.tween_property(banner, "modulate:a", 0.0, 0.4)
	tween.tween_callback(banner.queue_free)


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


func _on_round_timer_difficulty_change_requested(difficulty_index: int) -> void:
	announce("DIFFICULTY UP!", globals.DIFFICULTY_NAMES[difficulty_index].to_upper())
