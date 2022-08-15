package org.franca.connectors.dbus.tests;

import org.eclipse.emf.compare.diff.DefaultDiffEngine;
import org.eclipse.emf.compare.diff.FeatureFilter;
import org.eclipse.emf.ecore.EAttribute;

import model.emf.dbusxml.DbusxmlPackage;

public class DBusDiffEngine extends DefaultDiffEngine {
	
	@Override
	protected FeatureFilter createFeatureFilter() {
		// In EMFCompare versions later than 3.0.1, there is an exception if the left model of the comparison
		// does not contain a DocumentType.mixed attribute (which is the case if the model has been created
		// by the fidl=>dbus transformation). Ignore these differences as they do not relate to functional
		// features of the transformation.
		// Exception was introduced by commit https://github.com/eclipse/emf.compare/commit/85470799137798914a00adb5a19789c6074bdbb6#diff-6f326c3cf977c5f7b073f7d184de2a65
		return new FeatureFilter() {
			@Override
			protected boolean isIgnoredAttribute(EAttribute attribute) {
				return attribute == DbusxmlPackage.Literals.DOCUMENT_ROOT__MIXED
						|| super.isIgnoredAttribute(attribute);
			}
		};
	}
	
}
