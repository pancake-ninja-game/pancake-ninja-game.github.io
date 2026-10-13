class_name OperatorScene
extends Node2D

const DEFAULT_POSITION_X: int = 400
const MOVE_SPEED: int = 400
# Start walking once the mouse is this far away, then keep walking until within
# STOP_DISTANCE. The gap between the two keeps the operator from flickering
# between walking and idle when the mouse hovers near the threshold.
const MOVE_THRESHOLD: int = 60
const STOP_DISTANCE: int = 10

var movement_enabled: bool = true
var cutting_enabled: bool = false

var position_x: int = DEFAULT_POSITION_X
var direction: int = 1 # 1 = right, -1 = left
var is_walking: bool = false
var is_sword_up: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var cutting_sound: AudioStreamPlayer2D = $CuttingSound
@onready var cut_line: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	animated_sprite.animation = "walking"


func _process(delta: float) -> void:
	if movement_enabled:
		update_position(delta)
		update_sword()


func update_position(delta: float) -> void:
	var target_x: float = get_global_mouse_position().x
	var diff_x: float = target_x - position.x
	var distance: float = abs(diff_x)

	var threshold: int = STOP_DISTANCE if is_walking else MOVE_THRESHOLD
	if distance <= threshold:
		stop_walking_animation()
		return

	var d: int = sign(diff_x)
	if d != direction:
		animated_sprite.flip_h = d < 0
		direction = d

	# Don't step past the mouse, or the operator jitters back and forth around it
	position.x += direction * min(MOVE_SPEED * delta, distance)
	play_walking_animation()


# The sword follows the mouse: raised above the cut line, lowered below it, so
# swiping through the line swings it
func update_sword() -> void:
	var sword_up: bool = get_global_mouse_position().y < cut_line.global_position.y
	if sword_up == is_sword_up:
		return
	
	is_sword_up = sword_up
	if is_walking:
		animated_sprite.play(sword_animation("walking"))
	else:
		animated_sprite.animation = sword_animation("idle")


# The variant of an animation that matches the current sword position
func sword_animation(base_name: String) -> StringName:
	return base_name + "_up" if is_sword_up else base_name


func play_walking_animation() -> void:
	if is_walking:
		return
	
	is_walking = true
	animated_sprite.play(sword_animation("walking"))

func stop_walking_animation() -> void:
	if !is_walking:
		return
	
	animated_sprite.animation = sword_animation("idle")
	animated_sprite.stop()
	is_walking = false

func _on_mouse_entered() -> void:
	cutting_sound.play()
