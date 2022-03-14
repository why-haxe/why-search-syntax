package;

@:asserts
class ParserTest {
	public function new() {}

	public function test() {
		search.Parser.parse('?date:2022-02-02');
		final result = search.Parser.parse('?date:>=2022-02-02');
		asserts.assert(result.length == 1);
		asserts.assert(result[0].modifiers.length == 1);
		asserts.assert(result[0].modifiers[0] == Optional);
		asserts.assert(result[0].field == 'date');
		asserts.assert(result[0].expr.match(Unop(Gte, Literal(Text('2022-02-02')))));

		final result = search.Parser.parse('?date:>=2022-02-02,<=2011-01-01');
		asserts.assert(result.length == 1);
		asserts.assert(result[0].modifiers.length == 1);
		asserts.assert(result[0].modifiers[0] == Optional);
		asserts.assert(result[0].field == 'date');
		asserts.assert(result[0].expr.match(Binop(And, Unop(Gte, Literal(Text('2022-02-02'))), Unop(Lte, Literal(Text('2011-01-01'))))));

		final result = search.Parser.parse('?date:>=2022-02-02|2011-01-01');
		asserts.assert(result.length == 1);
		asserts.assert(result[0].modifiers.length == 1);
		asserts.assert(result[0].modifiers[0] == Optional);
		asserts.assert(result[0].field == 'date');
		asserts.assert(result[0].expr.match(Binop(Or, Unop(Gte, Literal(Text('2022-02-02'))), Literal(Text('2011-01-01')))));

		final result = search.Parser.parse('or:foo|>bar and:<=foo,bar range:1.1..2.2 esc:foo\\|bar\\.baz regex:/abc\\/$/ number:1.2');
		asserts.assert(result.length == 6);
		asserts.assert(result[0].modifiers.length == 0);
		asserts.assert(result[0].field == 'or');
		asserts.assert(result[0].expr.match(Binop(Or, Literal(Text('foo')), Unop(Gt, Literal(Text('bar'))))));
		asserts.assert(result[1].modifiers.length == 0);
		asserts.assert(result[1].field == 'and');
		asserts.assert(result[1].expr.match(Binop(And, Unop(Lte, Literal(Text('foo'))), Literal(Text('bar')))));
		asserts.assert(result[2].modifiers.length == 0);
		asserts.assert(result[2].field == 'range');
		asserts.assert(result[2].expr.match(Binop(Range, Literal(Text('1.1')), Literal(Text('2.2')))));
		asserts.assert(result[3].modifiers.length == 0);
		asserts.assert(result[3].field == 'esc');
		asserts.assert(result[3].expr.match(Literal(Text('foo|bar.baz'))));
		asserts.assert(result[4].modifiers.length == 0);
		asserts.assert(result[4].field == 'regex');
		asserts.assert(result[4].expr.match(Literal(Regex('abc\\/$'))));
		asserts.assert(result[5].modifiers.length == 0);
		asserts.assert(result[5].field == 'number');
		asserts.assert(result[5].expr.match(Literal(Text('1.2'))));

		return asserts.done();
	}
	
	#if js
	@:exclude
	public function object() {
		final objects = search.Parser.parse('or:foo|>bar and:<=foo,bar esc:foo\\|bar\\,baz regex:/abc\\/$/')
			.map(term -> term.toObject());
			
		trace(haxe.Json.stringify(objects, '  '));
		
		return asserts.done();
	}
	#end
}
