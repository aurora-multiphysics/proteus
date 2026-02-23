#pragma once

#include "Component.h"
#include "InputParameters.h"

class Coaxial1PhaseBase : public Component {
public:
  Coaxial1PhaseBase(const InputParameters &params) : Component(params) {}

protected:
  // Create constant function based on scalar value
  FunctionName CreateFunctionFromValue(const std::string &suffix,
                                       const Real value);

  // Function that copies parameters depending on whether the
  // local parameter or global parameter is specified
  template <typename T>
  inline void CopyParamFromParamWithGlobal(const std::string dst_name,
                                           const std::string src_name,
                                           const std::string global_src_name,
                                           InputParameters &dst_params);
};
