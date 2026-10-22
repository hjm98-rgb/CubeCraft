## Settings 自动加载单例：设置持久化（user://settings.cfg）并真实生效
extends Node

signal settings_changed

const SETTINGS_PATH := "user://settings.cfg"

var language: String = "zh_CN"
var master_volume: float = 0.8
var fullscreen: bool = false
var graphics_quality: int = 1  # 0=低 1=中 2=高
var resolution: Vector2i = Vector2i(1280, 720)
var window_width: int = 1280
var window_height: int = 720

func _ready() -> void:
	load_settings()
	apply_all()

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	language = cfg.get_value("general", "language", "zh_CN")
	master_volume = cfg.get_value("audio", "master_volume", 0.8)
	fullscreen = cfg.get_value("video", "fullscreen", false)
	graphics_quality = cfg.get_value("video", "graphics_quality", 1)
	window_width = cfg.get_value("video", "window_width", 1280)
	window_height = cfg.get_value("video", "window_height", 720)
	resolution = Vector2i(window_width, window_height)

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("general", "language", language)
	cfg.set_value("audio", "master_volume", master_volume)
	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.set_value("video", "graphics_quality", graphics_quality)
	cfg.set_value("video", "window_width", resolution.x)
	cfg.set_value("video", "window_height", resolution.y)
	cfg.save(SETTINGS_PATH)

func set_resolution(w: int, h: int) -> void:
	resolution = Vector2i(w, h)
	window_width = w
	window_height = h

func apply_all() -> void:
	# 音量：真实作用于主总线
	var bus := AudioServer.get_bus_index("Master")
	if bus >= 0:
		AudioServer.set_bus_volume_db(bus, linear_to_db(clampf(master_volume, 0.0, 1.0)))
	# 窗口与分辨率
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(resolution)
	# 画质（作用于全屏抗锯齿与阴影质量，低端设备更流畅）
	match graphics_quality:
		0:
			get_viewport().msaa_3d = Viewport.MSAA_DISABLED
			get_viewport().scaling_3d_scale = 0.75
		1:
			get_viewport().msaa_3d = Viewport.MSAA_2X
			get_viewport().scaling_3d_scale = 1.0
		2:
			get_viewport().msaa_3d = Viewport.MSAA_4X
			get_viewport().scaling_3d_scale = 1.0
	settings_changed.emit()
