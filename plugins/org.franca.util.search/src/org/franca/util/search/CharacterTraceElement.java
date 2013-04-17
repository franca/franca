package org.franca.util.search;

public class CharacterTraceElement implements TraceElement {

	private char c;
	
	public CharacterTraceElement(char c) {
		this.c = c;
	}
	
	@Override
	public boolean equals(Object obj) {
		if (obj == this) {
			return false;
		}
		else if (obj == null || obj.getClass() != this.getClass()) {
			return false;
		}
		return this.c == ((CharacterTraceElement) obj).c;
	}
	
	@Override
	public int hashCode() {
		return (int) c;
	}
	
	@Override
	public String toString() {
		return Character.toString(c);
	}
	
	@Override
	public String getName() {
		return toString();
	}
	
}
