package;

import why.searchsyntax.Parser;

@:asserts
class ParserTest {
	public function new() {}
	
	#if interop
	public function object() {
		final objects = Parser.parse('or:foo|>bar and:<=foo,bar esc:foo\\|bar\\,baz regex:/abc\\/$/');
		$type(objects);
		for(o in objects) {
			#if java
			final c = (cast o:java.lang.Object).getClass();
			final f = c.getDeclaredFields();
			for(f in f) trace(f);
			#end
			trace(o);
		}
		trace(haxe.Json.stringify(objects, '  '));
		
		return asserts.done();
	}
	
	#else

	public function basic() {
		Parser.parse('?date:2022-02-02');
		final result = Parser.parse('?date:>=2022-02-02');
		asserts.assert(result.length == 1);
		asserts.assert(result[0].modifiers.length == 1);
		asserts.assert(result[0].modifiers[0] == Optional);
		asserts.assert(result[0].field == 'date');
		asserts.assert(result[0].expr.match(Unop(Gte, Literal(Text('2022-02-02')))));

		final result = Parser.parse('?date:>=2022-02-02,<=2011-01-01');
		asserts.assert(result.length == 1);
		asserts.assert(result[0].modifiers.length == 1);
		asserts.assert(result[0].modifiers[0] == Optional);
		asserts.assert(result[0].field == 'date');
		asserts.assert(result[0].expr.match(Binop(And, Unop(Gte, Literal(Text('2022-02-02'))), Unop(Lte, Literal(Text('2011-01-01'))))));

		final result = Parser.parse('?date:>=2022-02-02|2011-01-01');
		asserts.assert(result.length == 1);
		asserts.assert(result[0].modifiers.length == 1);
		asserts.assert(result[0].modifiers[0] == Optional);
		asserts.assert(result[0].field == 'date');
		asserts.assert(result[0].expr.match(Binop(Or, Unop(Gte, Literal(Text('2022-02-02'))), Literal(Text('2011-01-01')))));
		
		return asserts.done();
	}
	
	public function range() {
		final result = Parser.parse('range:1.1..2.2');
		asserts.assert(result.length == 1);
		asserts.assert(result[0].modifiers.length == 0);
		asserts.assert(result[0].field == 'range');
		asserts.assert(result[0].expr.match(Binop(Range, Literal(Text('1.1')), Literal(Text('2.2')))));
		
		return asserts.done();
	}
	
	public function quoted() {
		final result = Parser.parse('quoted:"foo,bar" escaped:"foo\\"bar"');
		asserts.assert(result.length == 2);
		asserts.assert(result[0].modifiers.length == 0);
		asserts.assert(result[0].field == 'quoted');
		asserts.assert(result[0].expr.match(Literal(QuotedText(Double, 'foo,bar'))));
		asserts.assert(result[1].modifiers.length == 0);
		asserts.assert(result[1].field == 'escaped');
		asserts.assert(result[1].expr.match(Literal(QuotedText(Double, 'foo"bar'))));
		return asserts.done();
	}

	public function complex() {
		final result = Parser.parse('or:foo|>bar and:<=foo,bar range:1.1..2.2 esc:foo\\|bar\\.baz\\!baz regex:/abc\\/$/ number:1.2');
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
		asserts.assert(result[3].expr.match(Literal(Text('foo|bar.baz!baz'))));
		asserts.assert(result[4].modifiers.length == 0);
		asserts.assert(result[4].field == 'regex');
		asserts.assert(result[4].expr.match(Literal(Regex('abc\\/$'))));
		asserts.assert(result[5].modifiers.length == 0);
		asserts.assert(result[5].field == 'number');
		asserts.assert(result[5].expr.match(Literal(Text('1.2'))));

		return asserts.done();
	}

	public function unicode() {
		final result = Parser.parse('name:名字');
		asserts.assert(result.length == 1);
		asserts.assert(result[0].modifiers.length == 0);
		asserts.assert(result[0].field == 'name');
		asserts.assert(result[0].expr.match(Literal(Text('名字'))));
		
		final result = Parser.parse('名:字');
		asserts.assert(result.length == 1);
		asserts.assert(result[0].modifiers.length == 0);
		asserts.assert(result[0].field == '名');
		asserts.assert(result[0].expr.match(Literal(Text('字'))));

		final result = Parser.parse('name:"이름"');
		asserts.assert(result.length == 1);
		asserts.assert(result[0].modifiers.length == 0);
		asserts.assert(result[0].field == 'name');
		asserts.assert(result[0].expr.match(Literal(QuotedText(Double, '이름'))));

		final result = Parser.parse('name:и\\ м\\ я');
		asserts.assert(result.length == 1);
		asserts.assert(result[0].modifiers.length == 0);
		asserts.assert(result[0].field == 'name');
		asserts.assert(result[0].expr.match(Literal(Text('и м я'))));

		final result = Parser.parse('name:"😍 😀"');
		asserts.assert(result.length == 1);
		asserts.assert(result[0].modifiers.length == 0);
		asserts.assert(result[0].field == 'name');
		asserts.assert(result[0].expr.getName() == "Literal");
		#if jvm
		// see https://github.com/HaxeFoundation/haxe/issues/10720
		asserts.assert((result[0].expr.getParameters()[0]:EnumValue).getName() == "QuotedText");
		asserts.assert((result[0].expr.getParameters()[0]:EnumValue).getParameters()[0] == '"');
		asserts.assert((result[0].expr.getParameters()[0]:EnumValue).getParameters()[1] == '😍 😀');
		#else
		asserts.assert(result[0].expr.match(Literal(QuotedText(Double, '😍 😀'))));
		#end
					
		return asserts.done();
	}
	#end
}
