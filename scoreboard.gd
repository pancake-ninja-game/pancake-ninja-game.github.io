class_name Scoreboard
extends Control

@onready var score: Label = $Score
@onready var difficulty: Label = $Difficulty


func update_score(yield_: int, ppm: int) -> void:
	score.text = "Yield: %d%%\nPPM: %d" % [yield_, ppm]


func update_difficulty(difficulty_index: int) -> void:
	difficulty.text = "Difficulty:\n%s" % [globals.DIFFICULTY_NAMES[difficulty_index]]


func _on_score_changed(yield_: int, ppm: int) -> void:
	update_score(yield_, ppm)


func _on_round_timer_difficulty_change_requested(difficulty_index: int) -> void:
	update_difficulty(difficulty_index)

	# Pulse from the left edge and flash yellow to match the announcement
	difficulty.pivot_offset = Vector2(0, difficulty.size.y / 2)
	var tween: Tween = difficulty.create_tween()
	tween.tween_property(difficulty, "scale", Vector2(1.25, 1.25), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(difficulty, "scale", Vector2.ONE, 0.3)
	tween.parallel().tween_property(difficulty, "modulate", Color.WHITE, 1.5).from(Feedback.ANNOUNCE_COLOR)


func _on_main_reset_state_requested() -> void:
	update_score(0, 0)
	update_difficulty(0)
