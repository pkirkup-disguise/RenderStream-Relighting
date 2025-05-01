# RenderStream-Relighting

A custom shader implementation for real-time scene relighting in disguise RenderStream environments.

## Overview

This project provides GLSL fragment shaders that enable dynamic relighting of RenderStream scenes. It extends the [RenderStream-shader](https://github.com/disguise-one/RenderStream-shader) framework to offer sophisticated lighting controls and effects for virtual production.

## Features

- Real-time lighting adjustments for RenderStream scenes
- Support for multiple light sources with independent controls
- Adjustable parameters including intensity, color, falloff, and direction
- Normal map integration for realistic surface lighting
- Performance-optimized shader implementation

## Requirements

- [RenderStream-Python](https://github.com/disguise-one/RenderStream-py) 
- [RenderStream-shader](https://github.com/disguise-one/RenderStream-shader) framework
- disguise Designer software

## Installation

1. Ensure RenderStream-Python and RenderStream-shader are properly installed
2. Clone this repository into your RenderStream Projects folder, into the Shaders folder of the Renderstream-shader project:
   ```
   git clone https://github.com/pkirkup-disguise/RenderStream-Relighting.git
   ```
3. In Designer, configure a RenderStream layer to use the relighting shader assets

## Usage

1. Select the relighting shader in your RenderStream layer configuration
2. Adjust exposed parameters in Designer to control lighting behavior
3. Link parameters to timeline sequences or dmx inputs for dynamic control

## Configuration

The shaders expose various uniforms that can be controlled through RenderStream parameters:

```glsl
// Light source properties
uniform vec3 lightPosition = vec3(0.0, 5.0, 0.0); // RS: display="Light Position" min=-10.0 max=10.0 step=0.1
uniform vec4 lightColor = vec4(1.0, 1.0, 1.0, 1.0); // RS: display="Light Color" isColour=True
uniform float lightIntensity = 1.0; // RS: display="Light Intensity" min=0.0 max=5.0 step=0.1

// Material properties
uniform float specularStrength = 0.5; // RS: display="Specular Strength" min=0.0 max=1.0 step=0.01
uniform float roughness = 0.3; // RS: display="Surface Roughness" min=0.0 max=1.0 step=0.01
```

## License

[MIT](LICENSE)

## Acknowledgments

- Built upon the [RenderStream-shader](https://github.com/disguise-one/RenderStream-shader) framework by disguise
- Inspired by advanced lighting techniques in modern real-time rendering engines 