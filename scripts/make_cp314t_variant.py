"""Derive a free-threaded (cp314t) variant config from a conda-forge feedstock's cp314 one.

conda-forge's vtk-feedstock ships no free-threaded Python build. Its .ci_support/<platform>_python3.14.____cp314.yaml
files already pin every dependency for Python 3.14, so the cp314t variant is that file with
  - python switched to the free-threaded ABI,
  - channel_sources/channel_targets dropped (rattler-build takes channels from the command line and refuses both),
  - every non-zipped key reduced to its first value, so that one variant (not a cartesian product) is built.
"""

import sys

import yaml

source, target = sys.argv[1], sys.argv[2]
with open(source) as f:
    variant = yaml.safe_load(f)

variant["python"] = [value.replace("_cp314", "_cp314t") for value in variant["python"]]
variant.pop("channel_sources", None)
variant.pop("channel_targets", None)

zipped = {key for group in variant.get("zip_keys", []) for key in group}
for key, values in variant.items():
    if key not in zipped and key != "zip_keys" and isinstance(values, list) and len(values) > 1:
        variant[key] = values[:1]

with open(target, "w") as f:
    yaml.safe_dump(variant, f, sort_keys=True)
