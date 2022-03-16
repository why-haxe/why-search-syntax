package search;

import tink.parse.Char;
import tink.parse.Char.*;
import tink.parse.StringSlice;
import tink.core.Error;
import search.internal.Term;
import search.internal.Expr;

using StringTools;
using tink.CoreApi;
typedef Result = 
	#if (interop && java)
	java.util.List<search.Term>;
	#else
	Array<search.Term>;
	#end

private class RuntimeReporter implements tink.parse.Reporter.ReporterObject<Pos, Error> {

	var pos:Pos;
  
	public function new(pos)
	  this.pos = pos;
  
	public function makeError(message:String, pos:Pos):Error
	  return new Error(UnprocessableEntity, message, pos);
  
	public function makePos(from:Int, to:Int):Pos
	  return pos;
  
  }

class Parser extends tink.parse.ParserBase<Pos, Error> {
	static final MOD:Char = ['?'.code, '!'.code];
	static final FIELD_SEP:Char = ':';
	static final FIELD = !FIELD_SEP;
	static final TERM_START = MOD || FIELD;
	static final TERM_SEP:Char = ' ';
	
	static final DOT:Char = '.';
	
	static final UNOP_START:Char = ['!'.code, '>'.code, '<'.code];
	static final BINOP_START:Char = ['.'.code, '|'.code, ','.code];
	static final ESCAPE:Char = '\\';
	static final LITERAL_END = BINOP_START || TERM_SEP;
	static final LITERAL_ESCAPABLE = LITERAL_END || ESCAPE;
	static final REGEX_END:Char = '/';
	
	
	static final REGEX = !REGEX_END;
	static final LITERAL = !LITERAL_ESCAPABLE;
	
	
	public static function parse(source, ?pos) {
		final result = doParse(source, pos).sure();
		#if interop
		return interop.Converter.nativize(result);
		#else
		return result;
		#end
	}
	
	public static function tryParse(source, ?pos) {
		final result = doParse(source, pos);
		#if interop
		return interop.Converter.nativize(result);
		#else
		return result;
		#end
	}
	
	static function doParse(source, ?pos):Outcome<Array<Term>, Error> {
		final offset = 0;
		final reporter = new RuntimeReporter(pos);
		final parser = new Parser(source, reporter, offset);
		final result = parser.parseAll();
		return 
			if(parser.pos < parser.source.length) {
				parser.die('Unexpected end of input');
			} else {
				Success(result);
			}
	}
	
	function parseAll():Array<Term> {
		final terms = [];
		
		do terms.push(parseTerm())
		while (allow(' '));
		
		return terms;
	}
	
	function parseTerm():Term {
		final modifiers = parseModifiers();
		final field = parseField();
		expect(':');
		final expr = parseExpr();
		
		return {
			modifiers: modifiers,
			field: field,
			expr: expr,
		}
	}
	
	function parseModifiers():Array<Modifier> {
		final mods = [];
		
		inline function add(mod:Modifier) {
			if(mods.contains(mod))
				die('Duplicate modifier: $mod');
			else
				mods.push(mod);
		}
		
		while(is(MOD)) {
			for(mod in [Optional, Important])
			if(allow((mod:String))) {
				add(mod);
				break;
			}
		}
		
		return mods;
	}
	
	function parseField():String {
		return readWhile(FIELD);
	}
	
	function parseExpr():Expr {
		var e = null;
		while(!is(TERM_SEP) && !eof()) {
			e = parseExprPart(e);
		}
		return e;
	}
	
	function eof():Bool {
		return pos == max;
	}
	
	function parseExprPart(left:Expr):Expr {
		return 
			if(is(UNOP_START)) {
				Unop(parseUnop(), Literal(parseLiteral())); // unop must be followed by literal
			} else if(is(BINOP_START)) {
				if(left == null) die('Missing left operand');
				Binop(parseBinop(), left, parseExpr());
			} else {
				Literal(parseLiteral());
			}
	}
	
	function parseUnop():Unop {
		return
			if(allow('!')) {
				Not;
			} else if(allow('>')) {
				allow('=') ? Gte : Gt;
			} else if(allow('<')) {
				allow('=') ? Lte : Lt;
			} else {
				die('unreachble');
			}
	}
	
	function parseBinop():Binop {
		return
			if(allow('.'))
				expect('.') + Range;
			else if(allow(','))
				And;
			else if(allow('|'))
				Or;
			else
				die('unreachble');
	}

	
	function parseLiteral():Literal {
		return
			if(allow('/'))
				Regex(parseRegex());
			else
				Text(parseText());
	}
	
	function parseRegex() {
		var pattern = '';
		while(true) {
			pattern += readWhile(REGEX).toString();
			
			if(source.fastGet(pos - 1) == '\\'.code)
				pattern += String.fromCharCode(source.fastGet(pos++));
			else {
				expect('/');
				break;
			}
		}
		return pattern;
	}
	
	function parseText():String {
		var v = '';
		while(true) {
			v += readWhile(LITERAL).toString();
			
			if(allow('\\')) {
				if(is(LITERAL_ESCAPABLE))
					v += String.fromCharCode(source.fastGet(pos++));
				else
					die('Invalid escape sequence "\\${String.fromCharCode(source.fastGet(pos))}"');
			} else if(allow('.')) {
				if(current() == '.'.code) {
					pos--; // wind back and break because it is a range op
					break;
				}
				v += '.';
			} else break;
		}
		
		return v
			.replace('\\.', '.')
			.replace('\\|', '|')
			.replace('\\,', ',')
			.replace('\\\\', '\\');
	}
	
	
}