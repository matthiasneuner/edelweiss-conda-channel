"""Package test of edelweissfe: every expected extension imports, the GIL stays off, and two test cases pass."""

import importlib
import shutil
import subprocess
import sys

extensions = [
    "edelweissfe.elements.marmotelement.element",
    "edelweissfe.materials.marmot.marmothypoelastic",
    "edelweissfe.materials.marmot.marmotgradientenhancedhypoelastic",
    "edelweissfe.utils.elementresultcollector",
    "edelweissfe.numerics.csrgenerator",
    "edelweissfe.numerics.csrgeneratorv2",
    "edelweissfe.solvers.base.dirichlet",
    "edelweissfe.linsolve.amgcl.amgcl",
    "edelweissfe.linsolve.klu.klu",
]
if sys.platform != "darwin":  # PARDISO needs Intel MKL, which does not exist for macOS
    extensions.append("edelweissfe.linsolve.pardiso.pardiso")

for extension in extensions:
    importlib.import_module(extension)
    print("imported", extension)

# An extension not declared free-threading compatible silently re-enables the GIL process-wide.
assert not sys._is_gil_enabled(), "importing the extensions re-enabled the GIL"

runner = shutil.which("run_tests_edelweissfe")
assert runner, "run_tests_edelweissfe is not on PATH"
for directory in ["testfiles/edelweiss-only", "testfiles/marmot"]:
    subprocess.run([runner, directory], check=True)
