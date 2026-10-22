extends Control

@onready var title_label: Label = $Center/VBox/TitleBox/TitleLabel
@onready var subtitle_label: Label = $Center/VBox/TitleBox/SubtitleLabel
@onready var author_label: Label = $AuthorLabel
@onready var version_label: Label = $VersionLabel
@onready var start_btn: Button = $Center/VBox/MenuBox/StartButton
@onready var settings_btn: Button = $Center/VBox/MenuBox/SettingsButton
@onready var quit_btn: Button = $Center/VBox/MenuBox/QuitButton
@onready var lang_btn: Button = $LangButton
@onready var settings_panel: Control = $SettingsPanel
@onready var lang_option: OptionButton = $SettingsPanel/Margin/VBox/LangRow/LangOption
@onready var volume_slider: HSlider = $SettingsPanel/Margin/VBox/VolumeRow/VolumeSlider
@onready var fullscreen_check: CheckButton = $SettingsPanel/Margin/VBox/FullscreenRow/FullscreenCheck
@onready var quality_option: OptionButton = $SettingsPanel/Margin/VBox/QualityRow/QualityOption
@onready var resolution_option: OptionButton = $SettingsPanel/Margin/VBox/ResolutionRow/ResolutionOption

const _tr_keys := [
	"btn_start", "btn_settings", "btn_quit", "settings_title",
	"settings_language", "settings_volume", "settings_fullscreen",
	"settings_quality", "settings_resolution", "btn_back", "btn_save",
	"app_title", "app_subtitle", "author_label", "version_label",
	"world_back",
]

func _ready() -> void:
	I18n.language_changed.connect(_refresh_texts)
	Settings.settings_changed.connect(_refresh_setting_controls)
	start_btn.pressed.connect(_on_start_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	lang_btn.pressed.connect(_on_lang_pressed)
	lang_option.item_selected.connect(_on_lang_selected)
	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	quality_option.item_selected.connect(_on_quality_selected)
	resolution_option.item_selected.connect(_on_resolution_selected)
	$SettingsPanel/Margin/VBox/ButtonRow/BackButton.pressed.connect(_close_settings)
	$SettingsPanel/Margin/VBox/ButtonRow/SaveButton.pressed.connect(_save_and_close_settings)
	_build_lang_option()
	_refresh_texts()
	_refresh_setting_controls()

func _build_lang_option() -> void:
	lang_option.clear()
	for code in I18n._strings.LANGS:
		lang_option.add_item(I18n.get_language_name(code), lang_option.item_count)
		lang_option.set_item_metadata(lang_option.item_count - 1, code)
	var idx := 0
	for i in range(lang_option.item_count):
		if lang_option.get_item_metadata(i) == I18n.get_language():
			idx = i
	lang_option.select(idx)

func _refresh_texts() -> void:
	title_label.text = I18n.trk("app_title")
	subtitle_label.text = I18n.trk("app_subtitle")
	author_label.text = I18n.trk("author_label")
	version_label.text = I18n.trk("version_label")
	start_btn.text = I18n.trk("btn_start")
	settings_btn.text = I18n.trk("btn_settings")
	quit_btn.text = I18n.trk("btn_quit")
	lang_btn.text = I18n.trk("btn_language") + "： " + I18n.get_language_name(I18n.get_language())
	$SettingsPanel/Margin/VBox/SettingsTitle.text = I18n.trk("settings_title")
	$SettingsPanel/Margin/VBox/LangRow/LangLabel.text = I18n.trk("settings_language")
	$SettingsPanel/Margin/VBox/VolumeRow/VolumeLabel.text = I18n.trk("settings_volume")
	$SettingsPanel/Margin/VBox/FullscreenRow/FullscreenLabel.text = I18n.trk("settings_fullscreen")
	$SettingsPanel/Margin/VBox/QualityRow/QualityLabel.text = I18n.trk("settings_quality")
	$SettingsPanel/Margin/VBox/ResolutionRow/ResolutionLabel.text = I18n.trk("settings_resolution")
	$SettingsPanel/Margin/VBox/ButtonRow/BackButton.text = I18n.trk("btn_back")
	$SettingsPanel/Margin/VBox/ButtonRow/SaveButton.text = I18n.trk("btn_save")
	_build_lang_option()

func _refresh_setting_controls() -> void:
	volume_slider.set_value_no_signal(Settings.master_volume * 100.0)
	fullscreen_check.set_pressed_no_signal(Settings.fullscreen)
	quality_option.select(Settings.graphics_quality)
	match Vector2i(Settings.window_width, Settings.window_height):
		Vector2i(1280, 720):
			resolution_option.select(0)
		Vector2i(1920, 1080):
			resolution_option.select(1)
		Vector2i(2560, 1440):
			resolution_option.select(2)
		_:
			resolution_option.select(0)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_settings_pressed() -> void:
	settings_panel.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_lang_pressed() -> void:
	# 依次循环切换语言：中文 → English → 日本語
	var langs := ["zh_CN", "en", "ja"]
	var next: String = langs[0]
	var cur := I18n.get_language()
	if langs.has(cur):
		next = langs[(langs.find(cur) + 1) % langs.size()]
	I18n.set_language(next)

func _on_lang_selected(index: int) -> void:
	var code: String = lang_option.get_item_metadata(index)
	I18n.set_language(code)

func _on_volume_changed(value: float) -> void:
	Settings.master_volume = clampf(value / 100.0, 0.0, 1.0)
	Settings.apply_all()

func _on_fullscreen_toggled(on: bool) -> void:
	Settings.fullscreen = on
	Settings.apply_all()

func _on_quality_selected(index: int) -> void:
	Settings.graphics_quality = index
	Settings.apply_all()

func _on_resolution_selected(index: int) -> void:
	match index:
		0:
			Settings.set_resolution(1280, 720)
		1:
			Settings.set_resolution(1920, 1080)
		2:
			Settings.set_resolution(2560, 1440)
	Settings.apply_all()

func _close_settings() -> void:
	Settings.save_settings()
	settings_panel.visible = false

func _save_and_close_settings() -> void:
	Settings.save_settings()
	Settings.apply_all()
	settings_panel.visible = false
