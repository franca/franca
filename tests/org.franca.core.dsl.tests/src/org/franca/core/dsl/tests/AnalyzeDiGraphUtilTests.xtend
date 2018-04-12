package org.franca.core.dsl.tests

import com.google.common.collect.ArrayListMultimap
import com.google.common.collect.Multimap
import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.dsl.validation.util.DiGraphAnalyzationUtil
import org.franca.core.utils.digraph.Digraph
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class DiGraphAnalyzationUtilsTests extends ValidationTestBase {
	@Inject extension DiGraphAnalyzationUtil 
	
	
	@Test
	def void testToMultiMap() {
		val Digraph<Integer> dg = new Digraph<Integer>()
		for(from : 1..10){
			for(to: from..10){
				dg.addEdge(from,to)
			}
		}
		val mm = dg.edgesIterator.toMultiMap
		assertEquals(10, mm.keySet.size)
		assertEquals(mm.get(3), newArrayList(3,4,5,6,7,8,9,10))
	}
	
	@Test
	def void testSeparateCycles_OneCycle_OneElement() {
		val mm = ArrayListMultimap::create()
		mm.put(1,1)
		val cycles =  mm.separateCycles
		assertEquals(1, cycles.size)
		assertEquals(newArrayList(1), cycles.get(0))
	}
	@Test
	def void testSeparateCycles_OneCycle_TwoElements() {
		val mm = ArrayListMultimap::create()
		mm.addCycle(1..2)
		val cycles =  mm.separateCycles
		assertEquals(1, cycles.size)
		assertEquals(newArrayList(1,2), cycles.get(0).sort)
	}
	@Test
	def void testSeparateCycles_OneCycle_ManyElements() {
		val mm = ArrayListMultimap::create()
		mm.addCycle(1..10)
		var cycles =  mm.separateCycles
		assertEquals(1, cycles.size)
		assertEquals((1..10).toList, cycles.get(0).sort)
	}

	@Test
	def void testSeparateCycles_ManyCycles() {
		val mm = ArrayListMultimap::create()
		mm.addCycle(1..10)
		mm.addCycle(1000..1001)
		mm.put(100,100) 
		var cycles =  mm.separateCycles
		println(cycles)
		assertEquals(3, cycles.size)
		assertEquals((1..10).toList, cycles.get(0).sort)
		assertEquals(newArrayList(100), cycles.get(1).sort)
		assertEquals(newArrayList(1000,1001), cycles.get(2).sort)
	}
	
	@Test
	def void test_SeparateCycles_ManyCycles() {
		val mm = ArrayListMultimap::create()
		mm.addCycle(1..2)
		mm.addCycle(10..11)
		println(mm)
	}
	
	
	def addCycle(Multimap<Integer,Integer> mm, IntegerRange range){
		for(i : range.start..range.end-1){
			mm.put(i,(i+1))
		}
		mm.put(range.end,range.start) 
	}
	
	@Test
	def void testSeparateCycles_IntersectingCycles() {
		val mm = ArrayListMultimap::create()
		mm.addCycle(1..5)
		mm.addCycle(10..15)
		mm.put(1,10) 
		mm.put(10,1)
		mm.put(100,100)
		var cycles =  mm.separateCycles
		println(cycles)
		assertEquals(2, cycles.size)
		assertEquals(newArrayList(1,2,3,4,5,10,11,12,13,14,15), cycles.get(0).sort)
		assertEquals(newArrayList(100), cycles.get(1).sort)
	}
	
}