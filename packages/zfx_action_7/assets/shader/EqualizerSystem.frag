precision mediump float;
varying float vValue;
uniform vec3 uColor;

void main() {
	gl_FragColor = vec4(uColor, 0.8);
}