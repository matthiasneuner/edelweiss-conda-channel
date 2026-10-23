/* Package test of hypre-openmp, built and run by tests/check_package.sh against the installed package: the public
 * headers compile, libHYPRE links and loads, a BoomerAMG solver is created, configured and destroyed, and the
 * library is the expected version with 32-bit integers. */
#include <stdio.h>

#include "HYPRE.h"
#include "HYPRE_parcsr_ls.h"
#include "HYPRE_utilities.h"

int main(void)
{
  HYPRE_Solver amg = NULL;
  HYPRE_Int major = 0, minor = 0, patch = 0;

  if (HYPRE_Initialize() != 0) {
    fprintf(stderr, "HYPRE_Initialize failed\n");
    return 1;
  }
  HYPRE_VersionNumber(&major, &minor, &patch, NULL);

  if (HYPRE_BoomerAMGCreate(&amg) != 0 || amg == NULL) {
    fprintf(stderr, "HYPRE_BoomerAMGCreate failed\n");
    return 1;
  }
  /* Settings of a displacement field block: 3 unknowns per node, one V-cycle per application. */
  HYPRE_BoomerAMGSetNumFunctions(amg, 3);
  HYPRE_BoomerAMGSetMaxIter(amg, 1);
  HYPRE_BoomerAMGSetTol(amg, 0.0);
  if (HYPRE_BoomerAMGDestroy(amg) != 0) {
    fprintf(stderr, "HYPRE_BoomerAMGDestroy failed\n");
    return 1;
  }

  printf("hypre %d.%d.%d: BoomerAMG created and destroyed; sizeof(HYPRE_Int) = %d, sizeof(HYPRE_BigInt) = %d\n",
         (int)major, (int)minor, (int)patch, (int)sizeof(HYPRE_Int), (int)sizeof(HYPRE_BigInt));
  if (sizeof(HYPRE_Int) != 4 || sizeof(HYPRE_BigInt) != 4) {
    fprintf(stderr, "expected 32-bit HYPRE_Int and HYPRE_BigInt\n");
    return 1;
  }

  HYPRE_Finalize();
  return 0;
}
