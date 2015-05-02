uniform float uSize;
attribute vec4 aPosition;
attribute vec3 aColor;
varying vec4 vColor;

void main() {
	gl_Position = aPosition;
	gl_PointSize = uSize;
	vColor = vec4(aColor, 1.0);
}