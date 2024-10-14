extends StaticBody2D

@export var animation_player: AnimationPlayer
@export var explosion_particles: CPUParticles2D

@export var nodes_to_remove: Array
@export var hit_zone: Area2D

@export var explosion_shake: Shake2D

@export var hit_audio: Audio2D
@export var fuse_audio: Audio2D
@export var explosion_audio: Audio2D

var health := 150
var is_igniting := false

func _on_area_2d_area_entered(bullet):
	if is_igniting or not bullet is BasicBullet:
		return
		
	animation_player.play("hit")
	health -= bullet.damage
	check_health()
	bullet.on_death()
	
func check_health():
	if health <= 0:
		is_igniting = true
		animation_player.stop()
		animation_player.play("fuse")
		$FuseTimer.start()
		fuse_audio.start()
	else:
		hit_audio.start()

func _on_fuse_timer_timeout():
	explosion_particles.emitting = true
	explosion_audio.start()
	explosion_shake.start()
	
	for current_node in nodes_to_remove:
		get_node(current_node).queue_free()
	
	for body in hit_zone.get_overlapping_bodies():
		var distance = body.global_position - global_position
		if body.has_meta("is_container"):
			body.linear_velocity = distance.normalized() * distance.length() * 3
			body.last_hit_by_bullet = false
			body.health -= 15000 / distance.length()
			body.check_health()
		elif body is Tank:
			var damage = 13000 / distance.length()
			var stats_component: StatsBasic = body.components["stats"]
			stats_component.damage_tank(damage)
		elif body.has_meta("is_canister") and body != self:
			body.health -= 25000 / distance.length()
			body.check_health()
	
	$DeathTimer.start()
	
func _on_death_timer_timeout():
	queue_free()
