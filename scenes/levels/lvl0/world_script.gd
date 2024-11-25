extends Node

@onready var sun = $Sun
@onready var moon = $Moon
var dayLengthScaler = .01

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	moveSunMoon(delta)

func moveSunMoon(delta):
	sun.rotate(sun.basis.x, delta * dayLengthScaler)
	moon.rotate(sun.basis.x, delta * dayLengthScaler)


func _on_sphererigid_property_list_changed() -> void:
	pass # Replace with function body.
