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

out vec4 fragColor;

//-------------------------------

/// http://www.pouet.net/prod.php?which=57245

#define t iGlobalTime
#define r iResolution.xy

void main(){

  vec3 c;
	float l,z=t;
	for(int i=0;i<30;i++) {
		vec2 uv,p=gl_FragCoord.xy/r;
		uv=p;
		p-=0.5;
		p.xy*=r.x/r.y;
		z+=split;
		l=length(p*bloom);
		uv+=p*split/l*(sin(z)+darkness)*abs(sin(l*fractale-z*2.));
		c[i]=zoom/length(abs(mod(uv,1.)-0.5));
	}
	fragColor=vec4(c/l,t/2);
}
