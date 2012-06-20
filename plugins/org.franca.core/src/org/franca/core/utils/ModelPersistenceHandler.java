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
    *  Flag to indicate that we must set a new relative path when saving the root model. The imported files will inherit
    *  this path.
    */
   private boolean isFirstPersistenceAction = true;
   
   /**
    * Creating an object used to save or to load a set of related models from files.
    *
    * Working relatively to a path example: model is in prependPath/fileName and is importing a file like importedFile.
    * The importedFile is to be found in prependPath. 
    * 
    * Working with absolute path example: model is in /my/nice/path/to/model.fidl and importing importedFile. The 
    * importedFile is to be found in /my/nice/path/to/

    * @param newResourceSet the resource set to save all the loaded files/ where all the models to be saved exist
    * @param newPrependPath a relative path to work in
    */
   public ModelPersistenceHandler(ResourceSet newResourceSet, String newPrependPath)
   {
      resourceSet = newResourceSet;  
      prependPath = newPrependPath;
   }

   /**
    * 
    * Load the model found in the fileName. Its dependencies can be loaded subsequently.
    *
    * @param fileName the file to be loaded   
    * @return the root model 
    */
   public EObject loadModel(String fileName) {
      URI uri = URI.createFileURI(fileName);
      HashMap<String,Object> options = new HashMap<String,Object>();
      Resource resource =null;
      
      uri = setEffectiveRelativePath(uri, resourceSet, prependPath);
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
      URI uri = URI.createFileURI(fileName);
      
      uri = setEffectiveRelativePath(uri, resourceSet, prependPath);
      
      try {
         model.eResource().save(Collections.EMPTY_MAP);
      } catch (IOException e) {
         e.printStackTrace();
      }

      return true;
   }
   
   /**
    * Helper method to be used on loading and saving models.
    * 
    * @param uri the URI of the file to be saved
    * @param resourceSet the resource set the model belongs to
    * @param prependPath a path to work relatively
    */
   private URI setEffectiveRelativePath(URI uri, ResourceSet resourceSet, String prependPath)
   {
      if (!uri.isRelative())
      {
         //if /my/nice/path/to/model.fidl => load all files relatively to path /my/nice/path/to/
         resourceSet.setURIConverter(new FrancaURIConverter(uri.trimSegments(1).toString()));
      } else if (prependPath != null) {
         //if model.fidl => load all files relatively to prependPath/
         resourceSet.setURIConverter(new FrancaURIConverter(prependPath));
      } else if (isFirstPersistenceAction) {
         //if a/relative/path/model.fidl => load file model.fidl relatively to a/relative/path
         resourceSet.setURIConverter(new FrancaURIConverter(uri.trimSegments(1).toString()));
         uri = URI.createURI(uri.lastSegment());
      }
      isFirstPersistenceAction = false;
      return uri;
   }

}
