shader_type spatial;

// Render settings: opaque, shaded, with back-face culling
render_mode depth_draw_opaque, cull_back;

// 🌈 Water color
uniform vec4 water_color : source_color = vec4(0.0, 0.4, 0.8, 1.0);

// 🌊 Wave properties
uniform float wave_height : hint_range(0.0, 2.0, 0.1) = 0.3;
uniform float wave_speed : hint_range(0.0, 5.0, 0.1) = 1.0;

// 💧 Surface appearance
uniform float metallic = 0.6;
uniform float specular = 0.5;
uniform float roughness = 0.2;

// Simple wave function
float get_wave(vec2 pos, float t) {
    return sin(pos.x * 0.5 + t) * cos(pos.y * 0.5 + t);
}

// Vertex function – apply wave displacement
void vertex() {
    float t = TIME * wave_speed;
    float wave = get_wave(VERTEX.xz, t) * wave_height;
    VERTEX.y += wave;
}

// Fragment – set color and lighting
void fragment() {
    NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));

    METALLIC = metallic;
    SPECULAR = specular;
    ROUGHNESS = roughness;
    ALBEDO = water_color.rgb;
    ALPHA = 1.0; // Fully opaque
}
