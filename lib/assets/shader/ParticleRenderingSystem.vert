attribute vec4 aPosition;
attribute vec3 aColor;
varying vec4 vColor;

void main() {
	gl_Position = aPosition;
	gl_PointSize = 1.0;
	vColor = vec4(aColor, 1.0);
}
