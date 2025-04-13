extends CharacterBody2D

@export var MOVE_SPEED = 200

@onready var raycast = $RayCast2D
@onready var navigationAgent = $NavigationAgent2D

# Raycasts to use for checking for obstacles
@onready var frontRay = $frontRay
@onready var leftRay = $leftRay
@onready var rightRay = $rightRay

var player = null

@export var maxHealth = 20
var health = maxHealth
var knockback = Vector2.ZERO

@onready var HUD = get_node("/root/world/player/Camera2D/HUD")

@export var baseDamage = 10
var totalDamage = baseDamage

#var velocity = Vector2.ZERO

@onready var healthBar = $healthBarNode/Node2D/healthBar

var pBloodParticles := preload("res://objects/bloodGunshotParticles.tscn")

func damage(amount):
	healthBar.visible = true
	health -= amount
	healthBar.value = health

func _ready():
	var tree = get_tree()

	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
	
	healthBar.max_value = maxHealth
	healthBar.value = health
	
	add_to_group("zombies")

func _process(_delta):
	if health <= 0:
		healthBar.visible = false
		HUD.killCount += 1
		HUD.zombiesLeftInWave -= 1
		queue_free()

#delta is time between frames
func _physics_process(delta): 
	if player == null:
		return
	
	knockback = knockback.move_toward(Vector2.ZERO, 1800 * delta)
	set_velocity(knockback)
	move_and_slide()
	knockback = velocity
	
	var vectorToPlayer = player.global_position - global_position
	vectorToPlayer = vectorToPlayer.normalized()
	global_rotation = atan2(vectorToPlayer.y, vectorToPlayer.x)
# warning-ignore:return_value_discarded
	if frontRay.is_colliding():
		# Try to go around the obstacle to the left
		if !leftRay.is_colliding():
			set_velocity(Vector2((-1 * vectorToPlayer.y), vectorToPlayer.x) * MOVE_SPEED)
			move_and_slide()
		# If that doesn't work, try to go around the obstacle to the right
		elif !rightRay.is_colliding():
# warning-ignore:return_value_discarded
			set_velocity(Vector2(vectorToPlayer.y, (-1 * vectorToPlayer.x)) * MOVE_SPEED)
			move_and_slide()
	
# warning-ignore:return_value_discarded
	#moves towards player if not colliding against an obstacle
	if !raycast.is_colliding():
		set_velocity(vectorToPlayer * MOVE_SPEED)
		move_and_slide()
	
	if raycast.is_colliding():
		var coll = raycast.get_collider()
		if coll != null and coll.name == "player":
			coll.knockback = global_position.direction_to(coll.global_position) * 800
			coll.damage(totalDamage)

func setPlayer(p):
	player = p

func doKnockback():
	knockback = (global_position - player.global_position)

