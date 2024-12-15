extends Node

const DEFAULT_SCORE: int = 1000
const  SCORE_PATH = "user://animals.json"

var _lvl_selected: int = 1
var _lvl_scores: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_to_disc()

func set_lvl_selected(ls: int) -> void:
	_lvl_selected = ls

func get_lvl_selected() -> int:
	return _lvl_selected

func check(lvl: String) -> void:
	if _lvl_scores.has(lvl) == false:
		_lvl_scores[lvl] = DEFAULT_SCORE

func set_score_for_lvl(score: int, lvl: String) -> void:
	check(lvl)
	if _lvl_scores[lvl] > score:
		_lvl_scores[lvl] = score
		save()

func get_best(lvl: String) -> int:
	check(lvl)
	return _lvl_scores[lvl]

func save():
	var file = FileAccess.open(SCORE_PATH, FileAccess.WRITE)
	var socre_json_str = JSON.stringify(_lvl_scores)
	file.store_string(socre_json_str)

func load_to_disc():
	var file = FileAccess.open(SCORE_PATH, FileAccess.READ)
	if file == null:
		save()
	else:
		var data = file.get_as_text()
		_lvl_scores = JSON.parse_string(data)
