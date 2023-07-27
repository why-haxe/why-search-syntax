package why.searchsyntax;

import tink.parse.Char;
import tink.parse.Char.*;
import tink.parse.StringSlice;
import tink.core.Error;
import why.searchsyntax.internal.Term;
import why.searchsyntax.internal.Expr;

using StringTools;
using tink.CoreApi;
typedef Result = 
	#if (interop && java)
	java.util.List<why.searchsyntax.Term>;
	#else
	Array<why.searchsyntax.Term>;
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

#if (js) @:expose("Parser") #end
class Parser extends tink.parse.ParserBase<Pos, Error> {
	static final MOD:Char = ['?'.code, '!'.code];
	static final FIELD_SEP:Char = ':';
	static final FIELD = !FIELD_SEP;
	static final TERM_START = MOD || FIELD;
	static final TERM_SEP:Char = ' ';
	
	static final DOT:Char = '.';
	static final OPEN_BRACE:Char = '{';
	static final CLOSE_BRACE:Char = '}';
	
	static final TEMPLATE_QUOTE:Char = '`';
	static final UNOP_START:Char = ['!'.code, '>'.code, '<'.code];
	static final BINOP_START:Char = ['.'.code, '|'.code, ','.code];
	static final ESCAPE:Char = '\\';
	static final LITERAL_END = BINOP_START || TERM_SEP || UNOP_START || CLOSE_BRACE;
	static final LITERAL_ESCAPABLE = LITERAL_END || ESCAPE;
	static final REGEX_END:Char = '/';
	
	
	
	static final REGEX = !REGEX_END;
	static final LITERAL = !LITERAL_ESCAPABLE;
	
	
	#if interop @:keep #end
	public static function parse(source:String #if !interop , ?pos #end) {
		final result = doParse(source #if !interop, pos #end).sure();
		#if interop
		return interop.Converter.nativize(result);
		#else
		return result;
		#end
	}
	
	#if interop @:keep #end
	public static function tryParse(source:String #if !interop , ?pos #end) {
		final result = doParse(source #if !interop, pos #end);
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
		while(!is(TERM_SEP) && !is(CLOSE_BRACE) && !eof()) {
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
			else if(allow('"'))
				QuotedText(Double, parseQuotedText('"'));
			else if(allow('`')) {
				Template(parseTemplate());
			}
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
	
	function parseQuotedText(quote:String):String {
		var v = '';
		
		while(true) {
			v += upto(quote).sure().toString();
			
			if(source.fastGet(pos-2) == '\\'.code)
				v += quote;
			else
				break;
		}
		
		return v.replace('\\$quote', quote);
	}
	
	function parseTemplate():Array<TemplatePart> {
		final parts:Array<TemplatePart> = [];
		
		var v = '';
		function pushText() {
			parts.push(Text(v));
			v = '';
		}
		while(true) {
			v += readWhile(!(TEMPLATE_QUOTE || OPEN_BRACE)).toString();
			if(source.fastGet(pos) == '{'.code) {
				expect('{');
				pushText();
				parts.push(Syntax(parseAll()));
				expect('}');
			} else if(source.fastGet(pos-1) == '\\'.code) {
				expect('`');
				v = v.substring(0, v.length - 1) + '`';
			} else {
				pushText();
				expect('`');
				break;
			}
		}
		
		return parts;
	}
	
	function parseSyntax(openBraces:Int):String {
		var v = '';
		
		final OPEN_BRACE:Char = '{';
		final CLOSE_BRACE:Char = '}';
		final QUOTE:Char = '`';
		
		while(true) {
			v += readWhile(!(OPEN_BRACE || CLOSE_BRACE || QUOTE)).toString();
			
			switch source.fastGet(pos) {
				case '`'.code:
					expect('`');
					if(source.fastGet(pos - 2) == '\\'.code)
						v = '\\`'
					else
						v += '`' + parseTemplate() + '`';
				case '}'.code:
					expect('}');
					if(source.fastGet(pos - 2) == '\\'.code)
						v = '}'
					else 
						break;
			}
		}
		
		return v;
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
	
	#if (js && !genes)
	static function __init__() {
		Macro.exportEnum(Expr);
		Macro.exportEnum(Literal);
		Macro.exportEnum(TemplatePart);
	}
		
	#end
	
}
