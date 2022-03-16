package com.ty.search.internal;

#if java
@:interop.nativize(com.ty.search.Term.new)
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
