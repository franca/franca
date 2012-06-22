package org.franca.core.utils;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.xmi.XMLResource;

public class ModelPersistenceHandler {
   
   /**
    * All models that have cross-references must exist in the same ResourceSet
    */
   private ResourceSet resourceSet;
   
   /**
    * A relative path to work from when loading/saving models.
    */
   private String prependPath;
   
   
   /**
    * Creating an object used to save or to load a set of related models from files.
    *
    * Working relatively to a path example: model is in prependPath/model.fidl and is importing a file like importedFile.fidl.
    * The importedFile.fidl is to be found in prependPath. 
    * 
    * Working with absolute path example: model is in /my/nice/path/to/model.fidl and importing importedFile.fidl. The 
    * importedFile is to be found in /my/nice/path/to/

    * @param newResourceSet the resource set to save all the loaded files/ where all the models to be saved exist
    * @param newPrependPath a relative path to work in
    */
   public ModelPersistenceHandler(ResourceSet newResourceSet, String newPrependPath)
   {
      resourceSet = newResourceSet;  
      prependPath = newPrependPath;
      if (prependPath != null)
      {
         resourceSet.setURIConverter(new FrancaURIConverter(prependPath));
      }
   }

   /**
    * 
    * Load the model found in the fileName. Its dependencies can be loaded subsequently.
    *
    * @param fileName the file to be loaded   
    * @return the root model 
    */
   public EObject loadModel(String fileName) {
      URI uri = URI.createURI(fileName);
      HashMap<String,Object> options = new HashMap<String,Object>();
      Resource resource =null;
      
      if (prependPath == null)
      {
         prependPath = uri.trimSegments(1).toString();
         resourceSet.setURIConverter(new FrancaURIConverter(prependPath));
         uri = URI.createURI(uri.lastSegment());
      }
      options.put(XMLResource.OPTION_DEFER_ATTACHMENT, true);
      options.put(XMLResource.OPTION_DEFER_IDREF_RESOLUTION, true);
      try {
            resource = resourceSet.createResource(uri);
            resource.load(options);
      } catch (IOException e) {
         e.printStackTrace();
         return null;
      }
      return resource.getContents().get(0);
   }
   
   /**
    * Saves a model to a file. If cross-references are used in the model then the model must be part of a ResourceSet 
    * containing all the other referenced models.
    *
    * @param fileName the name of the file to be saved
    * @return true if the model was saved
    */
   public boolean saveModel(EObject model, String fileName)
   {
      URI uri = URI.createURI(fileName);
      
      if (prependPath == null)
      {
         prependPath = uri.trimSegments(1).toString();
         resourceSet.setURIConverter(new FrancaURIConverter(prependPath));
         uri = URI.createURI(uri.lastSegment());
      }
      if (model.eResource() == null) {
         // create a resource containing the model
         Resource resource = resourceSet.createResource(URI.createURI(fileName));
         resource.getContents().add(model);
      }

      try {
         model.eResource().save(Collections.EMPTY_MAP);
      } catch (IOException e) {
         e.printStackTrace();
      }

      return true;
   }
   
   public ResourceSet getResourceSet() {
      return resourceSet;
   }

   public String getPrependPath() {
      return prependPath;
   }
}
