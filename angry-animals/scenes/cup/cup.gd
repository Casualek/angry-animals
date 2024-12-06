extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func die() -> void:
	animation_player.play("vanish")


func _animation_finished(anim_name: StringName) -> void:
	SignalManager.on_cup_destroyed.emit()
	queue_free()
