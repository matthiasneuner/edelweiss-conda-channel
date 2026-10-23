# Package test of hypre-openmp (run by rattler-build in the test environment, with the C compiler activated).
set -euo pipefail

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

# (c) The build configuration hypre recorded: sequential (no MPI), OpenMP, 32-bit HYPRE_Int and HYPRE_BigInt.
config="$PREFIX/include/HYPRE_config.h"
for macro in HYPRE_SEQUENTIAL HYPRE_USING_OPENMP; do
  grep -Eq "^#define $macro( |$)" "$config" || fail "$config does not define $macro"
done
for macro in HYPRE_BIGINT HYPRE_MIXEDINT HYPRE_HAVE_MPI; do
  if grep -Eq "^#define $macro( |$)" "$config"; then fail "$config defines $macro"; fi
done
echo "HYPRE_config.h: HYPRE_SEQUENTIAL, HYPRE_USING_OPENMP; no HYPRE_BIGINT, HYPRE_MIXEDINT, HYPRE_HAVE_MPI"

# (b) libHYPRE is threaded with the OpenMP runtime of the stack. Linux: it needs libgomp.so.1 and calls its GOMP_*
# entry points (an OpenMP build that silently fell back to serial would have neither). macOS: it links libomp.
case "$(uname)" in
  Linux)
    lib="$PREFIX/lib/libHYPRE.so"
    "${READELF:-readelf}" -d "$lib" | grep -Eq 'NEEDED.*\[libgomp\.so\.1\]' || fail "$lib does not link libgomp.so.1"
    gomp=$("${NM:-nm}" -D --undefined-only "$lib" | grep -c ' GOMP_' || true)
    [ "$gomp" -gt 0 ] || fail "$lib calls no GOMP_* function"
    echo "libHYPRE.so: NEEDED libgomp.so.1, $gomp GOMP_* symbols"
    ;;
  Darwin)
    lib="$PREFIX/lib/libHYPRE.dylib"
    "${OTOOL:-otool}" -L "$lib" | grep -q 'libomp\.dylib' || fail "$lib does not link libomp.dylib"
    echo "libHYPRE.dylib: links libomp.dylib"
    ;;
  *)
    fail "unsupported platform $(uname)"
    ;;
esac

# (d) A consumer compiles against the public headers (which include omp.h), links libHYPRE and runs.
"${CC:-cc}" ${CFLAGS:-} ${LDFLAGS:-} -I"$PREFIX/include" tests/boomeramg_create_destroy.c -o boomeramg_create_destroy \
  -L"$PREFIX/lib" -Wl,-rpath,"$PREFIX/lib" -lHYPRE
OMP_NUM_THREADS=2 ./boomeramg_create_destroy
