extends Node2D

const Constants = preload("res://Constants.gd")

var main
var upgrade_manager
var game_manager

var current_choices = []
var xp_rainbow_tween

# =========================
# REFERENCES
# =========================
@onready var level_panel = $"../CanvasLayer/LevelUpPanel"
@onready var level_title = $"../CanvasLayer/LevelUpPanel/LevelTitle"
@onready var level_subtitle = $"../CanvasLayer/LevelUpPanel/Subtitle"
@onready var choice1 = $"../CanvasLayer/LevelUpPanel/Choice1"
@onready var choice2 = $"../CanvasLayer/LevelUpPanel/Choice2"
@onready var choice3 = $"../CanvasLayer/LevelUpPanel/Choice3"
@onready var choice1_icon = $"../CanvasLayer/LevelUpPanel/Choice1/Icon"
@onready var choice2_icon = $"../CanvasLayer/LevelUpPanel/Choice2/Icon"
@onready var choice3_icon = $"../CanvasLayer/LevelUpPanel/Choice3/Icon"
@onready var choice1_text = $"../CanvasLayer/LevelUpPanel/Choice1/Text"
@onready var choice2_text = $"../CanvasLayer/LevelUpPanel/Choice2/Text"
@onready var choice3_text = $"../CanvasLayer/LevelUpPanel/Choice3/Text"
@onready var level_up_sound = $"../AudioStreamPlayer2D2"

# =========================
# READY
# =========================
func _ready() -> void:
	level_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	level_panel.visible = false
	
	choice1.pressed.connect(func(): pick_upgrade(0))
	choice2.pressed.connect(func(): pick_upgrade(1))
	choice3.pressed.connect(func(): pick_upgrade(2))
	choice1.mouse_entered.connect(func(): main.ui_manager.show_tooltip(get_choice_tooltip(0)))
	choice2.mouse_entered.connect(func(): main.ui_manager.show_tooltip(get_choice_tooltip(1)))
	choice3.mouse_entered.connect(func(): main.ui_manager.show_tooltip(get_choice_tooltip(2)))
	choice1.mouse_exited.connect(func(): main.ui_manager.hide_tooltip())
	choice2.mouse_exited.connect(func(): main.ui_manager.hide_tooltip())
	choice3.mouse_exited.connect(func(): main.ui_manager.hide_tooltip())
	
	choice1.process_mode = Node.PROCESS_MODE_ALWAYS
	choice2.process_mode = Node.PROCESS_MODE_ALWAYS
	choice3.process_mode = Node.PROCESS_MODE_ALWAYS

# =========================
# LEVEL UP SCREEN
# =========================
func show_level_up_screen(new_level, choices):
	if xp_rainbow_tween:
		xp_rainbow_tween.kill()
		xp_rainbow_tween = null
		main.xp_bar.modulate = Color.WHITE
	
	main.xp_visual = main.xp_bar.max_value
	main.xp_bar.value = main.xp_bar.max_value
	main.showing_levelup = true
	main.frozen_xp_bar = true
	
	main.xp_bar.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Rainbow tween
	xp_rainbow_tween = get_tree().create_tween()
	xp_rainbow_tween.set_loops()
	xp_rainbow_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	xp_rainbow_tween.tween_property(main.xp_bar, "modulate", Color(1, 0.5, 1), 0.3)
	xp_rainbow_tween.tween_property(main.xp_bar, "modulate", Color(0.5, 1, 1), 0.3)
	xp_rainbow_tween.tween_property(main.xp_bar, "modulate", Color(1, 1, 0.5), 0.3)
	
	current_choices = choices
	level_up_sound.play()
	
	await show_level_up_animation(new_level)
	
	get_tree().paused = true
	level_panel.visible = true
	
	level_title.text = "LEVEL " + str(new_level) + "!"
	level_subtitle.text = "Choose your upgrade:"
	
	rainbow_title()
	
	# Set icons and text (only if choices exist)
	if choices.size() >= 1:
		choice1_icon.texture = main.upgrade_icons[choices[0]["id"]]
		
	if choices.size() >= 2:
		choice2_icon.texture = main.upgrade_icons[choices[1]["id"]]
		
	if choices.size() >= 3:
		choice3_icon.texture = main.upgrade_icons[choices[2]["id"]]
		

func pick_upgrade(index):
	# Safety check: ensure index is valid
	if index < 0 or index >= current_choices.size():
		print("Invalid upgrade index:", index, "available choices:", current_choices.size())
		return
	
	var upgrade = current_choices[index]
	game_manager.apply_upgrade(upgrade["id"])
	
	level_panel.visible = false
	main.showing_levelup = false
	
	get_tree().paused = false
	
	if xp_rainbow_tween:
		xp_rainbow_tween.kill()
	
	main.xp_bar.modulate = Color.WHITE
	main.xp_bar.process_mode = Node.PROCESS_MODE_INHERIT

func get_choice_tooltip(index) -> String:
	if index < 0 or index >= current_choices.size():
		return ""
	return current_choices[index]["text"]

# =========================
# ANIMATIONS
# =========================
func show_level_up_animation(level):
	var label = Label.new()
	label.text = "LEVEL UP!\nLv." + str(level)
	label.scale = Vector2(0.5, 0.5)
	label.modulate = Color(1, 1, 0, 0)
	
	main.add_child(label)
	label.global_position = get_viewport_rect().size / 2 - Vector2(100, 50)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(label, "scale", Vector2(1.5, 1.5), 0.3)
	tween.parallel().tween_property(label, "modulate:a", 1.0, 0.2)
	
	tween.tween_interval(0.4)
	
	tween.tween_property(label, "modulate:a", 0.0, 0.3)
	tween.tween_property(label, "scale", Vector2(2, 2), 0.3)
	
	await tween.finished
	label.queue_free()

func show_level_up_popup(new_level, bonus):
	var label = Label.new()
	label.text = "LEVEL UP!\nLv." + str(new_level)
	label.scale = Vector2(1.5, 1.5)
	label.modulate = Color(1, 1, 0)
	
	main.add_child(label)
	label.global_position = main.player.global_position + Vector2(-40, -80)
	
	for i in range(30):
		await get_tree().create_timer(0.05).timeout
		label.global_position.y -= 2
		label.modulate.a -= 0.03
	
	label.queue_free()

func rainbow_title():
	var tween = create_tween()
	tween.set_loops()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	tween.tween_property(level_title, "modulate", Color(1, 0.5, 1), 0.3)
	tween.tween_property(level_title, "modulate", Color(0.5, 1, 1), 0.3)
	tween.tween_property(level_title, "modulate", Color(1, 1, 0.5), 0.3)
