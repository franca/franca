package org.franca.core.dsl.tests;

import org.eclipse.xtext.junit4.InjectWith;
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2;
import org.eclipselabs.xtext.utils.unittesting.XtextTest;
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(XtextRunner2.class)
@InjectWith(FrancaIDLTestsInjectorProvider.class)
public class ModelTests extends XtextTest {

    @Before
    public void before() {
        suppressSerialization();
    }


    @Test
    public void test_01_Minimal() {
    	testFile("testcases/01-Minimal.fidl");
    }

    @Test
    public void test_05_EmptyTypeCollection() {
    	testFile("testcases/05-EmptyTypeCollection.fidl");
    }

    @Test
    public void test_06_MoreEmptyTypeCollections() {
    	testFile("testcases/06-MoreEmptyTypeCollections.fidl");
    }

    @Test
    public void test_07_EmptyTypeCollectionWithMeta() {
    	testFile("testcases/07-EmptyTypeCollectionWithMeta.fidl");
    }

    @Test
    public void test_10_GlobalArray() {
    	testFile("testcases/10-GlobalArray.fidl");
    }

    @Test
    public void test_11_GlobalStruct() {
    	testFile("testcases/11-GlobalStruct.fidl");
    }

    @Test
    public void test_12_GlobalUnion() {
    	testFile("testcases/12-GlobalUnion.fidl");
    }

    @Test
    public void test_13_GlobalMap() {
    	testFile("testcases/13-GlobalMap.fidl");
    }

    @Test
    public void test_14_GlobalEnum() {
    	testFile("testcases/14-GlobalEnum.fidl");
    }

    @Test
    public void test_15_GlobalTypedef() {
    	testFile("testcases/15-GlobalTypedef.fidl");
    }
    
    @Test
    public void test_20_AllPredefinedTypes() {
    	testFile("testcases/20-AllPredefinedTypes.fidl");
    }

    @Test
    public void test_21_InlineArrays() {
    	testFile("testcases/21-InlineArrays.fidl");
    }

    @Test
    public void test_25_NestedStruct() {
    	testFile("testcases/25-NestedStruct.fidl");
    }

    @Test
    public void test_30_StructInheritance() {
    	testFile("testcases/30-StructInheritance.fidl");
    }
    
    @Test
    public void test_31_UnionInheritance() {
    	testFile("testcases/31-UnionInheritance.fidl");
    }
    
    @Test
    public void test_32_EnumInheritance() {
    	testFile("testcases/32-EnumInheritance.fidl");
    }

    @Test
    public void test_35_StructInheritanceDifferentCollections() {
    	testFile("testcases/35-StructInheritanceDifferentCollections.fidl");
    }
    
    @Test
    public void test_50_InterfaceMinimal() {
    	testFile("testcases/50-InterfaceMinimal.fidl");
    }
    
    @Test
    public void test_51_InterfaceWithMeta() {
    	testFile("testcases/51-InterfaceWithMeta.fidl");
    }
    
    @Test
    public void test_55_Attribute() {
    	testFile("testcases/55-Attribute.fidl");
    }
    
    @Test
    public void test_56_AttributeWithFlags() {
    	testFile("testcases/56-AttributeWithFlags.fidl");
    }
    
    @Test
    public void test_60_Method() {
    	testFile("testcases/60-Method.fidl");
    }
    
    @Test
    public void test_65_Broadcast() {
    	testFile("testcases/65-Broadcast.fidl");
    }
    
}
