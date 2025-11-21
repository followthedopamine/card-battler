class_name DamageParticleEmitter extends Control

@export var particle_lifetime = 1.2

## Used to size the emission_box
var emission_box_extents := Vector3.ZERO
var emission_shape_offset := Vector3.ZERO

var elapsed_time := 0.0

@onready var viewport_scene = preload("res://scenes/play_panel/damage_particle/DamageParticleViewport.tscn")
@onready var particle_scene = preload("res://scenes/play_panel/damage_particle/DamageParticleParticle.tscn")

# @onready var viewport_scene: SubViewport = $SubViewport

func set_emission_box(box_size: Vector2):
	emission_box_extents = Vector3(box_size.x *.5, box_size.y/4, 1.0)
	emission_shape_offset = Vector3(0, -(box_size.y * .5), 0)

func set_emission_offset(offset: Vector2):
	emission_shape_offset = Vector3(offset.x, offset.y, 0)

func emit_particle(text: String, colour = Color.WHITE, is_number = true):
	var new_viewport: SubViewport = viewport_scene.instantiate()
	add_child(new_viewport)
	
	new_viewport.size = Vector2(256, 256)
	new_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	if is_number:
		text = text.rstrip("0").rstrip(".")

	new_viewport.set_label(text)
	new_viewport.set_colour(colour)

	var new_particle: GPUParticles2D = particle_scene.instantiate()
	new_particle.lifetime = particle_lifetime

	new_particle.texture = new_viewport.get_texture()
	new_particle.process_material.emission_box_extents = emission_box_extents
	new_particle.process_material.emission_shape_offset = emission_shape_offset

	add_child(new_particle)

	new_particle.emitting = true

	var cleanup_timer: SceneTreeTimer = get_tree().create_timer(particle_lifetime)
	cleanup_timer.timeout.connect(func(): _on_cleanup_timer_timeout(new_viewport, new_particle))

func _on_cleanup_timer_timeout(viewport_scene_to_delete: SubViewport, particle_scene_to_delete: GPUParticles2D):
	viewport_scene_to_delete.queue_free()
	particle_scene_to_delete.queue_free()

func _process(delta: float) -> void:
	elapsed_time += delta
