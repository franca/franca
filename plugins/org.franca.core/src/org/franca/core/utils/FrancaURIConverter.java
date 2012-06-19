package org.franca.core.utils;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Map;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.ContentHandler;
import org.eclipse.emf.ecore.resource.URIConverter;
import org.eclipse.emf.ecore.resource.URIHandler;
import org.eclipse.xtext.resource.XtextResourceSet;

public class FrancaURIConverter implements URIConverter {

   URIConverter xTextURIConverter = null;
   String relativePath = "";

   public void setRelativePath(String newRelativePath) {
      if (newRelativePath != null && newRelativePath.length() > 0)
      {
         relativePath = URI.createURI(newRelativePath + "/").toString().replaceAll("/+", "/");
      }
   }

   public FrancaURIConverter(String newRelativePath) {
      xTextURIConverter = new XtextResourceSet().getURIConverter();
      setRelativePath(newRelativePath);
   }

   public URI normalize(URI uri) {
      return xTextURIConverter.normalize(uri);
   }

   public Map<URI, URI> getURIMap() {
      return xTextURIConverter.getURIMap();
   }

   public EList<URIHandler> getURIHandlers() {
      return xTextURIConverter.getURIHandlers();
   }

   public URIHandler getURIHandler(URI uri) {
      return xTextURIConverter.getURIHandler(uri);
   }

   public EList<ContentHandler> getContentHandlers() {
      return xTextURIConverter.getContentHandlers();
   }

   public InputStream createInputStream(URI uri) throws IOException {
      URI tmpURI = URI.createFileURI(relativePath + uri.path());
      
      System.out.println("Loading " + tmpURI);
      return xTextURIConverter.createInputStream(tmpURI);
   }

   public InputStream createInputStream(URI uri, Map<?, ?> options) throws IOException {
      URI tmpURI = URI.createURI(relativePath + uri.path());
      
      System.out.println("Loading " + tmpURI);
      return xTextURIConverter.createInputStream(tmpURI, options);
   }

   public OutputStream createOutputStream(URI uri) throws IOException {
      URI tmpURI = URI.createURI(relativePath + uri.path());
      
      System.out.println("Saving " + tmpURI);
      return xTextURIConverter.createOutputStream(tmpURI);
   }

   public OutputStream createOutputStream(URI uri, Map<?, ?> options) throws IOException {
      URI tmpURI = URI.createURI(relativePath + uri.path());
      
      System.out.println("Saving " + tmpURI);
      return xTextURIConverter.createOutputStream(URI.createURI(relativePath + uri.path()), options);
   }

   public void delete(URI uri, Map<?, ?> options) throws IOException {
      xTextURIConverter.delete(uri, options);
   }

   public Map<String, ?> contentDescription(URI uri, Map<?, ?> options) throws IOException {
      return xTextURIConverter.contentDescription(uri, options);
   }

   public boolean exists(URI uri, Map<?, ?> options) {
      return xTextURIConverter.exists(uri, options);
   }

   public Map<String, ?> getAttributes(URI uri, Map<?, ?> options) {
      return xTextURIConverter.getAttributes(uri, options);
   }

   public void setAttributes(URI uri, Map<String, ?> attributes, Map<?, ?> options) throws IOException {
      xTextURIConverter.setAttributes(uri, attributes, options);
   }
}
