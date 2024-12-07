extends RigidBody2D

enum ANIMAL_STATE {READY, DRAG, RELEASE}

const DRAG_LIMIT_MAX: Vector2 = Vector2(0, 100)
const DRAG_LIMIT_MIN: Vector2 = Vector2(-100, -40)
const IMPULSE_MULTIPLIER: float = 20.0
const IMPULSE_MAX: float = 1200.0

var _last_collision_count: int = 0
var _arrow_scale_x: float = 0.0
var _start: Vector2 = Vector2.ZERO
var _drag_start: Vector2 = Vector2.ZERO
var _dragged_vector: Vector2 = Vector2.ZERO
var _last_dragged_vector: Vector2 = Vector2.ZERO
var _state: ANIMAL_STATE = ANIMAL_STATE.READY

@onready var stretch: AudioStreamPlayer2D = $stretch
@onready var arrow: Sprite2D = $arrow
@onready var launch: AudioStreamPlayer2D = $launch
@onready var kick: AudioStreamPlayer2D = $kick

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_arrow_scale_x = arrow.scale.x
	arrow.hide()
	_start = position
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	update(delta)

func get_impulse() -> Vector2:
	return _dragged_vector * -1 * IMPULSE_MULTIPLIER

func animal_die() -> void:
	queue_free()

func _screen_exited() -> void:
	SignalManager.on_animal_died.emit()
	animal_die()

func update(delta: float) -> void:
	match _state:
		ANIMAL_STATE.DRAG:
			update_drag()
		ANIMAL_STATE.RELEASE:
			update_flight()

func get_dragged_vector(gmp: Vector2) -> Vector2:
	return get_global_mouse_position() - _drag_start

func drag_in_limits() -> void:
	_last_dragged_vector = _dragged_vector
	_dragged_vector.x = clampf(_dragged_vector.x, DRAG_LIMIT_MIN.x, DRAG_LIMIT_MAX.x)
	_dragged_vector.y = clampf(_dragged_vector.y, DRAG_LIMIT_MIN.y, DRAG_LIMIT_MAX.y)
	position = _start + _dragged_vector

func update_drag() -> void:
	if detect_release() == true:
		return
	var gmp = get_global_mouse_position()
	_dragged_vector = get_dragged_vector(gmp)
	play_stretch_sound()
	drag_in_limits()
	scale_arrow()

func scale_arrow() -> void:
	var imp_lngth = get_impulse().length()
	var perc = imp_lngth / IMPULSE_MAX
	arrow.scale.x = (_arrow_scale_x * perc) + _arrow_scale_x
	arrow.rotation = (_start - position).angle()

func set_drag() -> void:
	_drag_start = get_global_mouse_position()
	arrow.show()
	
func set_released() -> void:
	arrow.hide()
	freeze = false
	apply_central_impulse(get_impulse())
	launch.play()
	SignalManager.on_attempt_made.emit()

func set_new_state(new_state: ANIMAL_STATE) -> void:
	_state = new_state
	if _state == ANIMAL_STATE.RELEASE:
		set_released()
	elif _state == ANIMAL_STATE.DRAG:
		set_drag()

func play_stretch_sound() -> void:
	if(_last_dragged_vector - _dragged_vector).length() > 0:
		if stretch.playing == false:
			stretch.play()

func detect_release() -> bool:
	if _state == ANIMAL_STATE.DRAG:
		if Input.is_action_just_released("drag") == true:
			set_new_state(ANIMAL_STATE.RELEASE)
			return true
	return false

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if _state == ANIMAL_STATE.READY and event.is_action_pressed("drag"):
		set_new_state(ANIMAL_STATE.DRAG)

func _on_sleeping_state_changed() -> void:
	if sleeping == true:
		var cb = get_colliding_bodies()
		if cb.size() > 0:
			cb[0].die()
		call_deferred("animal_die")
		SignalManager.on_animal_died.emit()

func play_collision() -> void:
	if _last_collision_count == 0 and get_contact_count() > 0 and kick.playing == false:
		kick.play()
	_last_collision_count = get_contact_count()

func update_flight() -> void:
	#play_collision()
	pass

func _on_body_entered(body: Node) -> void:
	if kick.playing == false:
		kick.play()
