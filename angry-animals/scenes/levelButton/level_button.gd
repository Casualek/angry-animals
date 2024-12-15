extends TextureButton

const HOVER_SCALE: Vector2 = Vector2(1.1, 1.1)
const DEFAULT_SCALE: Vector2 = Vector2(1.0, 1.0)

@export var level_number: int = 1

@onready var level_button: TextureButton = $"."
@onready var level_num: Label = $MarginContainer/VBoxContainer/levelNum
@onready var score: Label = $MarginContainer/VBoxContainer/score

var _level_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_num.text = str(level_number)
	var _best = Scorer.get_best(str(level_number))
	score.text = str(_best)
	_level_scene = load("res://scenes/level/level%s.tscn" % level_number)

func _on_pressed() -> void:
	Scorer.set_lvl_selected(level_number)
	get_tree().change_scene_to_packed(_level_scene)

func _on_mouse_entered() -> void:
	level_button.scale = HOVER_SCALE

func _on_mouse_exited() -> void:
	level_button.scale = DEFAULT_SCALE
