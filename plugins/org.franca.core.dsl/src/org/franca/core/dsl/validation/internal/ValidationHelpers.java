/*******************************************************************************
 * Copyright (c) 2012 Harman International (http://www.harman.com).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation.internal;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

//TODO: this class is not depending on a particular DSL, should be factored to a common helper package
public class ValidationHelpers {

   // simple helper for finding duplicates in ELists
   public static <T extends EObject> int checkDuplicates(ValidationMessageReporter reporter, Iterable<T> items,
         EStructuralFeature feature, String description) {
      int nErrors = 0;
      String msg = "Name conflict for " + description + ' ';

      // for each name store the element of its first occurrence
      Map<String, EObject> firstOccurrenceOfName = new HashMap<String, EObject>();
      Set<String> duplicateNames = new HashSet<String>();

      // iterate (once!) over all types in the model
      for (EObject i : items) {
         String name = FrancaNameProvider.getName(i);

         // if the name already occurred we have a duplicate name and hence an error
         if (firstOccurrenceOfName.get(name) != null) {
            duplicateNames.add(name);
            reporter.reportError(msg + "'" + name + "'", i, feature);
            nErrors++;
         } else {
            firstOccurrenceOfName.put(name, i);
         }
      }

      // now create the error for the first occurrence of a duplicate name
      for (String s : duplicateNames) {
         reporter.reportError(msg + "'" + s + "'", firstOccurrenceOfName.get(s), feature);
         nErrors++;
      }

      return nErrors;
   }

   public static class Entry {
      public EObject object;
      public String name;

      public Entry(EObject object, String name) {
         this.object = object;
         this.name = name;
      }

      @Override
      public String toString() {
         return "'" + name + "'";
      }
   }

   public static class NameList {
      private List<Entry> list = new ArrayList<Entry>();

      public void add(EObject object, String name) {
          list.add(new Entry(object, name));
       }

      public Iterable<Entry> iterable() {
         return list;
      }

      @Override
      public String toString() {
         return list.toString();
      }
   }

   public static NameList createNameList() {
      return new NameList();
   }

   // more complex helper for finding duplicates in arbitrary sets of EObjects
   // (the EObject names must be determined by the caller)
   public static int checkDuplicates(ValidationMessageReporter reporter, NameList items, EStructuralFeature feature,
         String description) {
      int nErrors = 0;
      String msg = "Duplicate " + description + ' ';

      // for each name store the element of its first occurrence
      Map<String, EObject> firstOccurrenceOfName = new HashMap<String, EObject>();
      Set<String> duplicateNames = new HashSet<String>();

      // iterate (once!) over all types in the model
      for (Entry p : items.iterable()) {
         // if the name already occurred we have a duplicate name and hence an error
         if (firstOccurrenceOfName.get(p.name) != null) {
            duplicateNames.add(p.name);
            reporter.reportError(msg + "'" + p.name + "'", p.object, feature);
            nErrors++;
         } else {
            firstOccurrenceOfName.put(p.name, p.object);
         }
      }

      // now create the error for the first occurrence of a duplicate name
      for (String s : duplicateNames) {
         reporter.reportError(msg + "'" + s + "'", firstOccurrenceOfName.get(s), feature);
         nErrors++;
      }

      return nErrors;
   }

}
