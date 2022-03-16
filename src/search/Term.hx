package search;

#if (interop && java)
class Term {
	public final modifiers:java.util.List<search.internal.Term.Modifier>;
	public final field:String;
	public final expr:search.internal.Expr;
	
	public function new(term:search.internal.Term) {
		modifiers = interop.Converter.nativize(term.modifiers);
		field = interop.Converter.nativize(term.field);
		expr = interop.Converter.nativize(term.expr);
	}
}
#else
typedef Term = search.internal.Term;
#end