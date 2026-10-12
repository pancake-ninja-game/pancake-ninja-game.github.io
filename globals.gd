extends Node

const GRAVITY: int = 1200

const WINDOW_WIDTH: int = 1152
const WINDOW_HEIGHT: int = 648

const ROUND_LENGTH: int = 30
# Seconds per level, adding up to ROUND_LENGTH
const LEVEL_DURATIONS: Array[int] = [8, 8, 7, 7]
const LEVEL_NAMES: Array[String] = ["Commissioning", "Ramp-up", "Production", "F1"]
const LEVEL_LIME_SPEEDS: Array[int] = [200, 300, 400]

var sheet_width: float
var sheet_height: float
