#version 140
#define PROCESSING_COLOR_SHADER

uniform float iGlobalTime;
uniform vec3 iResolution;
uniform vec4 iMouse;
uniform float darkness;
uniform float fractale;
uniform float split;
uniform float bloom;
uniform float zoom;
uniform float splat;
uniform float sploot;

out vec4 fragColor;

//-------------------------------

/// http://www.pouet.net/prod.php?which=57245

#define t iGlobalTime
#define r iResolution.xy

void main(){

  vec3 c; //stores rgb values
	float l,z=t; //animation values set to global time
	for(int i=0;i<20;i++) {
		vec2 uv,p=gl_FragCoord.xy/r; // xy positioning variables?
		uv=p; //moves back to the center at the start of the loop?
		p-=0.5; //sets center of vortex
		p.x*=r.x/r.y; //aspect ratio set to screen size
		z+=split; // colour intensity
		l=length(p/bloom); //animation for music
		uv+=p/l*(sin(z)+darkness)*abs(sin(l*fractale-z*splat)); //replaced all hard numbers
		c[i]=zoom/length(abs(mod(uv,1.)-0.5)); //zoom animates the brightness of the center
	}
	fragColor=vec4(c/l*sploot,t); //sploot controls the overall brightness
}
