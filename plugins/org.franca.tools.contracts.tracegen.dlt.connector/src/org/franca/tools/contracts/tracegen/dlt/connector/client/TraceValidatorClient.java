package org.franca.tools.contracts.tracegen.dlt.connector.client;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.Socket;

import org.franca.tools.contracts.tracegen.dlt.connector.TraceElementResponse;

import com.google.gson.Gson;

public class TraceValidatorClient {

	private static final String HOST_NAME = "localhost";
	private static int PORT = 1235;
	private static Gson gson = new Gson();

	public static void send(TraceElementResponse response) throws IOException {
		Socket socket = null;
		PrintWriter writer = null;
		
		try {
			String message = gson.toJson(response);
			socket = new Socket(HOST_NAME, PORT);
			writer = new PrintWriter(socket.getOutputStream(), true);
			writer.println(message);
		}
		finally {
			if (writer != null) {
				writer.close();
			}
			if (socket != null) {
				socket.close();
			}
		}
	}
}
