#include "IRMINSADMaterial.h"
#include "IRMINSADTauMaterial.h"

registerMooseObject("ProteusApp", IRMINSADTauMaterial);

template class IRMINSADTauMaterialTempl<IRMINSADMaterial>;
