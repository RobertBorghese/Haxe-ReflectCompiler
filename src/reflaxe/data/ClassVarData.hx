package reflaxe.data;

#if (macro || reflaxe_runtime)

import haxe.macro.Expr;
import haxe.macro.Type;

using reflaxe.helpers.ClassFieldHelper;
using reflaxe.helpers.ClassTypeHelper;
using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.PositionHelper;
using reflaxe.helpers.TypedExprHelper;

class ClassVarData {
	public var classType(default, null): ClassType;
	public var field(default, null): ClassField;

	public var isStatic(default, null): Bool;
	public var read(default, null): VarAccess;
	public var write(default, null): VarAccess;

	public var getter(default, null): Null<ClassField>;
	public var setter(default, null): Null<ClassField>;

	public function new(classType: ClassType, field: ClassField, isStatic: Bool, read: VarAccess, write: VarAccess) {
		this.classType = classType;
		this.field = field;

		this.isStatic = isStatic;
		this.read = read;
		this.write = write;

		findGetterAndSetter();
	}

	function findGetterAndSetter() {
		function find(access: VarAccess, prefix: String, isStatic: Bool): Null<ClassField> {
			switch(access) {
				case AccCall: {
					final getterName = prefix + field.getHaxeName();
					for(f in (isStatic ? classType.statics : classType.fields).get()) {
						if(f.getHaxeName() == getterName) {
							return f;
						}
					}
				}
				case _:
			}
			return null;
		}
		getter = find(read, "get_", isStatic);
		setter = find(write, "set_", isStatic);
	}

	public function hasDefaultValue(): Bool {
		return field.hasDefaultValue();
	}

	public function getDefaultUntypedExpr(): Null<Expr> {
		final args = field.meta.extractExpressionsFromFirstMeta(":value");
		if(args != null && args.length == 1) {
			return args[0];
		}
		return null;
	}

	/**
		Haxe removes the default `TypedExpr` from the class field in
		most cases. However, this function uses `ClassTypeHelper.extractPreconstructorFieldAssignments`
		to help locate and track down the default expression from the
		constructor.
	**/
	public function findDefaultExpr(): Null<TypedExpr> {
		if(hasDefaultValue()) {
			final data = classType.extractPreconstructorFieldAssignments();
			if(data != null) {
				for(assignField => expr in data.assignments) {
					if(field.name == assignField.name) {
						return expr;
					}
				}
			}
		}
		return null;
	}
}

#end
