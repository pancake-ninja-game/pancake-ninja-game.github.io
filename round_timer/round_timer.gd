class_name RoundTimerScene
extends Node2D

signal timeout
signal tick(time_passed: int)
signal difficulty_change_requested(difficulty_index: int)

var time_left: int

@onready var timer: Timer = $Timer
@onready var label: Label = $Label


func _ready() -> void:
	reset()


func reset() -> void:
	time_left = globals.ROUND_LENGTH
	update_label()


func start() -> void:
	timer.start()


func stop() -> void:
	timer.stop()


func update_label() -> void:
	label.text = str(time_left)


func emit_tick() -> void:
	var t: int = globals.ROUND_LENGTH - time_left
	tick.emit(t)


func _on_timer_timeout() -> void:
	time_left -= 1
	update_label()
	emit_tick()
	
	if time_left == 0:
		timeout.emit()
		timer.stop()
		return
		
	var time_passed: int = globals.ROUND_LENGTH - time_left
	var difficulty_end: int = 0
	for i: int in len(globals.DIFFICULTY_DURATIONS) - 1:
		difficulty_end += globals.DIFFICULTY_DURATIONS[i]
		if time_passed == difficulty_end:
			difficulty_change_requested.emit(i + 1)


func _on_main_game_started() -> void:
	reset()
	start()


func _on_main_game_ended() -> void:
	stop()
