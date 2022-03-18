package com.kevinresol.searchsyntax;

#if (interop && java)
class Term {
	public final modifiers:java.util.List<com.kevinresol.searchsyntax.internal.Term.Modifier>;
	public final field:String;
	public final expr:com.kevinresol.searchsyntax.internal.Expr;
	
	public function new(term:com.kevinresol.searchsyntax.internal.Term) {
		modifiers = interop.Converter.nativize(term.modifiers);
		field = interop.Converter.nativize(term.field);
		expr = interop.Converter.nativize(term.expr);
	}
}
#else
typedef Term = com.kevinresol.searchsyntax.internal.Term;
#end