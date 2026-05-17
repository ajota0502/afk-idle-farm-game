extends Node2D

const Constants = preload("res://Constants.gd")

var main

@onready var menu = $"../CanvasLayer/Menu/TextureRect"
@onready var menu1asset = load("res://Sprites/menu.png")
@onready var menu2asset = load("res://Sprites/menu2.png")
@onready var play_content = $"../CanvasLayer/Menu/Play/Content"
@onready var options_content = $"../CanvasLayer/Menu/Options/Content"
@onready var quit_content = $"../CanvasLayer/Menu/Quit/Content"

# =========================
# STATE
# =========================
var menu_flag = 0
var menu_timer = 0.0
var base_play_size := Vector2()
var base_options_size := Vector2()
var base_quit_size := Vector2()

# =========================
# READY
# =========================
func _ready() -> void:
	base_play_size = play_content.size
	base_options_size = options_content.size
	base_quit_size = quit_content.size

# =========================
# PROCESS (UI UPDATES)
# =========================
func _process(delta: float) -> void:
	# Menu texture animation
	menu_timer += delta
	if menu_flag == 0:
		if menu_timer >= Constants.MENU_TOGGLE_INTERVAL:
			menu_timer = 0
			menu.texture = menu2asset
			menu_flag = 1
	else:
		if menu_timer >= Constants.MENU_TOGGLE_INTERVAL:
			menu_timer = 0
			menu.texture = menu1asset
			menu_flag = 0
	
	update_tooltip()

# =========================
# INVENTORY
# =========================
func _on_inventory_button_pressed():
	main.inventory_menu.visible = !main.inventory_menu.visible

func update_inventory_menu():
	if main.wheat_inventory_label:
		main.wheat_inventory_label.text = "x" + str(int(GameManager.wheat))

	if main.corn_inventory_label:
		main.corn_inventory_label.text = "x" + str(int(GameManager.corn))

	if main.carrot_inventory_label:
		main.carrot_inventory_label.text = "x" + str(int(GameManager.carrot))

# =========================
# SHOP
# =========================
func _on_shop_pressed():
	main.shop_panel.visible = !main.shop_panel.visible

# =========================
# TOOLTIPS
# =========================
func show_tooltip(text):
	main.tooltip.text = text
	main.tooltip.visible = true

func hide_tooltip():
	main.tooltip.visible = false

func update_tooltip():
	if main.tooltip == null:
		return
	
	if main.tooltip.visible:
		var mouse_pos = get_viewport().get_mouse_position()
		main.tooltip.position = mouse_pos + Vector2(20, 20)

# =========================
# MENU HOVER ANIMATIONS
# =========================
func hover_in(content, base_size):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(content, "custom_minimum_size", base_size * 1.1, 0.1)

func hover_out(content, base_size):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(content, "custom_minimum_size", base_size, 0.1)

func _on_play_mouse_entered():
	hover_in(play_content, base_play_size)

func _on_play_mouse_exited():
	hover_out(play_content, base_play_size)

func _on_options_mouse_entered():
	hover_in(options_content, base_options_size)

func _on_options_mouse_exited():
	hover_out(options_content, base_options_size)

func _on_quit_mouse_entered():
	hover_in(quit_content, base_quit_size)

func _on_quit_mouse_exited():
	hover_out(quit_content, base_quit_size)

# =========================
# MENU BUTTONS
# =========================
func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	main.menu.visible = false
	main.xp_bar.visible = true
