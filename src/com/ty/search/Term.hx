package com.ty.search;

#if (interop && java)
class Term {
	public final modifiers:java.util.List<com.ty.search.internal.Term.Modifier>;
	public final field:String;
	public final expr:com.ty.search.internal.Expr;
	
	public function new(term:com.ty.search.internal.Term) {
		modifiers = interop.Converter.nativize(term.modifiers);
		field = interop.Converter.nativize(term.field);
		expr = interop.Converter.nativize(term.expr);
	}
}
#else
typedef Term = com.ty.search.internal.Term;
#end