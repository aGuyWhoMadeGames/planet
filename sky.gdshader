shader_type sky;

// From: https://www.shadertoy.com/view/slSXRW
float sunWithBloom(vec3 rayDir, vec3 sunDir) {
    const float sunSolidAngle = 0.53*PI/180.0;
    const float minSunCosTheta = cos(sunSolidAngle);

    float cosTheta = dot(rayDir, sunDir);
    if (cosTheta >= minSunCosTheta) return 1.0;
    
    float offset = minSunCosTheta - cosTheta;
    float gaussianBloom = exp(-offset*50000.0)*0.5;
    float invBloom = 1.0/(0.02 + offset*300.0)*0.01;
    return 15.0*(gaussianBloom+invBloom);
}

void sky() {
	COLOR = sunWithBloom(EYEDIR,LIGHT0_DIRECTION)*LIGHT0_COLOR*LIGHT0_ENERGY;
}
