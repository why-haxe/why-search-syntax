package com.ty.search.internal;

enum Expr {
	Binop(op:Binop, expr1:Expr, expr2:Expr);
	Unop(op:Unop, expr:Expr);
	Literal(value:Literal);
}

interface Visitor {
	function binop(op:Binop, expr1:Expr, expr2:Expr):Void;
	function unop(op:Unop, expr:Expr):Void;
	function literal(value:Literal):Void;
}

enum abstract Unop(String) {
	final Not = '!';
	final Gt = '>';
	final Gte = '>=';
	final Lt = '<';
	final Lte = '<=';
}

enum abstract Binop(String) {
	final And = ',';
	final Or = '|';
	final Range = '..';
}

enum Literal {
	Text(value:String);
	Regex(pattern:String);
}
