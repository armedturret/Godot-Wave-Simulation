extends Node3D

@export
var speed: float = 1.0
@export
var speed_fast: float = 3.0
@export
var mouse_sens: float = 1.0

var _rmb_held: bool = false
var _shift_held: bool = false
var _mouse_vec: Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
        _rmb_held = event.is_pressed()
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if _rmb_held else Input.MOUSE_MODE_VISIBLE
        get_viewport().set_input_as_handled()
    elif event is InputEventMouseMotion:
        _mouse_vec = event.relative
        get_viewport().set_input_as_handled()
    elif event is InputEventKey and event.keycode == KEY_SHIFT:
        _shift_held = event.is_pressed()
        get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
    var in_vec := Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
    var vert_ax := Input.get_axis("move_down","move_up")
    in_vec = in_vec.normalized() * delta
    vert_ax *= delta

    if _shift_held:
        in_vec *= speed_fast
        vert_ax *= speed_fast
    else:
        in_vec *= speed
        vert_ax *= speed

    position += in_vec.x * global_transform.basis.x
    position -= in_vec.y * global_transform.basis.z
    position += vert_ax * global_transform.basis.y

    if _rmb_held and _mouse_vec != Vector2.ZERO:
        rotation.y -= _mouse_vec.x * mouse_sens
        rotation.x = clamp(rotation.x - _mouse_vec.y * mouse_sens, -1.5, 1.5)
        _mouse_vec = Vector2.ZERO
