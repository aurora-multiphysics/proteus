#include "RBEConstraint.h"
#include "MooseMesh.h"

registerMooseObject("ProteusApp", RBEConstraint);

InputParameters
RBEConstraint::validParams()
{
  InputParameters params = NodalConstraint::validParams();
  params.addClassDescription(
    "Constrains secondary node to move as a linear combination of primary nodes. "
    "Implementation of a Rigid Body Element Constraint");
  params.addRequiredParam<BoundaryName>("primary_node_set",
    "The boundary ID associated with the primary nodes.");
  params.addRequiredParam<BoundaryName>("secondary_node_set",
    "The boundary ID associated with the secondary node.");
  params.addRequiredParam<Real>("penalty", "The penalty used for the boundary term.");
  params.addRequiredParam<Real>("primary_size", "The number of nodes in the primary node set.");
  return params;
}

RBEConstraint::RBEConstraint(const InputParameters & parameters)
  : NodalConstraint(parameters),
    _primary_node_set_id(getParam<BoundaryName>("primary_node_set")),
    _secondary_node_set_id(getParam<BoundaryName>("secondary_node_set")),
    _penalty(getParam<Real>("penalty")),
    _primary_size(getParam<Real>("primary_size"))
{
  const auto & lm_mesh = _mesh.getMesh();

  // Get secondary nodes
  std::vector<dof_id_type> nodelist =
    _mesh.getNodeList(_mesh.getBoundaryID(_secondary_node_set_id));
  std::vector<dof_id_type>::iterator in;

  for (in = nodelist.begin(); in != nodelist.end(); ++in)
  {
    const Node * const node = lm_mesh.query_node_ptr(*in);
    if (node && node->processor_id() == _subproblem.processor_id())
      _connected_nodes.push_back(*in);
  }

  // Get primary nodes
  std::vector<dof_id_type> primary_nodelist =
    _mesh.getNodeList(_mesh.getBoundaryID(_primary_node_set_id));

  const auto & node_to_elem_map = _mesh.nodeToElemMap();

  for (in = primary_nodelist.begin(); in != primary_nodelist.end(); ++in)
  {
    auto node_to_elem_pair = node_to_elem_map.find(*in);
    if (node_to_elem_pair == node_to_elem_map.end())
      continue;

    _primary_node_vector.push_back(*in);
    const std::vector<dof_id_type> & elems = node_to_elem_pair->second;
    for (const auto & elem_id : elems)
    {
      _subproblem.addGhostedElem(elem_id);
    }
  }
  _weights = std::vector<Real>(_primary_size, 1.0/_primary_size);
}

Real
RBEConstraint::computeQpResidual(Moose::ConstraintType type)
{
/*
Secondary residual is u_secondary - weights[1]*u_primary[1]
                      - weights[2]*u_primary[2] - u_primary[n]*weights[n]
However, computeQpResidual is calculated for only a combination of one
primary and one secondary node at a time.  To get around this, the residual is
split up such that the final secondary residual resembles the above expression.
*/
  unsigned int primary_size = _primary_size;

  switch (type)
  {
    case Moose::Primary:
      return (_u_primary[_j] * _weights[_j] - _u_secondary[_i] / primary_size)
             * _penalty;
    case Moose::Secondary:
      return (_u_secondary[_i] / primary_size - _u_primary[_j] * _weights[_j])
             * _penalty;
  }
  return 0;
}

Real
RBEConstraint::computeQpJacobian(Moose::ConstraintJacobianType type)
{
  unsigned int primary_size = _primary_size;

  switch (type)
  {
    case Moose::PrimaryPrimary:
      return _penalty * _weights[_j];
    case Moose::PrimarySecondary:
      return -_penalty / primary_size;
    case Moose::SecondarySecondary:
      return _penalty / primary_size;
    case Moose::SecondaryPrimary:
      return -_penalty * _weights[_j];
    default:
      mooseError("Unsupported type");
  }
  return 0;
}
