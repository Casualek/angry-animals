extends Node2D

const ANIMAL = preload("res://scenes/animal/animal.tscn")

@onready var animal_start: Marker2D = $animalStart

const MAIN = preload("res://scenes/main/main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_animal_died.connect(add_animal)
	add_animal()

func add_animal() -> void:
	var animal = ANIMAL.instantiate()
	animal.position = animal_start.position
	add_child(animal)
