class_name BladeTrail
extends Line2D

# How long a point of the trail lives, in seconds
const LIFETIME: float = 0.12
const MIN_SEGMENT_LENGTH: float = 4

var elapsed: float = 0
var point_times: Array[float] = []


func _ready() -> void:
	# Thin and transparent at the tail, full width and bright at the blade
	width_curve = Curve.new()
	width_curve.add_point(Vector2(0, 0))
	width_curve.add_point(Vector2(1, 1))
	
	gradient = Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 0))
	gradient.set_color(1, Color(1, 1, 1, 0.9))


func _input(event: InputEvent) -> void:
	# Touch drags arrive here too, as emulated mouse motion
	var motion: InputEventMouseMotion = make_input_local(event) as InputEventMouseMotion
	if !motion:
		return
	
	var count: int = get_point_count()
	if count == 0 or get_point_position(count - 1).distance_to(motion.position) > MIN_SEGMENT_LENGTH:
		add_point(motion.position)
		point_times.append(elapsed)


func _process(delta: float) -> void:
	elapsed += delta
	
	while !point_times.is_empty() and elapsed - point_times[0] > LIFETIME:
		remove_point(0)
		point_times.pop_front()
