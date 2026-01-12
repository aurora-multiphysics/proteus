#include "Coaxial1PhaseBase.h"

FunctionName
Coaxial1PhaseBase::CreateFunctionFromValue(const std::string &suffix,
                                           const Real value) {
  auto func_params = _factory.getValidParams("ConstantFunction");
  func_params.set<Real>("value") = value;

  auto func_name = name() + "_" + suffix;
  getTHMProblem().addFunction("ConstantFunction", func_name, func_params);
  return func_name;
}

template <typename T>
inline void Coaxial1PhaseBase::CopyParamFromParamWithGlobal(
    const std::string dst_name, const std::string src_name,
    const std::string global_src_name, InputParameters &dst_params) {

  if (!isParamSetByUser(src_name) && !isParamSetByUser(global_src_name))
    mooseError("Either ", src_name, " or ", global_src_name, " must be set.");

  dst_params.set<T>(dst_name) = (isParamSetByUser(src_name))
                                    ? getParam<T>(src_name)
                                    : getParam<T>(global_src_name);
}