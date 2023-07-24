package why.searchsyntax;

#if (interop && java)
class Term {
	public final modifiers:java.util.List<why.searchsyntax.internal.Term.Modifier>;
	public final field:String;
	public final expr:why.searchsyntax.internal.Expr;
	
	public function new(term:why.searchsyntax.internal.Term) {
		modifiers = interop.Converter.nativize(term.modifiers);
		field = interop.Converter.nativize(term.field);
		expr = interop.Converter.nativize(term.expr);
	}
}
#elseif(interop && js)
@:keep
class Term {
	public final modifiers:Array<why.searchsyntax.internal.Term.Modifier>;
	public final field:String;
	public final expr:Dynamic;
	
	public function new(term:why.searchsyntax.internal.Term) {
		modifiers = interop.Converter.nativize(term.modifiers);
		field = interop.Converter.nativize(term.field);
		expr = interop.Converter.nativize(term.expr);
	}
}
#else
typedef Term = why.searchsyntax.internal.Term;
#end