## I18n 自动加载单例：负责语言切换与 UI 文本刷新
extends Node

signal language_changed

var _strings: RefCounted = load("res://i18n/strings.gd")
var _current_lang: String = "zh_CN"

func _ready() -> void:
	_current_lang = Settings.language

## 获取当前语言下的文本
func trk(key: String) -> String:
	return _strings.get_text(_current_lang, key)

## 切换语言（真实生效：立即发出信号，所有界面刷新文本）
func set_language(lang: String) -> void:
	if lang == _current_lang:
		return
	_current_lang = lang
	Settings.language = lang
	Settings.save_settings()
	language_changed.emit()

func get_language() -> String:
	return _current_lang

func get_language_name(lang: String) -> String:
	return _strings.LANGS.get(lang, lang)
