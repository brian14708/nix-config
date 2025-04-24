_: {
  programs.qalculate = {
    enable = true;
    definitions = {
      units = ./units.xml;
      variables = ./variables.xml;
    };
  };
}
