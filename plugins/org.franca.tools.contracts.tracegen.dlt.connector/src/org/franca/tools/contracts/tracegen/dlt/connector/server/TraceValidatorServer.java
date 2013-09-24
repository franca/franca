package org.franca.tools.contracts.tracegen.dlt.connector.server;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.ServerSocket;
import java.net.Socket;

import org.franca.tools.contracts.tracegen.dlt.connector.TraceElementProcessor;
import org.franca.tools.contracts.tracegen.dlt.connector.TraceElementRequest;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;

public class TraceValidatorServer extends Thread {

	private static int port = 1234;
	private volatile boolean interrupted;
	private Gson gson;
	public static final TraceValidatorServer INSTANCE = new TraceValidatorServer();
	
	private TraceValidatorServer() {
		this.interrupted = false;
		this.setName("Trace listener server thread");
		this.gson = new Gson();
	}

	@Override
	public void run() {
		ServerSocket serverSocket = null;
		try {
			serverSocket = new ServerSocket(port);
			while (!interrupted) {
				Socket socket = null;
				InputStream inputStream = null;
				InputStreamReader inputStreamReader = null;
				BufferedReader bufferedReader = null;				
				
				try {
					socket = serverSocket.accept();
					if (!interrupted) {
						inputStream = socket.getInputStream();
						inputStreamReader = new InputStreamReader(inputStream);
						bufferedReader = new BufferedReader(inputStreamReader);
						
						String data = null;
						
						while ((data = bufferedReader.readLine()) != null) {
							try {
								TraceElementRequest request = gson.fromJson(data, TraceElementRequest.class);
								System.out.println("Request: "+request);
								TraceElementProcessor.INSTANCE.addRequest(request);
							}
							catch (JsonSyntaxException e) {
								//ignore malformed requests
							}
						}
					}
					
				} finally {
					if (bufferedReader != null) {
						bufferedReader.close();
					}
					if (inputStreamReader != null) {
						inputStreamReader.close();
					}
					if (inputStream != null) {
						inputStream.close();
					}
					if (socket != null) {
						socket.close();
					}
				}
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (serverSocket != null) {
				try {
					serverSocket.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}

	}

	public void interruptThread() {
		this.interrupted = true;
	}

}
