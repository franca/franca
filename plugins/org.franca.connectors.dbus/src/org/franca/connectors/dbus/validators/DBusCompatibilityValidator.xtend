/*******************************************************************************
* Copyright (c) 2014 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.connectors.dbus.validators

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtend.typesystem.emf.EcoreUtil2
import org.eclipse.xtext.validation.ValidationMessageAcceptor
import org.franca.core.dsl.validation.IFrancaExternalValidator
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMapType
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FUnionType

import static org.franca.core.franca.FrancaPackage.Literals.*

import static extension org.franca.core.framework.FrancaHelpers.*
import static extension org.franca.core.utils.ExpressionEvaluator.*

import static extension org.franca.connectors.dbus.util.DBusLogic.*

/**
 * External Franca IDL validator for compatibility with plain D-Bus.
 * 
 * <p>This validator checks all features which can not be implemented by
 * plain D-Bus. If it has to be enforced to be compatible with plain D-Bus
 * in a specific development environment, the warningsAsErrors flag should
 * be set.</p>
 * 
 * <p>Note: CommonAPI supports most of the above features; however, they will
 * be "emulated" by additional D-Bus interaction. Therefore, the resulting
 * D-Bus interfaces will be different from plain D-Bus introspection
 * when using CommonAPI.</p>
 */
class DBusCompatibilityValidator implements IFrancaExternalValidator {
	val MESSAGE_PREFIX = "D-Bus compatibility: "

	static var active = true
	static var warningsAsErrors = false

	/** Deactivate this validator. */
	def static setActive(boolean flag) {
		active = flag
	}	

	/** Report errors instead of warnings. */
	def static setWarningsAsErrors(boolean flag) {
		warningsAsErrors = flag
	}	

	override validateModel(FModel model,
		ValidationMessageAcceptor issues
	) {
		if (!active)
			return

		val all = EcoreUtil2::allContents(model)
		all.filter(typeof(FTypeRef)).check(issues)
		all.filter(typeof(FEnumerator)).check(issues)
		all.filter(typeof(FMapType)).check(issues)
		all.filter(typeof(FStructType)).check(issues)
		all.filter(typeof(FUnionType)).check(issues)
		all.filter(typeof(FInterface)).check(issues)
		all.filter(typeof(FAttribute)).check(issues)
		all.filter(typeof(FMethod)).check(issues)
		all.filter(typeof(FBroadcast)).check(issues)
	}

	def private check(Iterable<? extends EObject> items, ValidationMessageAcceptor issues) {
		for(i : items)
			i.checkItem(issues)
	}

	def private dispatch checkItem(FTypeRef item, ValidationMessageAcceptor issues) {
		val t = item.actualPredefined
		if (t!==null) {
			if (t==FBasicTypeId::INT8) {
				issues.warning(
					"Int8 type is not supported by D-Bus",
					item, FTYPE_REF__PREDEFINED)
			}
			if (t==FBasicTypeId::FLOAT) {
				issues.warning(
					"Float type is not supported by D-Bus",
					item, FTYPE_REF__PREDEFINED)
			}
		}
	}

	def private dispatch checkItem(FEnumerator item, ValidationMessageAcceptor issues) {
		if (item.value!==null) {
			try {
				val v = item.value.evaluateIntegerOrParseString
				if (v!==null) {
					if (v.signum == -1) {
						issues.warning(
							"Enumerator values must not be negative",
							item, FMODEL_ELEMENT__NAME)
					}
				}
			} catch (NumberFormatException e) {
				issues.warning(
					"Invalid number format in enumerator value",
					item, FMODEL_ELEMENT__NAME)
			}
		}
	}

	def private dispatch checkItem(FMapType item, ValidationMessageAcceptor issues) {
		val key = item.keyType
		if (! key.isProperDictKey) {
			issues.warning(
				"D-Bus dictionaries support only primitive key types",
				item, FMAP_TYPE__KEY_TYPE)
		}
	}

	def private dispatch checkItem(FStructType item, ValidationMessageAcceptor issues) {
		if (item.base!==null) {
			issues.info(
				"Inheritance for struct types has to be emulated in D-Bus",
				item, FSTRUCT_TYPE__BASE)
		}

		if (item.polymorphic) {
			issues.info(
				"Polymorphic struct types have to be emulated in D-Bus",
				item, FSTRUCT_TYPE__POLYMORPHIC)
		}
	}

	def private dispatch checkItem(FUnionType item, ValidationMessageAcceptor issues) {
		if (item.base!==null) {
			issues.warning(
				"Inheritance for unions is not supported by D-Bus",
				item, FUNION_TYPE__BASE)
		}
	}

	def private dispatch checkItem(FInterface item, ValidationMessageAcceptor issues) {
		if (item.base!==null) {
			issues.warning(
				"Inheritance for interfaces is not supported in D-Bus",
				item, FINTERFACE__BASE)
		}

		if (item.managedInterfaces!==null && item.managedInterfaces.size>0) {
			issues.warning(
				"Managed interfaces are not supported in D-Bus",
				item, FINTERFACE__MANAGED_INTERFACES)
		}
	}

	def private dispatch checkItem (FAttribute item, ValidationMessageAcceptor issues) {
		if (item.noSubscriptions) {
			issues.warning(
				"Attribute subscription cannot be discarded in D-Bus",
				item, FATTRIBUTE__NO_SUBSCRIPTIONS)
		}
	}

	def private dispatch checkItem (FMethod item, ValidationMessageAcceptor issues) {
		if (item.fireAndForget) {
			issues.warning(
				"One-way methods are not supported in plain D-Bus",
				item, FMETHOD__FIRE_AND_FORGET)
		}
	}

	def private dispatch checkItem (FBroadcast item, ValidationMessageAcceptor issues) {
		if (item.selective) {
			issues.warning(
				"Selective broadcasts are not supported in plain D-Bus",
				item, FBROADCAST__SELECTIVE)
		}
	}

	def private dispatch checkItem (EObject item, ValidationMessageAcceptor issues) {
		throw new RuntimeException("Invalid object type in validator: " + item.class.toString)
	}


	def private warning (ValidationMessageAcceptor messageAcceptor,
		String txt, EObject object, EStructuralFeature feature
	) {
		val message = MESSAGE_PREFIX + txt + "."
		if (warningsAsErrors) {
			messageAcceptor.acceptError(
				message, object, feature,
				ValidationMessageAcceptor.INSIGNIFICANT_INDEX,
				null
			)
		} else {
			messageAcceptor.acceptWarning(
				message, object, feature,
				ValidationMessageAcceptor.INSIGNIFICANT_INDEX,
				null
			)
		}
	}
	
//	def private error (ValidationMessageAcceptor messageAcceptor,
//		String txt, EObject object, EStructuralFeature feature
//	) {
//		val message = MESSAGE_PREFIX + txt + "."
//		messageAcceptor.acceptError(
//			message, object, feature,
//			ValidationMessageAcceptor.INSIGNIFICANT_INDEX,
//			null
//		)
//	}

	def private info (ValidationMessageAcceptor messageAcceptor,
		String txt, EObject object, EStructuralFeature feature
	) {
		val message = MESSAGE_PREFIX + txt + "."
		messageAcceptor.acceptInfo(
			message, object, feature,
			ValidationMessageAcceptor.INSIGNIFICANT_INDEX,
			null
		)
	}
}
