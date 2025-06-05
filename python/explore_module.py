# explore_module.py
import importlib
import types
import argparse

def score(name, obj):
    score = 0
    if isinstance(obj, (types.FunctionType, types.BuiltinFunctionType)):
        score += 1
    if len(name) <= 6:
        score += 1
    if any(verb in name.lower() for verb in ["get", "set", "load", "save", "open", "calc", "compute"]):
        score += 2
    return score

def explore_module(module_name, use_scoring=False):
    try:
        module = importlib.import_module(module_name)
    except ImportError:
        print(f"❌ Impossible d'importer le module '{module_name}'")
        return

    public_items = [name for name in dir(module) if not name.startswith("_")]

    groups = {
        "functions": [],
        "classes": [],
        "others": [],
    }

    for name in public_items:
        obj = getattr(module, name)
        if isinstance(obj, (types.FunctionType, types.BuiltinFunctionType)):
            groups["functions"].append(name)
        elif isinstance(obj, type):
            groups["classes"].append(name)
        else:
            groups["others"].append(name)

    print(f"\n📦 Module : {module_name}\n")

    print("🔧 Fonctions :")
    if use_scoring:
        sorted_funcs = sorted(
            groups["functions"],
            key=lambda name: score(name, getattr(module, name)),
            reverse=True
        )
    else:
        sorted_funcs = sorted(groups["functions"])

    for name in sorted_funcs:
        print(f"  - {name}")

    print("\n🏷️  Classes :")
    for name in sorted(groups["classes"]):
        print(f"  - {name}")

    print("\n📦 Autres objets :")
    for name in sorted(groups["others"]):
        print(f"  - {name}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Explorer un module Python")
    parser.add_argument("module", help="Nom du module à explorer")
    parser.add_argument("-s", "--scored", action="store_true", help="Trier les fonctions par pertinence estimée")

    args = parser.parse_args()
    explore_module(args.module, use_scoring=args.scored)
