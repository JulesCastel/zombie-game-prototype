extends CPUParticles2D

func _on_particleTimer_timeout():
	queue_free()
