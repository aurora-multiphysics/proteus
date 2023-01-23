#include "IRMINSADTauMaterial.h"
#include "IRMINSADMaterial.h"

registerMooseObject("ProteusApp", IRMINSADTauMaterial);

template class IRMINSADTauMaterialTempl<IRMINSADMaterial>;
