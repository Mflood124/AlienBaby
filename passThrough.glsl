#version 140
#define PROCESSING_COLOR_SHADER
uniform sampler2D tex;
uniform vec3 iResolution;
uniform float iGlobalTime;
uniform float dryWet;
uniform vec4 iMouse;
uniform float darkness;
uniform float fractale;
uniform float split;
uniform float bloom;

out vec4 fragColor;

//-------------------------------

/// http://www.pouet.net/prod.php?which=57245

#define t iGlobalTime
#define r iResolution.xy

void main(){

  vec3 c;
  vec2 uv,p;
	float l,z=bloom;
	for(int i=0;i<3;i++) {
		p=gl_FragCoord.xy/r;
		uv=p*fractale;
		p-=0.5;
		p.x*=r.x/r.y;
		z+=split;
		l=length(p*bloom);
		uv+=p/l*(sin(z)+1.)*abs(sin(l*9.-z*2.));
		c[i]=.01/length(abs(mod(uv,1.)-.5));
	}
	fragColor=vec4(c/l,t);
	vec4 dry = texture2D(tex,uv);
	vec4 final = mix(dry, frag, dryWet);
	gl_FragColor = final;
}
