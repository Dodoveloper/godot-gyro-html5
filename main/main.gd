extends Node2D


const TILT_TRESHOLD := 5.0
const SCROLL_STEP := 3  # pixels
const SCROLL_SPEED := 200.0

onready var parallax_background := $ParallaxBackground as ParallaxBackground
onready var gyro_component := $GyroComponent as GyroComponent
onready var background := $ParallaxBackground/ParallaxLayer1/Background as Sprite
onready var os_label := $"%OSLabel" as Label
onready var gyro_label := $"%GyroscopeLabel" as Label
# iOS only
onready var enable_gyro_btn := $"%EnableGyroBtn" as CheckButton


func _ready() -> void:
	# update UI
	enable_gyro_btn.hide()
	os_label.text = "OS: %s" % gyro_component.os_string
	# plug-in logic
	if gyro_component.os_string == "iOS":
		enable_gyro_btn.show()


func _physics_process(delta: float) -> void:
	var dir := int(Input.is_action_pressed("ui_left")) - int(Input.is_action_pressed("ui_right"))
	parallax_background.scroll_offset.x = lerp(parallax_background.scroll_offset.x,
			parallax_background.scroll_offset.x + SCROLL_STEP * dir,
			SCROLL_SPEED * delta)


# Used to trigger the iOS permission logic
func _on_EnableGyro_toggled(button_pressed: bool) -> void:
	gyro_component.is_permission_asked = button_pressed


# Here is where the sensor data is received, in case of success
func _on_SensorComponent_gyroscope_triggered(coords: Vector3) -> void:
	# display text on the UI
	var text := "(%.2f, %.2f, %.2f)" % [coords.x, coords.y, coords.z]
	gyro_label.text = "Gyroscope: %s" % text
	# camera-moving logic
	var relative_scroll: float = coords.y if abs(coords.y) > TILT_TRESHOLD else 0.0
	parallax_background.scroll_offset.x -= relative_scroll


# Updates the checkbox button based on the outcome of the request
func _on_SensorComponent_ios_permission_requested(is_granted: bool) -> void:
	enable_gyro_btn.pressed = is_granted
	enable_gyro_btn.disabled = true
