extends CanvasLayer

const SWIPE_DISTANCE: int = 230

var demo_tween: Tween

@onready var swipe_demo: Line2D = $SwipeDemo
@onready var demo_perfect: Label = $DemoPerfect
@onready var swipe_start_y: float = swipe_demo.position.y


# Loops a blade swiping down, then up, through the cut zone, each followed by the reward
func play_demo() -> void:
	demo_perfect.modulate.a = 0
	
	var swipe_end_y: float = swipe_start_y + SWIPE_DISTANCE
	demo_tween = create_tween().set_loops()
	add_demo_swipe(swipe_start_y, swipe_end_y)
	add_demo_swipe(swipe_end_y, swipe_start_y)


func add_demo_swipe(from_y: float, to_y: float) -> void:
	demo_tween.tween_interval(0.5)
	demo_tween.tween_callback(func() -> void:
		# The streak's bright head is its last point, so flip it to lead upward swipes
		swipe_demo.scale.y = signf(to_y - from_y)
		swipe_demo.show())
	demo_tween.tween_property(swipe_demo, "position:y", to_y, 0.4).from(from_y).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	demo_tween.tween_callback(swipe_demo.hide)
	demo_tween.tween_property(demo_perfect, "modulate:a", 0.0, 0.8).from(1.0)


func _on_visibility_changed() -> void:
	if demo_tween:
		demo_tween.kill()
	
	if visible:
		play_demo()
