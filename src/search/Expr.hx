package search;

enum Expr {
	Binop(op:Binop, expr1:Expr, expr2:Expr);
	Unop(op:Unop, expr:Expr);
	Literal(value:Literal);
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
