extends Node2D

var zombie1 = preload ("res://objects/zombie.tscn")
@onready var HUD = get_node("/root/world/player/Camera2D/HUD")
var cursorCrosshair = preload("res://sprites/crosshair.png")

func _ready():
	Input.set_custom_mouse_cursor(cursorCrosshair)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	HUD.zombiesInWave = 5 * HUD.waveCount
	HUD.zombiesLeftInWave = HUD.zombiesInWave + 3

func _on_enemySpawnTimer_timeout():
	
	if HUD.zombiesInWave > 0:
		var enemyPosition = Vector2(randf_range(-2500, 3200), randf_range(-850, 2150))
		
		while (enemyPosition.x < 640 and enemyPosition.x > -80) and (enemyPosition.y < 360 and enemyPosition.y > -45):
			enemyPosition = Vector2(randf_range(-160, 670), randf_range(-90, 390))
		
		HUD.zombiesInWave -= 1
		
		Global.instanceNode(zombie1, enemyPosition, self, "zombie")
	
	if HUD.zombiesLeftInWave <= 0:
		HUD.nextWaveButton.visible = true
	
