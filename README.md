# Godot Gyroscope on HTML5
This is a Godot 3.5 demo demonstrating how to get gyroscope data from mobile devices on an HTML5 export.

## Description
The project leverages Godot's JavaScript [bridge](https://docs.godotengine.org/en/3.5/classes/class_javascript.html) to call JS APIs, specifically to detect the [device orientation](https://developer.mozilla.org/en-US/docs/Web/API/Device_orientation_events/Detecting_device_orientation).
This is needed for games that are deployed on the web, since calling `Input.get_gyroscope()` works only on native applications.

It supports both Android and iOS platforms.

## Requirements
You can access gyroscope data only in [secure contexts](https://developer.mozilla.org/en-US/docs/Web/Security/Secure_Contexts) (HTTPS).

Also, iOS devices require explicit user interaction before allowing access to gyroscope data from an HTML5 application.
That's why the demo has a toggle button on the top left, which is visible only on such platforms.

![image](https://github.com/Dodoveloper/godot-gyro-html5/assets/17781050/af5549a6-a1b6-4d04-b302-8bb1e24b840a)

When enabled, a popup requesting permission will appear on screen, and after selecting _Allow_ you should get access to gyroscope data on iOS.

## Usage
There is a custom class called `GyroComponent`, which takes care of requesting permissions to access the gyroscope (if needed) and gathering its data.

Just instantiate the component scene in your game scene (the one which will get the data and handle it) and connect to its signals:
- `ios_permission_requested(is_granted)`: emitted after the user has interacted with the permission popup;
- `gyroscope_triggered(coords)`: emitted every time the JS event is triggered, the `coords` argument is a `Vector3` holding [orientation data](https://developer.mozilla.org/en-US/docs/Web/API/Device_orientation_events/Orientation_and_motion_data_explained). `x` holds the rotation around the **X** axis, `y` on the **y** axis and so on.

You can check out the `main` scene to see how to use the component. It has a bunch of planets on different parallax layers and it shows how to tilt the content horizontally based on sensor data.

# Asset attributions
- Project Icon: <a href="https://www.flaticon.com/free-icons/gyroscope" title="gyroscope icons">Gyroscope icons created by Freepik - Flaticon</a>
- Planets are kindly provided by [Kenney](https://www.kenney.nl/assets/planets)
