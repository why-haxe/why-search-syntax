package;

import js.Browser.*;
import js.html.*;
import com.ty.search.Parser;

class Playground {
	static function main() {
		final input:InputElement = cast document.getElementById('input');
		final output:PreElement = cast document.getElementById('output');
		
		input.oninput = () -> {
			output.innerHTML = switch Parser.tryParse(input.value) {
				case Success(terms):
					haxe.Json.stringify(terms.map(term -> term.toObject()), '  ');
				case Failure(e):
					'';
			}
		};
	}
}