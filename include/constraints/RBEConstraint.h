#pragma once
#include "NodalConstraint.h"

class RBEConstraint : public NodalConstraint
{
public:
  static InputParameters validParams();
  RBEConstraint(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual(Moose::ConstraintType type) override;
  virtual Real computeQpJacobian(Moose::ConstraintJacobianType type) override;
  std::string _primary_node_set_id;
  std::string _secondary_node_set_id;
  Real _penalty;
  Real _primary_size;
};
