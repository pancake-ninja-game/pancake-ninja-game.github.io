class_name StackScene
extends Node2D

signal stack_completed

const CAPACITY: int = 5
const SHEET_SPACING: int = 5
const DONE_COLOR: Color = Color(1, 0.85, 0.2)
# Finished jelly rolls stay at the bottom of the stack, packed tight, so the
# stack grows taller with every roll while a normal round stays below the line
const ROLL_SHEET_SPACING: int = 2
const ROLL_GAP: int = 3
const ROLL_HEIGHT: int = ROLL_SHEET_SPACING * CAPACITY + ROLL_GAP
# Every other roll gets a stronger tint so the rolls can be told apart
const ROLL_TINT_ALPHAS: Array[float] = [0.6, 0.35]
# Stacked sheets are drawn centered on their position, so their visible edges
# end up this far below it
const STACKED_EDGE_Y: int = 33

# Sheets of the roll being built
var sheets: Array[SheetScene] = []
var rolled_sheets: Array[SheetScene] = []
var rolls_completed: int = 0

@onready var sheet_stacked_sound: AudioStreamPlayer2D = $SheetStackedSound
@onready var stack_completed_sound: AudioStreamPlayer2D = $StackCompletedSound
@onready var count_label: Label = $CountLabel
@onready var rolls_label: Label = $RollsLabel


func is_full() -> bool:
	return len(sheets) >= CAPACITY


func rolls_height() -> int:
	return rolls_completed * ROLL_HEIGHT


func stack_sheet(sheet: SheetScene) -> void:
	sheets.append(sheet)
	sheet.reparent(self)

	sheet.move_to_stack(Vector2(
		0,
		0 - rolls_height() - SHEET_SPACING * len(sheets),
	))

	if is_full():
		roll_up()
		stack_completed_sound.play()
		stack_completed.emit()
	else:
		sheet_stacked_sound.play()

	update_count_label()


# Packs the finished sheets into a jelly roll on top of the earlier rolls
func roll_up() -> void:
	var tint_alpha: float = ROLL_TINT_ALPHAS[rolls_completed % len(ROLL_TINT_ALPHAS)]

	for i: int in len(sheets):
		sheets[i].roll_into(Vector2(
			0,
			0 - rolls_height() - ROLL_SHEET_SPACING * (i + 1),
		), tint_alpha)

	rolled_sheets.append_array(sheets)
	sheets.clear()
	rolls_completed += 1
	update_rolls_label()


func empty() -> void:
	for s: SheetScene in sheets:
		s.queue_free()
	sheets.clear()

	for s: SheetScene in rolled_sheets:
		s.queue_free()
	rolled_sheets.clear()

	rolls_completed = 0
	update_rolls_label()


func update_count_label() -> void:
	# A roll was just finished and no new sheets are stacked yet
	if sheets.is_empty() and rolls_completed > 0:
		count_label.text = "JELLY ROLL!"
		count_label.self_modulate = DONE_COLOR
	else:
		count_label.text = "SHEETS %d/%d" % [len(sheets), CAPACITY]
		count_label.self_modulate = Color.WHITE

	pop(count_label)


# Keeps the roll count next to the top roll, so it climbs with the stack
func update_rolls_label() -> void:
	rolls_label.visible = rolls_completed > 0
	if !rolls_label.visible:
		return

	rolls_label.text = "x%d" % rolls_completed

	var top_roll_y: float = STACKED_EDGE_Y - rolls_height() + ROLL_HEIGHT - ROLL_SHEET_SPACING * (CAPACITY + 1) / 2.0
	rolls_label.position.y = top_roll_y - rolls_label.size.y / 2

	pop(rolls_label)


func pop(label: Label) -> void:
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "scale", Vector2.ONE, 0.25).from(Vector2(1.5, 1.5)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_main_game_started() -> void:
	empty()
	update_count_label()
