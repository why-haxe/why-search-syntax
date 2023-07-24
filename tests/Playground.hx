package;

import js.Browser.*;
import js.html.*;
import why.searchsyntax.Parser;

class Playground {
	static function main() {
		final input:InputElement = cast document.getElementById('input');
		final output:PreElement = cast document.getElementById('output');
		
		input.oninput = () -> {
			output.innerHTML = haxe.Json.stringify(Parser.tryParse(input.value), '  ');
		};
	}
}