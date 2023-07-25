package why.searchsyntax.internal;
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

enum abstract Quote(String) {
	final Double = '"';
	final Backtick = '`';
}

enum Literal {
	QuotedText(quote:Quote, value:String);
	Text(value:String);
	Regex(pattern:String);
	Template(parts:Array<TemplatePart>);
}

enum TemplatePart {
	Text(value:String);
	Syntax(terms:Array<Term>);
}