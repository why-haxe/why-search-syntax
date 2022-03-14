package search;

@:structInit
class Term {
	public final modifiers:Array<Modifier>;
	public final field:String;
	public final expr:Expr;
	
	#if js
	public function toObject() {
		return {
			modifiers: modifiers,
			field: field,
			expr: expr.toObject(),
		}
	}
	#end
}

enum abstract Modifier(String) to String {
	final Optional = '?';
	final Important = '!';
}
