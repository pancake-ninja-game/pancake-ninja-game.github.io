extends Node

const GRAVITY: int = 1200

const WINDOW_WIDTH: int = 1152
const WINDOW_HEIGHT: int = 648

const ROUND_LENGTH: int = 30
# Seconds per difficulty, adding up to ROUND_LENGTH
const DIFFICULTY_DURATIONS: Array[int] = [8, 8, 7, 7]
const DIFFICULTY_NAMES: Array[String] = ["Commissioning", "Ramp-up", "Production", "F1"]

var sheet_width: float
var sheet_height: float
