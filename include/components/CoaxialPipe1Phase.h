#pragma once

#include <Coaxial1PhaseBase.h>
#include <FlowChannel1Phase.h>
#include <InputParameters.h>

class CoaxialPipe1Phase : public Coaxial1PhaseBase {
public:
  static InputParameters validParams();

  CoaxialPipe1Phase(const InputParameters &params);

protected:
  // Add inner pipe to coaxial pipe
  void AddInnerPipe(const InputParameters &params);

  // Add outer annulus to coaxial pipe
  void AddOuterAnnulus(const InputParameters &params);

  // Add solid tube between pipe and annulus
  void AddSolidTube(const InputParameters &params);

  // Add solid shell around annulus
  void AddSolidShell(const InputParameters &params);

  // Add solid-fluid connection based on component names
  void AddHeatTransferConnection(const std::string &flow_channel,
                                 const std::string &hs,
                                 const std::string &hs_side, const Real radius);
};