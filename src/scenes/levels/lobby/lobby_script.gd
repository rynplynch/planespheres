extends Node3D

@export var cam_speed = 0.1

# all parts related to the camera
# the camera itself
var cam : Camera3D
# the target the camera points towards
var cam_target : Node3D
# spring the changes distance to the camera target
var cam_spring : SpringArm3D
# the direction the player wants to move the camera
var cam_dir = Vector3(0,1,0)
var cam_dis = -20
var cam_height = 5
# rigid body of the spehere in the scene
var sphere_rigid : RigidBody3D
# randomly move the sphere around in the scene after the timer
var timer = 0
var alarm = 1
var rand_dir = Vector3.ZERO
var mag = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	cam_target = $"CameraTarget"
	cam_spring = $"CameraTarget/SpringArm3D"
	cam = $"CameraTarget/SpringArm3D/Camera3D"
	
	sphere_rigid = $"Player/player/Sphere-rigid"
	
	# camera starts at a distance of -3 meters
	cam_spring.spring_length = cam_dis
	cam_spring.position.y = cam_height
	# set cameras z equal to this
	#cam.position.x = -15
	cam.rotation.x = -0.2
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	
	if (timer < alarm):
		timer = 0
		generateRandDir()
		
	moveSphere(delta)
	var xRot = cam_target.rotation.y
		
	#cam_target.rotation.x = lerp(xRot, xRot + 1, delta * cam_speed * cam_dir.x)
	cam_target.rotation.y = lerp(xRot, xRot + 1, delta * cam_speed * cam_dir.y)	

func generateRandDir():
	rand_dir = Vector3(randf_range(0,1), randf_range(0,1), randf_range(0,1))

func moveSphere(delta):
	sphere_rigid.apply_torque(rand_dir * delta * mag)
