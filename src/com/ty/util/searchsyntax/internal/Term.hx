package com.ty.util.searchsyntax.internal;

#if java
@:interop.nativize(com.ty.util.searchsyntax.Term.new)
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
