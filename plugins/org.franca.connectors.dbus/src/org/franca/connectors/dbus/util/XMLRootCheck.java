package org.franca.connectors.dbus.util;

import java.io.InputStream;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

public class XMLRootCheck {

	static SAXParser saxParser = null;
	static MySaxHandler handler = new MySaxHandler();

	/**
	 * simple handler to read starting (root) element
	 */

	private static class MySaxHandler extends DefaultHandler {

		String rootName;

		@Override
		public void startElement(String uri, String localName, String qName,
				Attributes ats) throws SAXException {

			rootName = localName;
			if (rootName.length() == 0) {
				rootName = qName;
			}
			throw new SAXException("stop after first element");
		}
	}

	public static String determineRootElement(InputStream input) {

		String rootElement = "";

		try {
			if (null == saxParser)
				saxParser = SAXParserFactory.newInstance().newSAXParser();
			saxParser.parse(input, handler);
		} catch (Exception e) {
			rootElement = handler.rootName;
		}

		return rootElement;
	}
}
