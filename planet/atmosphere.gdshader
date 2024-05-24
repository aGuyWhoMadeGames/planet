shader_type spatial;
render_mode unshaded,depth_draw_never;//,depth_test_disabled;

uniform float planet_radius = 1.0;
uniform float atmosphere_radius = 1.0;

uniform float density:hint_range(0.0, 1000.0, 0.01) = 19.5;
uniform float falloff = 0.865;
uniform vec3 sky_color:source_color = vec3(0.271,0.855,1);

const vec3 sun_dir = vec3(0.451,0.5,0.739);
global uniform vec3 SUN_DIR;

varying mat4 view_mat;

void vertex() {
	view_mat = inverse(MODELVIEW_MATRIX);
}

void fragment() {
	vec3 orig = (view_mat*vec4(0,0,0,1)).xyz;
	vec3 dir = normalize((view_mat * vec4(VERTEX, 1.)).xyz - orig);
	/*if(dot(dir,orig)>0.0&&!(dot(orig,orig)<atmosphere_radius*atmosphere_radius)){
		discard;
	}*/
	float a = dot(dir,dir);
	float b = 2.0*dot(orig,dir);
	float c = dot(orig,orig)-atmosphere_radius*atmosphere_radius;
	float d = b*b-4.0*a*c;
	if(d<0.0){
		discard;
	}
	d = sqrt(d);
	float a2 = 0.5/a;
	float start = max((-b-d)*a2,0.0);
	float end = (-b+d)*a2;
	if(end<0.0){
		discard;
	}
	c = dot(orig,orig)-planet_radius*planet_radius;
	d = b*b-4.0*a*c;
	float planet_dist;
	if(d>0.0){
		planet_dist = (-b-sqrt(d))*a2;
		if(planet_dist>0.0){
			end = min(planet_dist,end);
		}
	}
	float depth = (end-start)/atmosphere_radius;
	float mid_depth = mix(start,end,0.1);
	vec3 mid_point = dir*mid_depth+orig;
	float mid_alt = (length(mid_point)-planet_radius)/(atmosphere_radius-planet_radius);
	//ALPHA = pow(depth,falloff)*density;
	float atmosphere = (1.0-pow(mid_alt,0.5))*depth*density;
	//ALPHA = atmosphere;
	ALPHA = (1.0-pow(falloff, atmosphere))*smoothstep(-0.1,0.1,dot(normalize(mid_point),SUN_DIR));
	//ALPHA = 1.0;
	ALBEDO = sky_color;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
