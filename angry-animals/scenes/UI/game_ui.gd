extends Control

const MAIN = preload("res://scenes/main/main.tscn")

@onready var lvl_label: Label = $MarginContainer/VB1/lvlLabel
@onready var attempts_label: Label = $MarginContainer/VB1/attemptsLabel
@onready var game_sound: AudioStreamPlayer = $gameSound
@onready var vb_2: VBoxContainer = $MarginContainer/VB2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vb_2.hide()
	lvl_label.text = "LEVEL: %s" % Scorer.get_lvl_selected()
	update_attempts(0)
	SignalManager.on_score_updated.connect(update_attempts)
	SignalManager.on_lvl_complete.connect(lvl_complete)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu") == true:
		get_tree().change_scene_to_packed(MAIN)

func update_attempts(attempts: int) -> void:
	attempts_label.text = "ATTEMPTS: %s" % attempts

func lvl_complete() -> void:
	vb_2.show()
	game_sound.play()
