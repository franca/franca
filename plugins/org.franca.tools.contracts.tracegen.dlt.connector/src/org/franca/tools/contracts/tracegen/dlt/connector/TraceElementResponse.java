package org.franca.tools.contracts.tracegen.dlt.connector;

public class TraceElementResponse {

	private int messageId;
	// changed from boolean to int because of the QT JSON parser
	private int valid;
	private String contextId;
	private String data;
	
	public TraceElementResponse(int messageId, boolean valid, String contextId, String data) {
		super();
		this.messageId = messageId;
		this.valid = (valid) ? 0 : 1;
		this.data = data;
		this.contextId = contextId;
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

	public int getValid() {
		return valid;
	}
	
	public void setValid(boolean valid) {
		this.valid = valid ? 0 : 1;
	}

	public String getData() {
		return data;
	}

	public void setData(String data) {
		this.data = data;
	}
	
	@Override
	public String toString() {
		return "[messageId: "+messageId+" valid: "+valid+" expected: "+data+"]";
	}

}
