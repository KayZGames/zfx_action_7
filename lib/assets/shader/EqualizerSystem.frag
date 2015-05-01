precision mediump float;
varying float vValue;

void main() {
	gl_FragColor = vec4(vValue / 256.0, vValue / 256.0, vValue / 256.0, 0.2);
}