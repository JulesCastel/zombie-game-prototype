extends CharacterBody2D

#unit is pixels per second
var MOVE_SPEED = 250
var BULLET_SPEED = 3000

@onready var raycast = $RayCast2D

@onready var HUD = get_node("/root/world/player/Camera2D/HUD")
@onready var weapon = get_node("/root/world/player/weaponNode")

@export var maxHealth: float = 100.0
@onready var health = maxHealth: set = _set_health
signal healthUpdated(health)
signal killed()
@onready var invincibilityTimer = $invincibilityTimer
@onready var hitAnimation = $CollisionShape2D/hitEffect
var knockback = Vector2.ZERO

var slowWalkingSound = preload("res://sounds/player sounds/slowWalking.ogg")
var normalWalkingSound = preload("res://sounds/player sounds/normalWalking.ogg")
var fastWalkingSound = preload("res://sounds/player sounds/fastWalking.ogg")


func _ready():
	$walkingSound.stream = normalWalkingSound
	await get_tree().process_frame
	get_tree().call_group("zombies", "setPlayer", self)
	HUD.healthAmount = health

func damage(amount):
	if invincibilityTimer.is_stopped():
		invincibilityTimer.start()
		_set_health(health - amount)
		HUD.healthAmount -= amount
		hitAnimation.play("hitAnimation")
		hitAnimation.queue("rest")

func _set_health(value):
	var previousHealth = health
	health = clamp(value, 0, maxHealth)
	if health != previousHealth:
		emit_signal("healthUpdated", health)
		if health <= 0:
			kill()
			emit_signal("killed")

#delta is time between frames
func _process(_delta):
	
	get_tree().call_group("zombies", "setPlayer", self)
	

func _physics_process(_delta): 
	look_at(get_global_mouse_position())
	
	move()
	
	knockback = lerp(knockback, Vector2.ZERO, 0.2)
	

func move():
	
	var moveVector = Vector2()
	if Input.is_action_pressed("moveUp"):
		moveVector.y -= 1
	if Input.is_action_pressed("moveDown"):
		moveVector.y += 1
	if Input.is_action_pressed("moveLeft"):
		moveVector.x -= 1
	if Input.is_action_pressed("moveRight"):
		moveVector.x += 1
	
	if (moveVector.x != 0 or moveVector.y != 0) and !$walkingSound.playing:
		$walkingSound.play()
		
	if (moveVector.x == 0 and moveVector.y == 0) and $walkingSound.playing:
		$walkingSound.playing = false
	
	if weapon.isReloading:
		if $walkingSound.stream != slowWalkingSound:
			$walkingSound.stream = slowWalkingSound
		MOVE_SPEED = 150
	
	if !weapon.isReloading:
		MOVE_SPEED = 250
		if !Input.is_action_pressed("sprint") and $walkingSound.stream != normalWalkingSound:
			$walkingSound.stream = normalWalkingSound
		if Input.is_action_pressed("sprint"):
			HUD.sprintIcon.visible = true
			MOVE_SPEED = 450
		if Input.is_action_just_pressed("sprint"):
			$walkingSound.stream = fastWalkingSound
		if Input.is_action_just_released("sprint"):
			HUD.sprintIcon.visible = false
			$walkingSound.stream = normalWalkingSound
			MOVE_SPEED = 250
	
	moveVector = moveVector.normalized()
# warning-ignore:return_value_discarded
	set_velocity(moveVector * MOVE_SPEED)
	move_and_slide()
	
# warning-ignore:return_value_discarded
	set_velocity(moveVector + knockback)
	move_and_slide()

#restarts the scene when killed, triggered by collision with zombie
func kill():
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
