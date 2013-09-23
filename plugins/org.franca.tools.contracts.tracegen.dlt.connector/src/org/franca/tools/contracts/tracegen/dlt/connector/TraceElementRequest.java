package org.franca.tools.contracts.tracegen.dlt.connector;

public class TraceElementRequest {

	private String contextId;
	private String traceElement;
	private String filePath;
	private int messageId;

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
	
	public String getContextId() {
		return contextId;
	}

	public void setContextId(String contextId) {
		this.contextId = contextId;
	}

	public int getMessageId() {
		return messageId;
	}

	public void setMessageId(int messageId) {
		this.messageId = messageId;
	}

	@Override
	public String toString() {
		return "messageId: "+messageId+" path: "+filePath+" trace: "+traceElement;
	}

}
