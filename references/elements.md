# MML element and attribute reference

Generated from the official `mml.xsd` schema in the mml-io/mml repository. Attribute groups are shared sets of attributes that several elements reuse. Each element section lists which groups it uses plus its own attributes.

## Shared attribute groups

### coreattrs

Attributes common to all elements.

| attribute | type | description |
|---|---|---|
| `id` | xs:ID | A unique identifier for the element, used for selection and manipulation through scripting. It must be unique within the document. |
| `class` | xs:NMTOKENS | A space-separated list of class names that can be used for scripting purposes. |

### clickable

This attribute group indicates that this element is clickable. The onclick attribute is a script expression that is executed when the element is clicked. Events are also dispatched to "click" listeners.

| attribute | type | description |
|---|---|---|
| `clickable` | xs:boolean | Whether the element is clickable (true) or not (false). Default value is true. If false, any click will pass through as if the element was not present. |
| `onclick` | Script | A script expression that is executed when the element is clicked. Events are also dispatched to "click" event listeners. (event: `click|MMLClickEvent`) |

### transformable

Attributes for positioning, rotating and scaling in 3D.

| attribute | type | description |
|---|---|---|
| `x` | xs:float | The position of the element along the X-axis in meters. Default value is 0. |
| `y` | xs:float | The position of the element along the Y-axis in meters. Default value is 0. |
| `z` | xs:float | The position of the element along the Z-axis in meters. Default value is 0. |
| `rx` | xs:float | The rotation of the element around the X-axis in degrees. Default value is 0. |
| `ry` | xs:float | The rotation of the element around the Y-axis in degrees. Default value is 0. |
| `rz` | xs:float | The rotation of the element around the Z-axis in degrees. Default value is 0. |
| `sx` | xs:float | The scale of the element along the X-axis. Default value is 1. |
| `sy` | xs:float | The scale of the element along the Y-axis. Default value is 1. |
| `sz` | xs:float | The scale of the element along the Z-axis. Default value is 1. |
| `visible` | xs:boolean | Whether the element is visible (true) or hidden (false) in the scene. Default value is true. |
| `socket` | xs:string | The name of a bone in the parent element's skeletal mesh to which this element will be attached. If not specified, the element will attach to the origin of its parent. |

### shadows

Attributes for cast and receiving shadows

| attribute | type | description |
|---|---|---|
| `cast-shadows` | xs:boolean | Whether the element casts shadows onto other elements (true) or not (false). Default value is true. |

### debuggable

The debug attribute is a boolean that indicates whether the element should be drawn with debug information.

| attribute | type | description |
|---|---|---|
| `debug` | xs:boolean | A boolean that indicates whether the element should be drawn with debug information (e.g. axes helper). Default value is false. |

### collideable

The collide attribute is a boolean that indicates whether a collision test should be performed on this element.

| attribute | type | description |
|---|---|---|
| `collide` | xs:boolean | Whether or not this object should participate in collision detection by other systems. Default value is true. If set to true, the object will be considered for collision tests. |
| `collision-interval` | xs:integer | If set, the time in milliseconds between user collision events being sent to the element. By default collision events are not sent. |
| `oncollisionstart` | Script | A script expression to be executed when a user starts colliding with the element. Receives a `CollisionStartEvent`. (event: `collisionstart|MMLCollisionStartEvent`) |
| `oncollisionmove` | Script | A script expression to be executed when a user moves the collision point they are colliding at on the element. Receives a `CollisionMoveEvent`. (event: `collisionmove|MMLCollisionMoveEvent`) |
| `oncollisionend` | Script | A script expression to be executed when a user stops colliding with the element. Receives a `CollisionEndEvent`. (event: `collisionend|MMLCollisionEndEvent`) |

### colorable

The color attribute is a string that indicates the color of the element.

| attribute | type | description |
|---|---|---|
| `color` | xs:string | The color of the element. Accepts color values in formats such as "#FF0000", "red", or "rgb(255,0,0)". If not specified, the default color is "white". |

## Elements

### `<html>`



| attribute | type | description |
|---|---|---|
| `id` | xs:ID |  |

Allowed children: `<head>`, `<body>`

### `<head>`

The `head` element is used to define the document's metadata and can contain `script` elements.

| attribute | type | description |
|---|---|---|
| `id` | xs:ID |  |
| `profile` | URI |  |

Allowed children: `<script>`

### `<script>`

The `script` element is used to define script expressions that are executed when the document is loaded.

| attribute | type | description |
|---|---|---|
| `id` | xs:ID |  |
| `type` | ContentType |  |
| `src` | URI |  |
| `defer` | one of: defer |  |

### `<body>`

The `body` element is used to define the document's content.

Uses attribute groups: `coreattrs`

| attribute | type | description |
|---|---|---|
| `onload` | Script |  |
| `onunload` | Script |  |

### `<m-group>`

The `m-group` element can contain other MML tags, allowing all of them to be transformed as single item.

Uses attribute groups: `debuggable`, `transformable`, `coreattrs`

### `<m-cube>`

The `m-cube` element is a primitive 3D cube that can be coloured. It is often used for debugging or initial development purposes.

Uses attribute groups: `debuggable`, `transformable`, `collideable`, `colorable`, `coreattrs`, `clickable`, `shadows`

| attribute | type | description |
|---|---|---|
| `width` | xs:float | The width of the cube in meters. Default value is 1 meter. |
| `height` | xs:float | The height of the cube in meters. Default value is 1 meter. |
| `depth` | xs:float | The depth of the cube in meters. Default value is 1 meter. |
| `opacity` | xs:float | The opacity of the cube, ranging from 0 (completely transparent) to 1 (completely opaque). Default value is 1. |

### `<m-sphere>`

The `m-sphere` element is a primitive 3D sphere that can be coloured. It is often used for debugging or initial development purposes.

Uses attribute groups: `debuggable`, `transformable`, `collideable`, `colorable`, `coreattrs`, `clickable`, `shadows`

| attribute | type | description |
|---|---|---|
| `radius` | xs:float | The radius of the sphere in meters. Default value is 0.5 meters. |
| `opacity` | xs:float | The opacity of the sphere, ranging from 0 (completely transparent) to 1 (completely opaque). Default value is 1. |

### `<m-cylinder>`

The `m-cylinder` element is a primitive 3D cylinder that can be coloured. It is often used for debugging or initial development purposes.

Uses attribute groups: `debuggable`, `transformable`, `collideable`, `colorable`, `coreattrs`, `clickable`, `shadows`

| attribute | type | description |
|---|---|---|
| `radius` | xs:float | The radius of the cylinder in meters. Default value is 0.5 meters. |
| `height` | xs:float | The height of the cylinder in meters. |
| `opacity` | xs:float | The opacity of the cylinder, ranging from 0 (completely transparent) to 1 (completely opaque). Default value is 1. |

### `<m-light>`

The `m-light` element is a light that supports various types (e.g. `point`, `spotlight`) and can be coloured.

Uses attribute groups: `debuggable`, `transformable`, `colorable`, `coreattrs`

| attribute | type | description |
|---|---|---|
| `intensity` | xs:float | The intensity of the light in candela (cd). Default value is 1. |
| `distance` | xs:float | The maximum distance in meters that the light will affect objects. Objects beyond this distance will not be illuminated. Default value is 0, which means the light has no maximum distance. |
| `angle` | xs:float | The angle of the light in degrees (only applicable to spotlight type). Default value is 45. |
| `enabled` | xs:boolean | Whether the light is enabled (true) or disabled (false). Default value is true. |
| `cast-shadows` | xs:boolean | Whether the light cast shadows (true) or not (false). Default value is true. |
| `type` | one of: point, spotlight |  |

### `<m-plane>`

The `m-plane` element is a primitive 3D plane that can be coloured.

Uses attribute groups: `debuggable`, `transformable`, `collideable`, `colorable`, `coreattrs`, `clickable`, `shadows`

| attribute | type | description |
|---|---|---|
| `width` | xs:float | The width of the plane in meters. Default value is 1 meter. |
| `height` | xs:float | The height of the plane in meters. Default value is 1 meter. |
| `opacity` | xs:float | The opacity of the plane, ranging from 0 (completely transparent) to 1 (completely opaque). Default value is 1. |

### `<m-model>`

The `m-model` element is a 3D model. It can be used to load and display various 3D model file formats, such as OBJ, FBX, or GLTF, depending on the rendering engine being used. The model can be positioned, rotated, and scaled within the 3D scene. It also supports animations.

Uses attribute groups: `debuggable`, `transformable`, `collideable`, `coreattrs`, `clickable`, `shadows`

| attribute | type | description |
|---|---|---|
| `src` | URI | The source URI of the 3D model file. Supported formats may vary depending on the rendering engine used. |
| `anim` | URI | The source URI of the animation file, if applicable. Supported formats may vary depending on the rendering engine used. |
| `anim-loop` | xs:boolean | Whether the animation should loop (true) or play once (false). Default value is true. |
| `anim-enabled` | xs:boolean | Whether the animation is enabled (true) or disabled (false). Default value is true. |
| `anim-start-time` | xs:integer | The time in milliseconds since the start of the document lifecycle when the animation should begin. Default value is 0. |
| `anim-pause-time` | xs:integer | The time in milliseconds since the start of the document lifecycle when the animation should pause. If there is no value the animation will not be paused. |

### `<m-animation>`

The `m-animation` element is used as a child of `m-model` or `m-character` elements to provide weighted animations. Multiple animations can be mixed together using their weight attributes.

Uses attribute groups: `coreattrs`

| attribute | type | description |
|---|---|---|
| `src` | URI | The source URI of the animation file. Supported formats may vary depending on the rendering engine used. |
| `weight` | xs:float | The weight of this animation in the mix. Values range from 0 (no influence) to 1 (full influence). If the sum of all weights is greater than 1, the sum of the weights will be normalized to 1. Default value is 1. |
| `loop` | xs:boolean | Whether the animation should loop (true) or play once (false). Default value is true. |
| `start-time` | xs:integer | The time in milliseconds since the start of the document lifecycle when the animation should begin. Default value is 0. |
| `pause-time` | xs:integer | The time in milliseconds since the start of the document lifecycle when the animation should pause. If there is no value the animation will not be paused. |
| `speed` | xs:float | The playback speed multiplier for the animation. Values greater than 1 play faster, values less than 1 play slower. Default value is 1. |
| `ratio` | xs:float | The specific time ratio (0-1) to set the animation to, overriding normal playback. When set, the animation will be positioned at this specific point regardless of time. If not specified, the animation plays normally based on time. |

### `<m-character>`

The `m-character` element is a 3D character. It supports containing other `m-model` elements, allowing for composing a character from multiple models.

Uses attribute groups: `debuggable`, `transformable`, `collideable`, `coreattrs`, `clickable`, `shadows`

| attribute | type | description |
|---|---|---|
| `src` | URI | The source URI of the 3D character model file. Supported formats may vary depending on the rendering engine used. |
| `anim` | URI | The source URI of the character animation file, if applicable. Supported formats may vary depending on the rendering engine used. |
| `anim-loop` | xs:boolean | Whether the character animation should loop (true) or play once (false). Default value is true. |
| `anim-enabled` | xs:boolean | Whether the character animation is enabled (true) or disabled (false). Default value is true. |
| `anim-start-time` | xs:integer | The time in milliseconds since the start of the document lifecycle when the character animation should begin. Default value is 0. |
| `anim-pause-time` | xs:integer | The time in milliseconds since the start of the document lifecycle when the character animation should pause. If there is no value the animation will not be paused. |

### `<m-frame>`

The `m-frame` element is a 3D frame. It enables composing other MML documents into the document and transforming them as a unit.

Uses attribute groups: `debuggable`, `transformable`, `coreattrs`

| attribute | type | description |
|---|---|---|
| `src` | URI | The source URI of the MML document to be embedded within the current document. |
| `min-x` | xs:float | The minimum X coordinate of the frame's contents in meters. If not specified, the content is not constrained. |
| `max-x` | xs:float | The maximum X coordinate of the frame's contents in meters. If not specified, the content is not constrained. |
| `min-y` | xs:float | The minimum Y coordinate of the frame's contents in meters. If not specified, the content is not constrained. |
| `max-y` | xs:float | The maximum Y coordinate of the frame's contents in meters. If not specified, the content is not constrained. |
| `min-z` | xs:float | The minimum Z coordinate of the frame's contents in meters. If not specified, the content is not constrained. |
| `max-z` | xs:float | The maximum Z coordinate of the frame's contents in meters. If not specified, the content is not constrained. |
| `load-range` | xs:float | The distance in meters from the observer at which the frame will be loaded. If bounds are specified for the frame then the range is a box expanded by this value from the bounds. If no value is specified, the frame will be loaded regardless of distance. |
| `unload-range` | xs:float | The distance beyond the load-range that the frame stay loaded for if currently loaded. This prevents rapid changes between loading and unloading. Default value is 1 meter. |

### `<m-audio>`

The `m-audio` element is used to play audio in a 3D scene.

Uses attribute groups: `debuggable`, `transformable`, `coreattrs`

| attribute | type | description |
|---|---|---|
| `src` | URI | The source URI of the audio file. Supported formats may vary depending on the rendering engine used. |
| `loop` | xs:boolean | Whether the audio should loop (true) or play once (false). Default value is true. |
| `loop-duration` | xs:float | The duration in seconds of the audio loop if `loop` is true. Can be shorter or longer than the audio file duration. Durations longer than the audio file will add silence. If not specified, the entire audio file will loop. |
| `enabled` | xs:boolean | Whether the audio is enabled (true) or disabled (false). Default value is true. |
| `volume` | xs:float | The volume of the audio, ranging from 0 (silent) to 1 (maximum volume). Default value is 1. |
| `cone-angle` | xs:float | The angle in degrees within which sound is at full volume. Default value is 360 (the sound is not directional). |
| `cone-falloff-angle` | xs:float | The angle in degrees beyond which sound is inaudible. Must be greater than `cone-angle` to have an effect. Default value is 0 (there is no gradual drop-off). |
| `start-time` | xs:integer | The time in milliseconds since the start of the document lifecycle when the audio should start playing. Default value is 0. |
| `pause-time` | xs:integer | The time in milliseconds since the start of the document lifecycle when the audio should pause. If there is no value the audio will not be paused. |

### `<m-image>`

The `m-image` element is used to display an image in a 3D scene.

Uses attribute groups: `debuggable`, `transformable`, `clickable`, `collideable`, `coreattrs`, `shadows`

| attribute | type | description |
|---|---|---|
| `src` | URI | The source URI of the image file. Supported formats may vary depending on the rendering engine used. |
| `width` | xs:float | The width of the image in meters. Default value is 1 meter. |
| `height` | xs:float | The height of the image in meters. Default value is 1 meter. |
| `emissive` | xs:float | The emissiveness strength of the image (how much perceived light it will emit). Default value is 0. |
| `opacity` | xs:float | The opacity of the image, ranging from 0 (completely transparent) to 1 (completely opaque). Default value is 1. |

### `<m-video>`

The `m-video` element is used to display a video in a 3D scene.

Uses attribute groups: `debuggable`, `transformable`, `clickable`, `collideable`, `coreattrs`, `shadows`

| attribute | type | description |
|---|---|---|
| `src` | URI | The source URI of the video file. Supported formats may vary depending on the rendering engine used. Some engines support streaming video using WHEP (WebRTC video streaming). In this case, the URI should use the protocol "whep://" rather than "https://". |
| `width` | xs:float | The width of the video in meters. Default value is 1 meter. |
| `height` | xs:float | The height of the video in meters. Default value is 1 meter. |
| `emissive` | xs:float | The emissiveness strength of the video (how much perceived light it will emit). Default value is 0. |
| `loop` | xs:boolean | Whether the video should loop (true) or play once (false). Default value is true. |
| `enabled` | xs:boolean | Whether the video is enabled (true) or disabled (false). Default value is true. |
| `volume` | xs:float | The volume of the video's audio, ranging from 0 (silent) to 1 (maximum volume). Default value is 1. |
| `start-time` | xs:integer | The time in milliseconds since the start of the document lifecycle when the video should start playing. Default value is 0. |
| `pause-time` | xs:integer | The time in milliseconds since the start of the document lifecycle when the video should pause. If there is no value the video will not be paused. |

### `<m-label>`

The `m-label` element is used to display text on a plane in a 3D scene.

Uses attribute groups: `debuggable`, `transformable`, `collideable`, `colorable`, `coreattrs`, `clickable`, `shadows`

| attribute | type | description |
|---|---|---|
| `content` | xs:string | The text content to be displayed on the label. |
| `width` | xs:float | The width of the label in meters. Default value is 1 meter. |
| `height` | xs:float | The height of the label in meters. Default value is 1 meter. |
| `emissive` | xs:float | The emissiveness strength of the label (how much perceived light it will emit). Default value is 0. |
| `font-size` | xs:float | The font size of the text in centimeters. Default value is 24 centimeters. |
| `font-color` | xs:string | The color of the text on the label. Accepts color values in formats such as "#FF0000", "red", or "rgb(255,0,0)". If not specified, the default color is "black". |
| `padding` | xs:float | The padding around the text in centimeters. Default value is 8 centimeters. |
| `alignment` | one of: left, center, right | The horizontal alignment of the text. Default value is left. |

### `<m-position-probe>`

The `m-position-probe` element is used to request the position of a user (either camera or avatar depending upon the experience).

Uses attribute groups: `debuggable`, `transformable`, `coreattrs`

| attribute | type | description |
|---|---|---|
| `range` | xs:float | The range from its position that the position probe requests user positions for in meters. Default value is 10 meters. |
| `interval` | xs:integer | The time in milliseconds between user positions being sent to the position probe. Default value is 1000 (1 second). |
| `onpositionenter` | Script | A script expression to be executed when a user enters the range of the position probe. Receives a `PositionEnterEvent`. (event: `positionenter|MMLPositionEnterEvent`) |
| `onpositionmove` | Script | A script expression to be executed when a user moves within the range of the position probe. Receives a `PositionMoveEvent`. (event: `positionmove|MMLPositionMoveEvent`) |
| `onpositionleave` | Script | A script expression to be executed when a user leaves the range of the position probe. Receives a `PositionLeaveEvent`. (event: `positionleave|MMLPositionLeaveEvent`) |

### `<m-prompt>`

The `m-prompt` element is used to request a string from the user when the element is clicked in a 3D scene.

Uses attribute groups: `debuggable`, `transformable`, `coreattrs`

| attribute | type | description |
|---|---|---|
| `message` | xs:string | The message text to be displayed to the user when the prompt is activated. |
| `placeholder` | xs:string | The hint text displayed in the input field when the prompt is activated. |
| `prefill` | xs:string | The default text pre-populated in the input field when the prompt is activated. |
| `onprompt` | Script | A script expression to be executed when a user submits their input. (event: `prompt|MMLPromptEvent`) |

### `<m-link>`

The `m-link` element is used to open a web address when the element is clicked in a 3D scene. The web address is opened in a new tab or window depending on the client implementation. The `m-link` element has no visual representation in the scene; clicking children of element activates the link.

Uses attribute groups: `debuggable`, `transformable`, `coreattrs`

| attribute | type | description |
|---|---|---|
| `href` | xs:string | The web address to open when the link is clicked. |
| `target` | xs:string | Where the address should be opened. "_self" opens in the current context / tab / window (if the content is in a context in which that is valid). "_blank" opens in a new tab / window. Default value is "_blank". |

### `<m-overlay>`

The `m-overlay` element is used to display a 2D element on top of the 3D scene. It is expected that the child elements to display in the overlay are SVG elements. Not all clients will support this element or choose to allow all documents to use it.

Uses attribute groups: `coreattrs`

| attribute | type | description |
|---|---|---|
| `anchor` | one of: top-left, top-center, top-right, center-left, center, center-right, bottom-left, bottom-center, bottom-right | The anchor point on the screen for the overlay element. Default value is "top-left". |
| `offset-x` | xs:float | The horizontal offset of the overlay element in pixels. Default value is 0. |
| `offset-y` | xs:float | The vertical offset of the overlay element in pixels. Default value is 0. |

### `<m-interaction>`

The `m-interaction` element is used to describe an action that a user can take at a point in 3D space.

Uses attribute groups: `debuggable`, `transformable`, `coreattrs`

| attribute | type | description |
|---|---|---|
| `range` | xs:float | The range that this interaction can be used from in meters. Default value is 5 meters. |
| `in-focus` | xs:boolean | Whether the interaction must be in the direction of the camera to be used. Default value is true. |
| `line-of-sight` | xs:boolean | Whether the interaction must be visible to the camera to be used. Default value is false. |
| `priority` | xs:integer | The priority of this interaction. Lower priority interactions will be shown first. Default value is 1. |
| `prompt` | xs:string | The prompt to be displayed when the interaction is presented to the user. |
| `oninteract` | Script | A script expression that is executed when the element is interacted with. Events are also dispatched to "interact" event listeners. (event: `interact|MMLInteractionEvent`) |

### `<m-chat-probe>`

The `m-chat-probe` element is used to receive messages from a chat system. Which chat system that is depends on the client implementation.

Uses attribute groups: `debuggable`, `transformable`, `coreattrs`

| attribute | type | description |
|---|---|---|
| `range` | xs:float | If the sender of a chat message is within this range (in meters) of the chat probe, the message is expected to be forwarded to the probe. Default value is 1 meter. |
| `onchat` | Script | A script expression that is executed when a chat message is forwarded to the probe. The message itself is contained within the `message` parameter. (event: `chat|MMLChatEvent`) |

### `<m-attr-anim>`

The `m-attr-anim` element is used to describe document time-synchronized changes to element attributes.

Uses attribute groups: `coreattrs`

| attribute | type | description |
|---|---|---|
| `attr` | xs:string | The attribute of the parent element that this animation will animate. |
| `start` | StringOrFloat | The value of the attribute that the animation should start at. |
| `end` | StringOrFloat | The value of the attribute that the animation should end at. |
| `start-time` | xs:integer | The time in milliseconds since the start of the document lifecycle when the animation should start playing. Default value is 0. |
| `pause-time` | xs:integer | The time in milliseconds since the start of the document lifecycle when the animation should pause. This animation will be considered active if the `pause-time` has passed. If there is no value the animation will not be paused. |
| `duration` | xs:integer | The duration of the animation in milliseconds. This is the time taken to go from the `start` value to the `end` value (unless `ping-pong` is enabled). Default value is 1000 (1 second). |
| `loop` | xs:boolean | Whether this animation should loop indefinitely. Default value is true. |
| `easing` | one of: easeInQuad, easeOutQuad, easeInOutQuad, easeInCubic, easeOutCubic, easeInOutCubic, easeInQuart, easeOutQuart, easeInOutQuart, easeInQuint, easeOutQuint, easeInOutQuint, easeInSine, easeOutSine, easeInOutSine, easeInExpo, easeOutExpo, easeInOutExpo, easeInCirc, easeOutCirc, easeInOutCirc, easeInElastic, easeOutElastic, easeInOutElastic, easeInBack, easeOutBack, easeInOutBack, easeInBounce, easeOutBounce, easeInOutBounce | The name of the easing function to apply to the animation ratio to achieve effects such as smooth animations. If the attribute is not specified or is empty the animation will be linear. |
| `ping-pong` | xs:boolean | Whether this animation should go from the `start` value to the `end` value, and then return to the `start` value, all within the time specified by the `duration` attribute. Default value is false. |
| `ping-pong-delay` | xs:float | If `ping-pong` is `true` then the `ping-pong-delay` attribute specifies the time in milliseconds that the animation should pause at the `start` and `end` values. This time is part of the overall `duration` (it does not extend the time taken), and as the `ping-pong-delay` is the time held at both `start` and `end`, the total time where the value is held is double the value of `ping-pong-delay`. Default value is 0. |

### `<m-attr-lerp>`

The `m-attr-lerp` element is used to describe time-transitioned changes to element attributes.

Uses attribute groups: `coreattrs`

| attribute | type | description |
|---|---|---|
| `attr` | xs:string | The attribute(s) of the parent element that this lerp will animate. Multiple attributes can be specified by separating them with a comma. A value of "all" applies this lerp to all attributes. |
| `duration` | xs:integer | The duration of the lerp in milliseconds. This is the time taken to go from the previous value of the attribute to the latest value. Default value is 1000 (1 second). |
| `easing` | one of: easeInQuad, easeOutQuad, easeInOutQuad, easeInCubic, easeOutCubic, easeInOutCubic, easeInQuart, easeOutQuart, easeInOutQuart, easeInQuint, easeOutQuint, easeInOutQuint, easeInSine, easeOutSine, easeInOutSine, easeInExpo, easeOutExpo, easeInOutExpo, easeInCirc, easeOutCirc, easeInOutCirc, easeInElastic, easeOutElastic, easeInOutElastic, easeInBack, easeOutBack, easeInOutBack, easeInBounce, easeOutBounce, easeInOutBounce | The name of the easing function to apply to the lerp ratio to achieve effects such as smooth animations. If the attribute is not specified or is empty the lerp will be linear. |
