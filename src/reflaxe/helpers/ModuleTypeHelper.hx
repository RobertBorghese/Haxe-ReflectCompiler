// =======================================================
// * CommonModuleTypeData
//
// Class for extracting common data shared between the
// ModuleType declaration classes.
// =======================================================

package reflaxe.helpers;

#if (macro || reflaxe_runtime)

import haxe.macro.Expr;
import haxe.macro.Type;

typedef CommonModuleTypeData = {
	pack: Array<String>,
	pos: Position,
	module: String,
	name: String
}

class ModuleTypeHelper {
	public static function getCommonData(type: ModuleType): CommonModuleTypeData {
		return switch(type) {
			case TClassDecl(c): c.get();
			case TEnumDecl(e): e.get();
			case TTypeDecl(t): t.get();
			case TAbstract(a): a.get();
		}
	}

	public static function getPos(type: ModuleType): Position {
		return getCommonData(type).pos;
	}

	public static function getModule(type: ModuleType): String {
		return getCommonData(type).module;
	}
}

#end
