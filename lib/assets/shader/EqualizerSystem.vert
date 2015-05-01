attribute vec4 aPosition;
attribute float aValue;
varying float vValue;

void main() {
	gl_Position = aPosition;
	vValue = aValue;
}