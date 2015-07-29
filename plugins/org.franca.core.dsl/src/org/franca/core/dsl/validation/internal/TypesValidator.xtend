/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation.internal;

import java.math.BigInteger
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.franca.core.typesystem.IssueCollector
import org.franca.core.typesystem.TypeIssue
import org.franca.core.typesystem.TypeSystem
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FBracketInitializer
import org.franca.core.franca.FCompoundInitializer
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FDeclaration
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FExpression
import org.franca.core.franca.FInitializer
import org.franca.core.franca.FInitializerExpression
import org.franca.core.franca.FMapType
import org.franca.core.franca.FStructType
import org.franca.core.typesystem.ActualType
import org.franca.core.utils.ExpressionEvaluator

import static org.franca.core.franca.FrancaPackage.Literals.*

import static extension org.franca.core.FrancaModelExtensions.*
import static org.franca.core.typesystem.ActualType.*

class TypesValidator {

	def static checkConstantType (ValidationMessageReporter reporter, FConstantDef constantDef) {
		checkConstantRHS(constantDef.rhs, typeFor(constantDef),
			reporter, constantDef, FCONSTANT_DEF__RHS, -1
		)
	}

	def static checkConstantType (ValidationMessageReporter reporter, FDeclaration declaration) {
		checkConstantRHS(declaration.rhs, typeFor(declaration),
			reporter, declaration, FDECLARATION__RHS, -1
		)
	}

	def static void checkEnumValueType (ValidationMessageReporter reporter, FEnumerator enumerator) {
		// for backward compatibility, we allow Strings as enum values
		// TODO: remove this section when the deprecated feature is removed
		val type = getCheckedExpressionType(reporter, enumerator.value, null,
			enumerator, FENUMERATOR__VALUE, -1
		)
		if (TypeSystem.isSameType(type, TypeSystem::STRING_TYPE)) {
			// String values for enumerators are deprecated
			reporter.reportWarning(
				"Deprecated: String value for enumerator (use integer expression instead).",
				enumerator, FENUMERATOR__VALUE)
			return
		}

		// this is the "real" check, value must be integer
		checkExpression(reporter, enumerator.value, TypeSystem.INTEGER_TYPE,
			enumerator, FENUMERATOR__VALUE, -1
		)
	}


	def private static void checkConstantRHS (
		FInitializerExpression rhs,
		ActualType typeLHS,
		ValidationMessageReporter reporter,
		EObject ctxt,
		EStructuralFeature feature,
		int index
	) {
		switch (rhs) {
			FExpression: {
				checkExpression(reporter, rhs, typeLHS, ctxt, feature, index)
			}
			FInitializer: {
				checkInitializer(rhs, typeLHS, reporter, ctxt, feature, index)
			}
		}
	}

	def private static dispatch checkInitializer (
		FBracketInitializer rhs,
		ActualType type,
		ValidationMessageReporter reporter,
		EObject ctxt,
		EStructuralFeature feature,
		int index
	) {
		if (type.isImplicitArray) {
			// we have a bracket initializer for an implicit array
			val plainType = typeFor(type.typeRef)
			checkArrayElements(rhs, plainType, reporter)
		} else {
			// check if bracket initializer is appropriate for the expected type
			if (! (type.isByteBuffer || type.isExplicitArray || type.isMap)) {
				reporter.reportError(
						"invalid initializer in constant definition (expected " +
							type.getTypeString + ")",
						ctxt, feature);
				return;
			}
			
			if (type.isByteBuffer) {
				for(e : rhs.elements) {
					val idx = rhs.elements.indexOf(e)
					if (e.second!=null) {
						reporter.reportError(
								"invalid initializer (expected 0..255)",
								rhs, FBRACKET_INITIALIZER__ELEMENTS, idx);
					} else {
						val expr = e.first
						if (expr instanceof FExpression) {
							val res = ExpressionEvaluator.evaluateInteger(expr)
							if (res==null) {
								reporter.reportError(
										"invalid byte buffer element",
										rhs, FBRACKET_INITIALIZER__ELEMENTS, idx);
							} else {
								if (res.signum<0 || res.compareTo(BigInteger.valueOf(255))>0) {
									reporter.reportError(
											"byte buffer element must be UInt8",
											rhs, FBRACKET_INITIALIZER__ELEMENTS, idx);
								}
							}
						}
					}
				}
			} else if (type.isArray) {
				val t = type.actualDerived as FArrayType
				checkArrayElements(rhs, typeFor(t.elementType), reporter)
			} else if (type.isMap) {
				val t = type.actualDerived as FMapType
				for(e : rhs.elements) {
					val idx = rhs.elements.indexOf(e)
					if (e.second==null) {
						reporter.reportError(
								"invalid initializer for map element",
								rhs, FBRACKET_INITIALIZER__ELEMENTS, idx);
					} else {
						checkConstantRHS(e.first,
							typeFor(t.keyType),
							reporter, e, FELEMENT_INITIALIZER__FIRST, -1
						)
						checkConstantRHS(e.second,
							typeFor(t.valueType),
							reporter, e, FELEMENT_INITIALIZER__SECOND, -1
						)
					}
				}
			}
		}
	}
	
	def private static checkArrayElements(
		FBracketInitializer rhs,
		ActualType type,
		ValidationMessageReporter reporter
	) {
		for(e : rhs.elements) {
			val idx = rhs.elements.indexOf(e)
			if (e.second!=null) {
				reporter.reportError(
						"invalid initializer for array element",
						rhs, FBRACKET_INITIALIZER__ELEMENTS, idx);
			} else {
				checkConstantRHS(e.first, type,
					reporter, e, FELEMENT_INITIALIZER__FIRST, -1
				)
			}
		}
	}
	
	def private static dispatch checkInitializer (
		FCompoundInitializer rhs,
		ActualType type,
		ValidationMessageReporter reporter,
		EObject ctxt,
		EStructuralFeature feature,
		int index
	) {
		if (type.isImplicitArray) {
			// this is a compound initializer, but we expected an initializer for an (implicit) array
			reporter.reportError(
					"Invalid array initializer in constant definition",
					ctxt, feature, index);
			return;
		}

		if (! type.isCompound) {
			reporter.reportError(
					"invalid compound initializer in constant definition (expected " +
						type.getTypeString + ")",
					ctxt, feature, index);
			return;
		}
		
		if (type.isStruct) {
			val t = type.actualDerived as FStructType
			val elems = t.getAllElements
			
			// check if there are initializers for all struct elements
			val fields = rhs.elements.map[element]
			for(e : elems) {
				if (! fields.contains(e)) {
					reporter.reportError(
							"initializer for element '" + e.name + "' missing",
							ctxt, feature, index);
				}
			}
			
			// check the types for all initializers
			for(e : rhs.elements) {
				checkConstantRHS(e.value, typeFor(e.element),
					reporter, e, FFIELD_INITIALIZER__VALUE, -1
				)
			}
		} else if (type.isUnion) {
			if (rhs.elements.size!=1) {
				reporter.reportError(
						"union initializer must have exactly one element",
						ctxt, feature, index);
			}

			// check type
			val e = rhs.elements.get(0)
			checkConstantRHS(e.value, typeFor(e.element),
				reporter, e, FFIELD_INITIALIZER__VALUE, 0
			)
		}
	}

	def private static dispatch checkInitializer (
		FInitializer rhs,
		ActualType type,
		ValidationMessageReporter reporter,
		EObject ctxt,
		EStructuralFeature feature,
		int index
	) {
		throw new RuntimeException("Unknown FInitializer type '" + rhs.class.toString + "'")
	}
	

	def static boolean checkExpression (
			ValidationMessageReporter reporter,
			FExpression expr,
			ActualType expected,
			EObject loc, EStructuralFeature feat)
	{
		checkExpression(reporter, expr, expected, loc, feat, -1)
	}

	/**
	 * Check if an expression has the expected type.
	 * 
	 * If any issues occur while checking the expression, these will be reported.
	 * 
	 * @param expr  the expression which should be checked
	 * @param expected  the expected type, must not be null
	 */
	def private static boolean checkExpression (
			ValidationMessageReporter reporter,
			FExpression expr,
			ActualType expected,
			EObject loc, EStructuralFeature feat, int index)
	{
		val type = getCheckedExpressionType(reporter, expr, expected, loc, feat, index)
		type!=null
	}
	
	/**
	 * Get the type of an expression.
	 * 
	 * If param expected is null, the type of the expression will be returned.
	 * If the expression is inconsistent and no type can be determined, the 
	 * relevant issues will be reported (via reporter) and null will be returned.
	 * 
	 * If param expected is not null, the above functionality will be done, 
	 * including an additional check that the overall expression type is as expected.
	 *  
	 * @param expr  the expression which should be checked
	 * @param expected  the expected type, may be null
	 * @param isImplicitArray true if the expected type is an implicit array 
	 */
	def private static ActualType getCheckedExpressionType (
			ValidationMessageReporter reporter,
			FExpression expr,
			ActualType expected,
			EObject loc, EStructuralFeature feat, int index)
	{
		val ts = new TypeSystem
		val issues = new IssueCollector
		val type = ts.checkType(expr, expected, issues, loc, feat)
		if (type==null) {
			if (issues.issues.empty) {
				// no issues, usually this is due to an undefined reference (which will
				// produce a generic validation error)
			} else {
				for(TypeIssue ti : issues.issues) {
					reporter.reportError(ti.message, ti.location, ti.feature)
				}
			}
		}
		type
	}
}

