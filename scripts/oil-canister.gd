extends StaticBody2D

@export var animation_player: AnimationPlayer
@export var explosion_particles: CPUParticles2D

@export var nodes_to_remove: Array
@export var hit_zone: Area2D

@export var hit_sounds: Array[AudioStream]
@export var fuse_audio_player: AudioStreamPlayer2D

@export var explosion_sound: AudioStream
@export var explosion_shake: Shake2D

var health := 50
var is_igniting := false

func _on_area_2d_body_entered(body):
	if not body.has_meta("is_bullet") or is_igniting:
		return
	
	animation_player.play("hit")
	health -= body.bullet_damage
	body.on_death()
	check_health()

func check_health():
	if health <= 0:
		is_igniting = true
		animation_player.stop()
		animation_player.play("fuse")
		$FuseTimer.start()
		fuse_audio_player.play()
	else:
		Helper.play_external_sound(self, hit_sounds.pick_random(), 5)	

func _on_fuse_timer_timeout():
	explosion_particles.emitting = true
	Helper.play_external_sound(self, explosion_sound, 10)
	explosion_shake.start()
	
	for current_node in nodes_to_remove:
		get_node(current_node).queue_free()
	
	for body in hit_zone.get_overlapping_bodies():
		var distance = body.global_position - global_position
		if body.has_meta("is_container"):
			body.linear_velocity = distance.normalized() * distance.length() * 3
			body.last_hit_by_bullet = false
			body.health -= 10000 / distance.length()
			body.check_health()
		elif body is CharacterBody2D:
			#body.stats_node.health -= 10000 / distance.length()
			pass
		elif body.has_meta("is_canister") and body != self:
			body.health -= 10000 / distance.length()
			body.check_health()
	
	$DeathTimer.start()
	
func _on_death_timer_timeout():
	queue_free()
