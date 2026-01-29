{ inputs, ... }:
{
  flake.modules.homeManager.qalculate = {
    programs.qalculate = {
      enable = true;
      definitions = {
        units = inputs.self + /configs/qalculate/units.xml;
        variables = inputs.self + /configs/qalculate/variables.xml;
      };
    };
  };
}
