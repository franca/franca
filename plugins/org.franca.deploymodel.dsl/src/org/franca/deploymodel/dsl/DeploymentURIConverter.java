package org.franca.deploymodel.dsl;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Map;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.ContentHandler;
import org.eclipse.emf.ecore.resource.URIConverter;
import org.eclipse.emf.ecore.resource.URIHandler;

public class DeploymentURIConverter implements URIConverter {

	URIConverter mOrigURICOnverter = null;
	String mInOutDirectory = null;
	
	public void setInOutDirectory(String inOutDirectory)
	{
		mInOutDirectory = inOutDirectory;
	}
	
	public DeploymentURIConverter(URIConverter origURICOnverter, String outDirectory)
	{
        mOrigURICOnverter = origURICOnverter;
		mInOutDirectory = outDirectory;
	}

	public URI normalize(URI uri) {
		return mOrigURICOnverter.normalize(uri);
	}

	public Map<URI, URI> getURIMap() {
		return mOrigURICOnverter.getURIMap();
	}

	public EList<URIHandler> getURIHandlers() {
		return mOrigURICOnverter.getURIHandlers();
	}

	public URIHandler getURIHandler(URI uri) {
		return mOrigURICOnverter.getURIHandler(uri);
	}

	public EList<ContentHandler> getContentHandlers() {
		return mOrigURICOnverter.getContentHandlers();
	}

	public InputStream createInputStream(URI uri) throws IOException {
		URI tmpURI = null;
		
		tmpURI = URI.createFileURI(mInOutDirectory + uri.path());
		System.out.println("Loading " + tmpURI);
		return mOrigURICOnverter.createInputStream(tmpURI);
	}

	public InputStream createInputStream(URI uri, Map<?, ?> options)
			throws IOException {
		URI tmpURI = null;
		
		tmpURI = URI.createFileURI(mInOutDirectory + uri.path());
		System.out.println("Loading " + tmpURI);

		return mOrigURICOnverter.createInputStream(tmpURI, options);
	}

	public OutputStream createOutputStream(URI uri) throws IOException {
		URI tmpURI = null;
		
		if (uri.isPlatform())
		{
			//in case of using plugin internal models, e.g. some_ip then copy the resource to the output directory too
			tmpURI = URI.createFileURI(mInOutDirectory + uri.lastSegment());
		}
		else
		{
			tmpURI = URI.createFileURI(mInOutDirectory + uri.path());
		}
		System.out.println("Saving " + tmpURI);
		return mOrigURICOnverter.createOutputStream(tmpURI);
	}

	public OutputStream createOutputStream(URI uri, Map<?, ?> options)
			throws IOException {
		System.out.println("Saving " + URI.createFileURI(mInOutDirectory + uri.path()));
		return mOrigURICOnverter.createOutputStream(URI.createFileURI(mInOutDirectory + uri.path()), options);
	}

	public void delete(URI uri, Map<?, ?> options) throws IOException {
		mOrigURICOnverter.delete(uri, options);
	}

	public Map<String, ?> contentDescription(URI uri, Map<?, ?> options)
			throws IOException {
		return mOrigURICOnverter.contentDescription(uri, options);
	}

	public boolean exists(URI uri, Map<?, ?> options) {
		return mOrigURICOnverter.exists(uri, options);
	}

	public Map<String, ?> getAttributes(URI uri, Map<?, ?> options) {
		return mOrigURICOnverter.getAttributes(uri, options);
	}

	public void setAttributes(URI uri, Map<String, ?> attributes,
			Map<?, ?> options) throws IOException {
		mOrigURICOnverter.setAttributes(uri, attributes, options);
	}
}
