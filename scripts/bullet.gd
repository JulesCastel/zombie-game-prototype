extends RigidBody2D

var knockbackVector = Vector2.ZERO
var pBloodParticles := preload("res://objects/bloodGunshotParticles.tscn")

var player = null

var baseBulletDamage = 10
var bulletDamage = baseBulletDamage

func _on_bullet_body_entered(body):
	if !body.is_in_group("player") and !("bullet" in body.name):
		if "zombie" in body.name:
			body.doKnockback()
			body.damage(bulletDamage)
			var bloodEffect := pBloodParticles.instantiate()
			bloodEffect.position = position
			bloodEffect.rotation_degrees = global_rotation_degrees
			bloodEffect.emitting = true
			get_parent().add_child(bloodEffect)
		queue_free()

func _on_despawnTimer_timeout():
	queue_free()
