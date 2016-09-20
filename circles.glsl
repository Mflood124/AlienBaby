#version 140
#define PROCESSING_COLOR_SHADER

uniform float iGlobalTime;
uniform vec3 iResolution;
uniform vec4 iMouse;
uniform sampler2D tex;


out vec4 fragColor;


void main()
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	vec2 p = -1.0 + 2.0 * uv;
	p *= iResolution.xy / min(iResolution.x,iResolution.y);

	p.x += 0.1*sin(iGlobalTime/31.0)*sin(iGlobalTime) * sin(p.y*11.0);
	p.y += 0.1*sin(iGlobalTime/31.0)*sin(iGlobalTime*0.8) * sin(p.x*13.0);

	float d = abs(0.9-length(p))-0.27;
	float a = atan(p.y,p.x);
	//fragColor = vec4(a/3.14,0.5-d,0,1);

	d += 0.04*sin(a*15.0);
	d += 0.075*sin(iGlobalTime);
	a += 2.0*sin(iGlobalTime/5.0);
	d += 0.04*sin(a*9.0);

	fragColor = vec4(1.0-abs(d*sin(a)*70.0),1.0-abs(d*cos(a)*70.0),abs(2.0*d)*(1.0-length(p)/1.25),1);
}
