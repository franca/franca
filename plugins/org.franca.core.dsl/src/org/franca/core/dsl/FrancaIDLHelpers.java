/*******************************************************************************
 * Copyright (c) 2012 Harman International (http://www.harman.com).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.Constants;
import org.franca.core.franca.FModel;
import org.franca.core.franca.Import;
import org.franca.core.utils.ModelPersistenceHandler;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Provider;
import com.google.inject.name.Named;

public class FrancaIDLHelpers {

   @Inject
   private Provider<ResourceSet> resourceSetProvider;

   @Inject
   @Named(Constants.FILE_EXTENSIONS)
   private String fileExtension;

   public String getFileExtension() {
      return fileExtension;
   }

   /**
    * Load Franca IDL model file (*.fidl) and all imported files recursively.
    * 
    * @param fileName
    *           name of Franca file (suffix .fidl is optional)
    * @return the root entity of the Franca IDL model
    */
   public FModel loadModel(String fileName) {
      return loadModel(fileName, null);
   }

   /**
    * Load Franca IDL model file (*.fidl) and all imported files recursively.
    * 
    * @param fileName
    *           name of Franca file (suffix .fidl is optional)
    * @param prependPath
    *           if not null work relatively to this path
    * 
    * @return the root entity of the Franca IDL model
    */
   @SuppressWarnings("unused")
   public FModel loadModel(String fileName, String prependPath) {
      if (fileName == null)
         return null;
      if (!fileName.endsWith("." + fileExtension)) {
         fileName += "." + fileExtension;
      }
      ModelPersistenceHandler persistenceHandler = new ModelPersistenceHandler(resourceSetProvider.get(), prependPath);

      // load root model
      FModel model = (FModel) persistenceHandler.loadModel(fileName);

      // and all its imports
      for (Import fidlImport : model.getImports()) {
         if (persistenceHandler.loadModel(fidlImport.getImportURI()) == null) {
            System.out.println("Could not load imported file " + fidlImport.getImportURI());
         }
      }

      if (model == null) {
         System.out.println("Error: Could not load Franca IDL model from file " + fileName);
      } else {
         System.out.println("Loaded Franca IDL model from file " + fileName);
      }
      return model;
   }

   /**
    * Save a Franca IDL model to file (*.fidl).
    * 
    * @param model
    *           the root of model to be saved
    * @param fileName
    *           name of Franca file (suffix .fidl is optional)
    * @return true if save could be completed successfully
    */
   public boolean saveModel(FModel model, String fileName) {
      return saveModel(model, fileName, null);
   }

   /**
    * Save a Franca IDL model to file (*.fidl).
    * 
    * @param model
    *           the root of model to be saved
    * @param fileName
    *           name of Franca file (suffix .fidl is optional)
    * @param prependPath
    *           if not null work relatively to this path
    * 
    * @return true if save could be completed successfully
    */
   public boolean saveModel(FModel model, String fileName, String prependPath) {
      String fn = fileName;
      boolean ret = true;

      if (!fn.endsWith("." + fileExtension)) {
         fn += "." + fileExtension;
      }
      ModelPersistenceHandler persistenceHandler = new ModelPersistenceHandler(model.eResource().getResourceSet(),
            prependPath);

      // save all model imports
      for (Import fidlImport : model.getImports()) {
         ret = ret
               && persistenceHandler.saveModel(
                     model.eResource().getResourceSet().getResource(URI.createURI(fidlImport.getImportURI()), false)
                           .getContents().get(0), fidlImport.getImportURI());
      }
      // save the root model
      ret = ret && persistenceHandler.saveModel(model, fn);

      return ret;
   }

   // singleton
   private static FrancaIDLHelpers instance = null;

   public static FrancaIDLHelpers instance() {
      if (instance == null) {
         Injector injector = new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
         instance = injector.getInstance(FrancaIDLHelpers.class);
      }
      return instance;
   }
}
