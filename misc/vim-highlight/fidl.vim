" Vim syntax file
" Language:    	   	FIDL (FRANCA Interface Description Language)
" Maintainer:  	   	Gabriel Almeida <gabrielmarchesan AT gmail DOT com>
" Latest Revision:   	Sat Jun 18 2016
" History:
" 0.1 (2015-06-30): Gabriel Almeida - first proposal
" 0.2 (2016-06-18): Oleksandr Kravchuk - cleanups and small improvements

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Read the C syntax to start with
if version < 600
  so <sfile>:p:h/c.vim
else
  runtime! syntax/c.vim
  unlet b:current_syntax
endif

" Read the Javacc syntax to start with
if version < 600
  so <sfile>:p:h/javacc.vim
else
  runtime! syntax/javacc.vim
  unlet b:current_syntax
endif

" Keywords codelanguage-def[Franca]
syn keyword fBoolean             true false  skipwhite
syn keyword fType                Int8 UInt8 Int16 UInt16 Int32 UInt32 Int64 UInt64 Boolean String Float Double ByteBuffe  skipwhite
syn keyword fStructure           struct union enumeration typedef  skipwhite

syn keyword syntaxElementKeyword typeCollection interface attribute method broadcast in out error  skipempty skipwhite 
syn keyword syntaxElementKeyword readonly noSubscriptions fireAndForget selective manages array of  skipempty skipwhite
syn keyword syntaxElementKeyword is map to extends polymorphic  skipempty skipwhite
syn keyword syntaxElementKeyword contract PSM vars state transition initial call respond signal set update  skipempty skipwhite
syn keyword syntaxElementKeyword version major minor const  skipempty skipwhite

" Keywords codelanguage-def[FDeploy]
syn keyword syntaxElementKeyword import from specification extends for optional default providers instances interfaces  skipempty skipwhite
syn keyword syntaxElementKeyword type_collections attributes methods broadcasts arguments structs struct_fields  skipempty skipwhite
syn keyword syntaxElementKeyword unions union_fields arrays enumerations enumerators strings numbers integers floats  skipempty skipwhite
syn keyword syntaxElementKeyword Boolean Integer String Interface define provider instance interface attribute method  skipempty skipwhite
syn keyword syntaxElementKeyword broadcast in out array struct enumeration false true  skipempty skipwhite

" Keywords codelanguage-def[Xtend]
syn keyword syntaxElementKeyword abstract continue def override for new switch assert default goto package synchronized  skipempty skipwhite
syn keyword syntaxElementKeyword boolean do if private this it break double implements protected throw byte else import  skipempty skipwhite
syn keyword syntaxElementKeyword public throws case enum instanceof return catch extends int short try char final static  skipempty skipwhite
syn keyword syntaxElementKeyword void class finally long float super while create dispatch extension typeof as val var  skipempty skipwhite
syn keyword syntaxElementKeyword true false null IF ELSE ELSEIF ENDIF FOR ENDFOR BEFORE AFTER SEPARATOR  skipempty skipwhite

syn keyword fTodo      contained TODO FIXME XXX NOTE

hi def link fConstant 	Constant
hi def link fBoolean 	Boolean
hi def link fType       Type
hi def link fTodo       Todo
hi def link fStructure  Structure
hi def link syntaxElementKeyword Keyword

let b:current_syntax = "fidl"

