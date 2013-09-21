package org.franca.tools.contracts.tracegen.dlt.connector.client;


public class TraceValidatorClient extends Thread {

	private static int port = 1234;
	private volatile boolean interrupted;

	public TraceValidatorClient() {
		this.interrupted = false;
		this.setName("Trace listener client thread");
		this.start();
	}

	@Override
	public void run() {

	}

	public void interruptServer() {
		this.interrupted = true;
	}

}
