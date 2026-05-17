extends Node

# =========================
# SPAWN INTERVALS (seconds)
# =========================
const WHEAT_SPAWN_INTERVAL = 3.0
const CORN_SPAWN_INTERVAL = 5.0
const CARROT_SPAWN_INTERVAL = 7.5

const WHEAT_MIN_INTERVAL = 0.01
const CORN_MIN_INTERVAL = 0.01
const CARROT_MIN_INTERVAL = 0.01

# =========================
# UPGRADE COSTS
# =========================
const WHEAT_UPGRADE_COST = 25
const CORN_UPGRADE_COST = 100
const CARROT_UPGRADE_COST = 250

const WHEAT_SPEED_COST = 30
const CORN_SPEED_COST = 120
const CARROT_SPEED_COST = 300

# =========================
# UPGRADE MULTIPLIERS
# =========================
const UPGRADE_COST_MULTIPLIER = 1.4
const SPEED_COST_MULTIPLIER = 1.5
const AUTO_HARVEST_COST_MULTIPLIER = 1.7
const SPEED_REDUCTION = 0.9

# =========================
# CROP SCALE & COLORS
# =========================
const WHEAT_SCALE = Vector2(0.15, 0.15)
const CORN_SCALE = Vector2(0.1, 0.1)
const CARROT_SCALE = Vector2(0.15, 0.15)

const CRIT_COLOR = Color(1, 0.8, 0)
const FLOATING_TEXT_FADE_SPEED = 0.05
const FLOATING_TEXT_MOVE_SPEED = 2

# =========================
# ANIMATIONS
# =========================
const MENU_TOGGLE_INTERVAL = 0.1
const FLOAT_TEXT_FRAMES = 20
const FLOAT_TEXT_TIMER = 0.05

# =========================
# POOL SIZES
# =========================
const FLOATING_TEXT_POOL_SIZE = 50
const SPRITE_POOL_SIZE = 100
