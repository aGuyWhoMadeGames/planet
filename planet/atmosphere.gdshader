shader_type spatial;
render_mode unshaded,depth_draw_never,depth_test_disabled;

uniform float planet_radius = 1.0;
uniform float atmosphere_radius = 1.0;

uniform float density:hint_range(0.0, 1000.0, 0.01) = 29;
uniform float falloff = 0.97;
uniform vec3 sky_color:source_color = vec3(0.271,0.855,1);

uniform sampler2D depth_tex : hint_depth_texture;

const vec3 sun_dir = vec3(0.451,0.5,0.739);
global uniform vec3 SUN_DIR;

varying mat4 view_mat;

// Adapted from: https://github.com/SebLague/Solar-System/blob/Development/Assets/Scripts/Celestial/Shaders/Includes/Math.cginc

// Returns vector (dstToSphere, dstToSphereFar)
// If ray origin is inside sphere, dstToSphere = 0
// If ray misses sphere, dstToSphere = -1; dstToSphereFar = maxValue
vec2 raySphere(float sphereRadius, vec3 rayOrigin, vec3 rayDir) {
	float a = 1.0; // Set to dot(rayDir, rayDir) if rayDir might not be normalized
	float b = 2.0 * dot(rayOrigin, rayDir);
	float c = dot (rayOrigin, rayOrigin) - sphereRadius * sphereRadius;
	float d = b * b - 4.0 * a * c; // Discriminant from quadratic formula

	// Number of intersections: 0 when d < 0; 1 when d = 0; 2 when d > 0
	if (d > 0.0) {
		float s = sqrt(d);
		float dstToSphereNear = max(0.0, (-b - s) / (2.0 * a));
		float dstToSphereFar = (-b + s) / (2.0 * a);

		// Ignore intersections that occur behind the ray
		if (dstToSphereFar >= 0.0) {
			return vec2(dstToSphereNear, dstToSphereFar);
		}
	}
	// Ray did not intersect sphere
	return vec2(-1.0, 0.0);
}

float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

float linear_depth(vec2 uv, mat4 inv_proj){
	float log_depth = textureLod(depth_tex, uv, 0.0).x;
	vec4 depth_view = inv_proj * vec4(uv * 2.0 - 1.0, log_depth, 1.0);
	depth_view.xyz /= depth_view.w;
	return length(depth_view.xyz);
}

void vertex() {
	view_mat = inverse(MODELVIEW_MATRIX);
}

void fragment() {
	vec3 orig = (view_mat*vec4(0,0,0,1)).xyz;
	vec3 dir = normalize((view_mat * vec4(VERTEX, 1.)).xyz - orig);


	vec2 atmosphere = raySphere(atmosphere_radius,orig,dir);
	if(atmosphere.x<-0.5) discard;
	vec2 planet = raySphere(planet_radius,orig,dir);

	float start = atmosphere.x;
	float scene_depth = linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX);
	float end = min(atmosphere.y,scene_depth);

	if(end < start) discard;

	float depth = (end-start)/atmosphere_radius;

	float densityAtPoint = 0.0;
	float light = 0.0;
	for(int i=0;i<4;i++){
		float mid_depth = mix(start,end,map(float(i),0.0,3.0,0.1,0.9));
		vec3 mid_point = dir*mid_depth+orig;
		float mid_alt = (length(mid_point)-planet_radius)/(atmosphere_radius-planet_radius);
		densityAtPoint += exp(-mid_alt*0.1)*(1.0-mid_alt)*depth*density;
		light += smoothstep(-0.1,0.1,dot(normalize(mid_point),SUN_DIR));
	}
	ALPHA = (1.0-pow(falloff, densityAtPoint*0.25))*light*0.25;

	ALBEDO = sky_color;
}


//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
