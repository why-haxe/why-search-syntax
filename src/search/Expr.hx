package search;

@:using(search.Expr.ExprTools)
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

@:using(search.Expr.LiteralTools)
enum Literal {
	Text(value:String);
	Regex(pattern:String);
}

class ExprTools {
	#if js
	public static function toObject(e:Expr):Dynamic {
		return switch e {
			case Binop(op, expr1, expr2):
				{
					"$type": 'Binop',
					op: op,
					expr1: expr1.toObject(),
					expr2: expr2.toObject()
				}
			case Unop(op, expr):
				{
					"$type": 'Unop',
					op: op,
					expr: expr.toObject()
				}
			case Literal(value):
				{
					"$type": 'Literal',
					value: value.toObject()
				}
		}
	}
	#end
}

class LiteralTools {
	#if js
	public static function toObject(v:Literal):Dynamic {
		return switch v {
			case Regex(pattern):
				{
					"$type": 'Regex',
					pattern: pattern,
				}
			case Text(value):
				{
					"$type": 'Text',
					value: value,
				}
		}
	}
	#end
}
