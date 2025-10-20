#include "MooseMain.h"
#include "ProteusTestApp.h"

int main(int argc, char *argv[]) {
  Moose::main<ProteusTestApp>(argc, argv);

  return 0;
}
