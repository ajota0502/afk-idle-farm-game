extends CanvasLayer

@onready var tooltip = $UpgradeTooltip

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	if tooltip.visible:
		tooltip.position = get_viewport().get_mouse_position() + Vector2(20, 20)

func show_tooltip(text):
	tooltip.text = text
	tooltip.visible = true

func hide_tooltip():
	tooltip.visible = false
