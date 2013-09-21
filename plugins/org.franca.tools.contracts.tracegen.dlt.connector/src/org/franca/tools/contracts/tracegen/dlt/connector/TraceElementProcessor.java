package org.franca.tools.contracts.tracegen.dlt.connector;

import java.util.ArrayList;
import java.util.List;

public class TraceElementProcessor extends Thread {

	private List<TraceElementRequest> requests;
	private volatile boolean interrupted;
	public static final TraceElementProcessor INSTANCE = new TraceElementProcessor();
	
	private TraceElementProcessor() {
		this.requests = new ArrayList<TraceElementRequest>();
		this.interrupted = false;
	}
	
	@Override
	public void run() {
		while (!interrupted) {
			TraceElementRequest request = null;
			synchronized (requests) {
				if (requests.isEmpty()) {
					try {
						// timeout wait is used to be able to check the state of 
						// the interrupted flag
						requests.wait(5000);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
				else {
					request = requests.remove(0);
					System.out.println(request);
				}
			}
			
			if (request != null) {
				// do processing
			}
		}	
	}
	
	public void interruptThread() {
		this.interrupted = true;
	}
	
	public void addRequest(TraceElementRequest request) {
		synchronized (requests) {
			requests.add(request);
			requests.notify();
		}
	}
}
