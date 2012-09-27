package org.franca.connectors.webidl

import org.franca.core.franca.FrancaFactory
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FAnnotationType

import java.util.List
import org.waml.w3c.webidl.webIDL.IDLDefinitions
import org.waml.w3c.webidl.webIDL.Module
import org.franca.core.franca.FModel
import org.waml.w3c.webidl.webIDL.TypeDef
import org.waml.w3c.webidl.webIDL.Interface
import org.waml.w3c.webidl.webIDL.ImplementStatement
import org.waml.w3c.webidl.webIDL.WebIDLPackage
import com.google.inject.Inject
import org.franca.core.framework.TransformationLogger

import static org.franca.core.framework.TransformationIssue.*
import org.eclipse.emf.ecore.EObject
import org.waml.w3c.webidl.webIDL.Const
import org.waml.w3c.webidl.webIDL.Attribute
import org.waml.w3c.webidl.webIDL.Operation
import org.franca.core.franca.FInterface
import org.waml.w3c.webidl.webIDL.TypeRef

class WebIDL2FrancaTransformation {

	@Inject extension TransformationLogger logger

	//List<FType> newTypes
	
	def transform (IDLDefinitions src) {
		clearIssues

		val fmodel = FrancaFactory::eINSTANCE.createFModel 
		fmodel.name = "RESULT"
		src.definitions.forEach[it | it.transformAbstractDefinition(fmodel)]

		return fmodel
	}

	def getTransformationIssues() {
		return getIssues
	}


	// **************************************************************
	// transforming subclasses of AbstractDefinition 

	def dispatch void transformAbstractDefinition (Module src, FModel fmodel) {
		src.definitions.forEach[it | it.transformAbstractDefinition(fmodel)]
	}

	def dispatch void transformAbstractDefinition (Interface src, FModel fmodel) {
		fmodel.interfaces.add(src.transformInterface)
	}

	def dispatch void transformAbstractDefinition (Exception src, FModel fmodel) {
		
	}

	def dispatch void transformAbstractDefinition (TypeDef src, FModel fmodel) {
		
	}

	def dispatch void transformAbstractDefinition (ImplementStatement src, FModel fmodel) {
		logger.addIssue(FEATURE_NOT_SUPPORTED, src, WebIDLPackage::IMPLEMENT_STATEMENT__SOURCE,
			"WebIDL 'implements' statement not supported " +
			"('" + src.source.name + " implements " + src.target.name + "')");
	}


	// **************************************************************

	def private create FrancaFactory::eINSTANCE.createFInterface transformInterface (Interface src) {
		name = src.computePrefix + src.name
		
		if (! src.superType.empty) {
			if (src.superType.size>1) {
				logger.addIssue(FEATURE_NOT_SUPPORTED, src, WebIDLPackage::INTERFACE__SUPER_TYPE,
					"Franca supports only single interface inheritance, " +
					"interface '" + name + "' has " + src.superType.size + " super types.");
			}
			base = src.superType.get(0).transformInterface
		}
		
		for(m : src.members)
			m.transformInterfaceMember(it)
	}

	def private computePrefix (Interface src) {
		var prefix = ''
		var EObject p = src
		while (p!=null) {
			p = p.eContainer
			if (p instanceof Module) {
				prefix = (p as Module).name + '.' + prefix
			}
		}
		prefix
	}


	// **************************************************************
	// transforming subclasses of InterfaceMember

	def dispatch void transformInterfaceMember (Const src, FInterface target) {
	} 

	def dispatch void transformInterfaceMember (Attribute src, FInterface target) {
		val it = FrancaFactory::eINSTANCE.createFAttribute
		name = src.name
		type = src.type.transformTypeRef
		if (src.readonly!=null)
			readonly = "readonly"
		 
		target.attributes.add(it)
	} 

	def dispatch void transformInterfaceMember (Operation src, FInterface target) {
		val it = FrancaFactory::eINSTANCE.createFMethod
		name = src.name
		target.methods.add(it)
	} 


	// **************************************************************
	// types
	
	def private create FrancaFactory::eINSTANCE.createFTypeRef transformTypeRef (TypeRef src) {
		it.predefined = FBasicTypeId::INT8 // TODO
	}  
}


