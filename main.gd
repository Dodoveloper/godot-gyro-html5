extends Node2D


onready var sensor_component := $SensorComponent as SensorComponent
onready var os_label := $Control/OS as Label
onready var gyro_label := $Control/Gyroscope as Label
# iOS only
onready var enable_gyro_btn := $Control/EnableGyro as CheckButton


func _ready() -> void:
	# update UI
	enable_gyro_btn.hide()
	os_label.text = "OS: %s" % sensor_component.os_string
	# plug-in logic
	if sensor_component.os_string == "iOS":
		enable_gyro_btn.show()


# Used to trigger the iOS permission logic
func _on_EnableGyro_toggled(button_pressed: bool) -> void:
	sensor_component.is_permission_asked = button_pressed


# Here is where the sensor data is received, in case of success
func _on_SensorComponent_gyroscope_triggered(coords: Vector3) -> void:
	var text := "(%.2f, %.2f, %.2f)" % [coords.x, coords.y, coords.z]
	gyro_label.text = "Gyroscope: %s" % text


# Updates the checkbox button based on the outcome of the request
func _on_SensorComponent_ios_permission_requested(value: bool) -> void:
	enable_gyro_btn.pressed = value
