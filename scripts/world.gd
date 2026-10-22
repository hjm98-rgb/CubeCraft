extends Node3D

## 3D 渲染验证场景：展示方块人模型 + 方块世界，证明渲染器工作。
## 后续版本将在此基础上加入真实的游戏玩法内容。

var _block_meshes: Dictionary = {}
var _orbit_yaw := 0.6
var _orbit_pitch := 0.32
var _orbit_dist := 16.0
var _dragging := false
var _last_mouse := Vector2.ZERO

@onready var camera: Camera3D = $Camera3D
@onready var hint_label: Label = $HintLabel

func _ready() -> void:
	I18n.language_changed.connect(_refresh_texts)
	_refresh_texts()
	_block_meshes = {
		"grass": load("res://assets/models/block_grass.obj"),
		"dirt": load("res://assets/models/block_dirt.obj"),
		"stone": load("res://assets/models/block_stone.obj"),
		"wood": load("res://assets/models/block_wood.obj"),
		"leaves": load("res://assets/models/block_leaves.obj"),
		"sand": load("res://assets/models/block_sand.obj"),
		"water": load("res://assets/models/block_water.obj"),
	}
	_build_ground()
	_build_tree()
	_build_hills()
	_spawn_player()
	_update_camera()

func _refresh_texts() -> void:
	hint_label.text = I18n.trk("controls_hint")
	$BackButton.text = I18n.trk("world_back")
	$WorldTitle.text = I18n.trk("world_title")
	$WorldHint.text = I18n.trk("world_hint")

func _build_ground() -> void:
	var terrain := Node3D.new()
	terrain.name = "Terrain"
	add_child(terrain)
	for x in range(-5, 6):
		for z in range(-5, 6):
			var key: String = "grass"
			if (x * x + z * z) % 7 == 0:
				key = "dirt"
			elif (x + z) % 11 == 0:
				key = "stone"
			if abs(x) <= 1 and abs(z) <= 1:
				key = "sand"
			if x == 0 and z == 0:
				continue
			var mi := MeshInstance3D.new()
			mi.mesh = _block_meshes[key]
			mi.position = Vector3(float(x), -1.0, float(z))
			terrain.add_child(mi)

func _build_tree() -> void:
	var trees := Node3D.new()
	trees.name = "Trees"
	add_child(trees)
	for pos in [Vector3(-4, 0, 3), Vector3(4, 0, -3), Vector3(2, 0, 4)]:
		var trunk := MeshInstance3D.new()
		trunk.mesh = _block_meshes["wood"]
		trunk.position = pos
		trees.add_child(trunk)
		var trunk2 := MeshInstance3D.new()
		trunk2.mesh = _block_meshes["wood"]
		trunk2.position = pos + Vector3(0, 1, 0)
		trees.add_child(trunk2)
		for offset in [Vector3(0, 2, 0), Vector3(-1, 2, 0), Vector3(1, 2, 0), Vector3(0, 2, -1), Vector3(0, 2, 1), Vector3(0, 3, 0)]:
			var leaf := MeshInstance3D.new()
			leaf.mesh = _block_meshes["leaves"]
			leaf.position = pos + offset
			trees.add_child(leaf)

func _build_hills() -> void:
	var hills := Node3D.new()
	hills.name = "Hills"
	add_child(hills)
	for i in range(12):
		var x := float(-5 + (i % 4) * 3)
		var z := float(-5 + int(i / 4) * 3)
		if x == 0.0 and z == 0.0:
			continue
		var mi := MeshInstance3D.new()
		mi.mesh = _block_meshes["dirt"]
		mi.position = Vector3(x, -2.0, z)
		hills.add_child(mi)
		var top := MeshInstance3D.new()
		top.mesh = _block_meshes["grass"]
		top.position = Vector3(x, -1.0, z)
		hills.add_child(top)

func _spawn_player() -> void:
	var player := MeshInstance3D.new()
	player.name = "Player"
	var mesh: Mesh = load("res://assets/models/steve.obj")
	player.mesh = mesh
	player.scale = Vector3.ONE * 0.07
	player.position = Vector3(0, -0.9, 0)
	add_child(player)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			_last_mouse = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_orbit_dist = clampf(_orbit_dist - 1.2, 5.0, 40.0)
			_update_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_orbit_dist = clampf(_orbit_dist + 1.2, 5.0, 40.0)
			_update_camera()
	elif event is InputEventMouseMotion and _dragging:
		var rel: Vector2 = event.position - _last_mouse
		_last_mouse = event.position
		_orbit_yaw -= rel.x * 0.01
		_orbit_pitch = clampf(_orbit_pitch - rel.y * 0.01, -1.3, 1.3)
		_update_camera()

func _update_camera() -> void:
	var target := Vector3(0, 0.5, 0)
	var offset := Vector3(
		cos(_orbit_pitch) * sin(_orbit_yaw),
		sin(_orbit_pitch),
		cos(_orbit_pitch) * cos(_orbit_yaw)
	) * _orbit_dist
	camera.position = target + offset
	camera.look_at(target, Vector3.UP)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
