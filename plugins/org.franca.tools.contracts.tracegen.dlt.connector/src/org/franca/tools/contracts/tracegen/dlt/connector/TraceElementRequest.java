package org.franca.tools.contracts.tracegen.dlt.connector;

public class TraceElementRequest {

	private String traceElement;
	private String filePath;
	private int messageIndex;

	public String getTraceElement() {
		return traceElement;
	}

	public void setTraceElement(String traceElement) {
		this.traceElement = traceElement;
	}

	public String getFilePath() {
		return filePath;
	}

	public void setFilePath(String filePath) {
		this.filePath = filePath;
	}

	public int getMessageIndex() {
		return messageIndex;
	}

	public void setMessageIndex(int messageIndex) {
		this.messageIndex = messageIndex;
	}
	
	@Override
	public String toString() {
		return "index: "+messageIndex+" path: "+filePath+" trace: "+traceElement;
	}

}
