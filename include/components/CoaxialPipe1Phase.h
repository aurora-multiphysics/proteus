#include <Component1D.h>
#include <FlowChannel1Phase.h>
#include <InputParameters.h>

class CoaxialPipe1Phase : public Component
{
public:
  static InputParameters validParams();

  CoaxialPipe1Phase(const InputParameters & params);

protected:
  void AddInnerPipe(const InputParameters & params);
  void AddOuterAnnulus(const InputParameters & params);
  void AddSolidTube(const InputParameters & params);
  void AddSolidShell(const InputParameters & params);
  void AddHeatTransferConnection(const InputParameters & params,
                                 const std::string & flow_channel,
                                 const std::string & hs,
                                 const std::string & hs_side,
                                 const Real radius);
  FunctionName CreateFunctionFromValue(const std::string & suffix, const Real value);
};