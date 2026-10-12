class_name StackScene
extends Node2D

signal stack_completed

const CAPACITY: int = 5
const SHEET_SPACING: int = 5
const DONE_COLOR: Color = Color(1, 0.85, 0.2)
	
var sheets: Array[SheetScene] = []

@onready var sheet_stacked_sound: AudioStreamPlayer2D = $SheetStackedSound
@onready var stack_completed_sound: AudioStreamPlayer2D = $StackCompletedSound
@onready var count_label: Label = $CountLabel


func is_full() -> bool:
	return len(sheets) >= CAPACITY


func stack_sheet(sheet: SheetScene) -> void:
	# A finished stack stays on display until the next sheet arrives
	if is_full():
		empty()
		
	sheets.append(sheet)
	sheet.reparent(self)
	
	sheet.move_to_stack(Vector2(
		0,
		0 - SHEET_SPACING * len(sheets),
	))
	
	if is_full():
		stack_completed_sound.play()
		stack_completed.emit()
	else:
		sheet_stacked_sound.play()
	
	update_count_label()


func empty() -> void:
	for s: SheetScene in sheets:
		s.queue_free()
	sheets.clear()


func update_count_label() -> void:
	if is_full():
		count_label.text = "JELLY ROLL!"
		count_label.self_modulate = DONE_COLOR
	else:
		count_label.text = "SHEETS %d/%d" % [len(sheets), CAPACITY]
		count_label.self_modulate = Color.WHITE
	
	var tween: Tween = count_label.create_tween()
	tween.tween_property(count_label, "scale", Vector2.ONE, 0.25).from(Vector2(1.5, 1.5)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_main_game_started() -> void:
	empty()
	update_count_label()
