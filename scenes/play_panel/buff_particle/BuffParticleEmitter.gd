class_name BuffParticleEmitter extends Control

@export var particle_lifetime = 1.2
@export var particle_scene: PackedScene

## Used to size the emission_box
var emission_box_extents := Vector3.ZERO
var emission_shape_offset := Vector3.ZERO

var elapsed_time := 0.0

func set_emission_box(box_size: Vector2):
	emission_box_extents = Vector3(box_size.x *.5, box_size.y/4, 1.0)
	emission_shape_offset = Vector3(0, -(box_size.y * .5), 0)

func set_emission_offset(offset: Vector2):
	emission_shape_offset = Vector3(offset.x, offset.y, 0)

func emit_particle(texture: Texture2D = null):
	var new_particle: GPUParticles2D = particle_scene.instantiate()
	if texture:
		new_particle.texture = texture

	new_particle.lifetime = particle_lifetime
	new_particle.process_material.emission_box_extents = emission_box_extents
	new_particle.process_material.emission_shape_offset = emission_shape_offset

	add_child(new_particle)

	new_particle.emitting = true

	var cleanup_timer: SceneTreeTimer = get_tree().create_timer(particle_lifetime)
	cleanup_timer.timeout.connect(func(): _on_cleanup_timer_timeout(new_particle))

func _on_cleanup_timer_timeout(particle_scene_to_delete: GPUParticles2D):
	particle_scene_to_delete.queue_free()

func _process(delta: float) -> void:
	elapsed_time += delta
