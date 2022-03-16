package search;

#if java
@:interop.nativize(search.interop.Term.new)
#end
typedef Term = {
	public final modifiers:Array<Modifier>;
	public final field:String;
	public final expr:Expr;
}

enum abstract Modifier(String) to String {
	final Optional = '?';
	final Important = '!';
}
