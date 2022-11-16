// Navier-Stokes includes
#include "IRMINSADTauMaterial.h"
#include "IRMINSADMaterial.h"
// #include "INSAD3Eqn.h"

registerMooseObject("ProteusApp", IRMINSADTauMaterial);

// Make sure all symbols are generated
template class IRMINSADTauMaterialTempl<IRMINSADMaterial>;
