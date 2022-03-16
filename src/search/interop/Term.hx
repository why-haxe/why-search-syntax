package search.interop;

class Term {
	public final modifiers:java.util.List<search.Term.Modifier>;
	public final field:String;
	public final expr:Expr;
	
	public function new(term:search.Term) {
		modifiers = interop.Converter.nativize(term.modifiers);
		field = interop.Converter.nativize(term.field);
		expr = interop.Converter.nativize(term.expr);
	}
}