/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.core.dsl.validation;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.franca.core.franca.FArgument;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FrancaPackage;
import org.franca.core.franca.FBasicTypeId;

//TODO: this class is not depending on a particular DSL, should be factored to a common helper package
public class ValidationHelpers
{

   // simple helper for finding duplicates in ELists
   public static <T extends EObject> int checkDuplicates(
         ValidationMessageReporter reporter, Iterable<T> items,
         EStructuralFeature feature, String description)
   {
      int nErrors = 0;
      String msg = "Duplicate " + description + ' ';

      // for each name store the element of its first occurrence
      Map<String, EObject> firstOccurrenceOfName = new HashMap<String, EObject>();
      Set<String> duplicateNames = new HashSet<String>();

      // iterate (once!) over all types in the model
      for(EObject i : items)
      {
         String name = toName(i);

         // if the name already occurred we have a duplicate name and hence an error
         if(firstOccurrenceOfName.get(name) != null)
         {
            duplicateNames.add(name);
            reporter.reportError(msg + "'" + name + "'", i, feature);
            nErrors++;
         }
         else
         {
            firstOccurrenceOfName.put(name, i);
         }
      }

      // now create the error for the first occurrence of a duplicate name
      for(String s : duplicateNames)
      {
         reporter.reportError(msg + "'" + s + "'", firstOccurrenceOfName.get(s), feature);
         nErrors++;
      }

      return nErrors;
   }

 
   /**
    * Helper function that computes the name of a method, broadcast including its signature. 
    * Used to identify uniquely the element in a restricted scope. 
    * 
    * @param e the object to get the name
    * @return the name
    */
   private static String toName(EObject e)
   {
      String name = new String();

      if (e instanceof FMethod)
      {
         FMethod method = (FMethod) e;
         
         name += method.getName();
         for (FArgument arg: method.getInArgs())
         {
            name += getTypeName(arg);
         }
         for (FArgument arg: method.getOutArgs())
         {
            name += getTypeName(arg);
         }
      } else if (e instanceof FBroadcast)
      {
         FBroadcast broadcast = (FBroadcast) e;
         
         name += broadcast.getName();
         for (FArgument arg: broadcast.getOutArgs())
         {
            name += getTypeName(arg);
         }   
      } else 
      {
         name = e.eGet(FrancaPackage.Literals.FMODEL_ELEMENT__NAME).toString();
      }
      return name;
   }
   
   private static String getTypeName(FArgument arg)
   {
      String typeName = new String();
      
      if (arg.getArray() != null) 
      {
         typeName += arg.getArray();
      }
      if (arg.getType().getPredefined().getValue() != FBasicTypeId.UNDEFINED_VALUE)
      {
         typeName += arg.getType().getPredefined().getLiteral();
      }
      if (arg.getType().getDerived().getName() != null)
      {
         typeName += arg.getType().getDerived().getName();
      }
      return typeName;
   }
   
   public static class Entry
   {
      public EObject object;
      public String  name;

      public Entry(EObject object, String name)
      {
         this.object = object;
         this.name = name;
      }
   }

   public static class NameList
   {
      private List<Entry> list = new ArrayList<Entry>();

      public void add(EObject object, String name)
      {
         list.add(new Entry(object, name));
      }

      public Iterable<Entry> iterable()
      {
         return list;
      }
   }

   public static NameList createNameList()
   {
      return new NameList();
   }

   // more complex helper for finding duplicates in arbitrary sets of EObjects
   // (the EObject names must be determined by the caller)
   public static int checkDuplicates(ValidationMessageReporter reporter, NameList items,
		   EStructuralFeature feature, String description)
   {
      int nErrors = 0;
      String msg = "Duplicate " + description + ' ';

      // for each name store the element of its first occurrence
      Map<String, EObject> firstOccurrenceOfName = new HashMap<String, EObject>();
      Set<String> duplicateNames = new HashSet<String>();

      // iterate (once!) over all types in the model
      for(Entry p : items.iterable())
      {
         // if the name already occurred we have a duplicate name and hence an error
         if(firstOccurrenceOfName.get(p.name) != null)
         {
            duplicateNames.add(p.name);
            reporter.reportError(msg + p.name, p.object, feature);
            nErrors++;
         }
         else
         {
            firstOccurrenceOfName.put(p.name, p.object);
         }
      }

      // now create the error for the first occurrence of a duplicate name
      for(String s : duplicateNames)
      {
         reporter.reportError(msg + "'" + s + "'", firstOccurrenceOfName.get(s), feature);
         nErrors++;
      }

      return nErrors;
   }

}
