package why.searchsyntax;

import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.Tools;

class Macro {
	public static macro function exportEnum(e:Expr) {
		return switch Context.follow(Context.getType(e.toString())) {
			case TEnum(_.get() => enm, _):
				final code = '$$hx_exports["${enm.name}"] = ${enm.pack.concat([enm.name]).join('_')}';
				macro js.Syntax.code($v{code});
			case _:
				throw 'Unsupported type for exportEnum';
		}
	}
}