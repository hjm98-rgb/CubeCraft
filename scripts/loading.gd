extends Control

@onready var progress_bar: ProgressBar = $Center/VBox/ProgressBar
@onready var status_label: Label = $Center/VBox/StatusLabel

func _ready() -> void:
	I18n.language_changed.connect(_refresh_texts)
	_refresh_texts()
	await _do_load()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _refresh_texts() -> void:
	$Center/VBox/TitleLabel.text = I18n.trk("app_title")
	$AuthorLabel.text = I18n.trk("author_label")
	$VersionLabel.text = I18n.trk("version_label")
	status_label.text = I18n.trk("loading")

func _do_load() -> void:
	for i in range(101):
		progress_bar.value = i
		status_label.text = I18n.trk("loading") + "  " + str(i) + "%"
		if i % 8 == 0:
			await get_tree().process_frame
	status_label.text = I18n.trk("loading_done")
	await get_tree().create_timer(0.35).timeout
