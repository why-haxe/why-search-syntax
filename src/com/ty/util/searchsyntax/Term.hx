package com.ty.util.searchsyntax;

#if (interop && java)
class Term {
	public final modifiers:java.util.List<com.ty.util.searchsyntax.internal.Term.Modifier>;
	public final field:String;
	public final expr:com.ty.util.searchsyntax.internal.Expr;
	
	public function new(term:com.ty.util.searchsyntax.internal.Term) {
		modifiers = interop.Converter.nativize(term.modifiers);
		field = interop.Converter.nativize(term.field);
		expr = interop.Converter.nativize(term.expr);
	}
}
#else
typedef Term = com.ty.util.searchsyntax.internal.Term;
#end