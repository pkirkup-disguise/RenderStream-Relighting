#version 330
precision highp float;

// Input textures
uniform sampler2D rgbTex;       // Original RGB color texture
uniform sampler2D albedoTex;    // Albedo texture
uniform sampler2D normalTex;    // Normal map texture
uniform sampler2D depthTex;     // Depth texture

// Window dimensions
uniform float width;            // RS: engine=stream.width
uniform float height;           // RS: engine=stream.height

// Light properties
uniform vec3 lightPosition = vec3(0.0, 0.0, 5.0);    // RS: min=-10 max=10 default=0,0,5 display="Light Position"
uniform vec3 lightRotation = vec3(0.0, 0.0, 0.0);    // RS: min=-180 max=180 default=0,0,0 display="Light Rotation"
uniform vec3 lightColor = vec3(1.0, 1.0, 1.0);       // RS: min=0 max=1 default=1,1,1 display="Light Color"
uniform float lightIntensity = 1.0;                  // RS: min=0 max=5 default=1 display="Light Intensity"
uniform float specularPower = 32.0;                  // RS: min=1 max=128 default=32 display="Specular Power"
uniform float ambientStrength = 0.2;                 // RS: min=0 max=1 default=0.2 display="Ambient Strength"

// View properties
uniform float znear = 0.1;
uniform float zfar = 100.0;

in vec2 fragCoord;
out vec4 fragColor;

// Function to convert depth to linear space
float linearizeDepth(float depth) {
    return -zfar * znear / (depth * (zfar - znear) - zfar);
}

// Function to reconstruct world position from depth
vec3 reconstructPosition(vec2 uv, float depth) {
    // Convert to NDC space
    vec2 screenPos = uv * 2.0 - 1.0;
    
    // Calculate view-space position
    float z = linearizeDepth(depth);
    
    // Assuming an inverse projection matrix calculation
    // This is simplified; for accurate reconstruction, you'd need actual projection matrix
    float aspectRatio = width / height;
    float fov = 60.0 * 3.14159265 / 180.0;
    float tanHalfFov = tan(fov / 2.0);
    
    vec3 viewPos;
    viewPos.z = -z;
    viewPos.x = screenPos.x * aspectRatio * tanHalfFov * abs(z);
    viewPos.y = screenPos.y * tanHalfFov * abs(z);
    
    return viewPos;
}

// Apply rotation to a vector
vec3 rotateVector(vec3 v, vec3 rotation) {
    // Convert rotation from degrees to radians
    vec3 rotRad = radians(rotation);
    
    // Rotation around X axis
    float cosX = cos(rotRad.x);
    float sinX = sin(rotRad.x);
    vec3 rotX = vec3(v.x, v.y * cosX - v.z * sinX, v.y * sinX + v.z * cosX);
    
    // Rotation around Y axis
    float cosY = cos(rotRad.y);
    float sinY = sin(rotRad.y);
    vec3 rotXY = vec3(rotX.x * cosY + rotX.z * sinY, rotX.y, -rotX.x * sinY + rotX.z * cosY);
    
    // Rotation around Z axis
    float cosZ = cos(rotRad.z);
    float sinZ = sin(rotRad.z);
    return vec3(rotXY.x * cosZ - rotXY.y * sinZ, rotXY.x * sinZ + rotXY.y * cosZ, rotXY.z);
}

void main() {
    // Sample textures
    vec4 originalColor = texture(rgbTex, fragCoord);
    vec3 albedo = texture(albedoTex, fragCoord).rgb;
    vec3 normal = normalize(texture(normalTex, fragCoord).rgb * 2.0 - 1.0);
    float depth = texture(depthTex, fragCoord).r;
    
    // Reconstruct position from depth
    vec3 fragPos = reconstructPosition(fragCoord, depth);
    
    // Apply light rotation to get the final light direction
    vec3 lightDir = normalize(rotateVector(lightPosition - fragPos, lightRotation));
    
    // Calculate view direction (camera is at 0,0,0 in view space)
    vec3 viewDir = normalize(-fragPos);
    
    // Calculate lighting components
    // Ambient component
    vec3 ambient = ambientStrength * albedo;
    
    // Diffuse component
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = diff * lightColor * albedo;
    
    // Specular component (Blinn-Phong)
    vec3 halfwayDir = normalize(lightDir + viewDir);
    float spec = pow(max(dot(normal, halfwayDir), 0.0), specularPower);
    vec3 specular = spec * lightColor;
    
    // Calculate attenuation (inverse square law)
    float distance = length(lightPosition - fragPos);
    float attenuation = 1.0 / (1.0 + 0.09 * distance + 0.032 * distance * distance);
    
    // Combine all lighting components
    vec3 lighting = (ambient + (diffuse + specular) * attenuation) * lightIntensity;
    
    // Mix with original color to preserve original lighting details
    vec3 finalColor = mix(originalColor.rgb, lighting, 0.8);
    
    // Output final color
    fragColor = vec4(finalColor, originalColor.a);
}
