//============================================================================
// Name        : main.cpp
// Description : Application entry point
//============================================================================

#include <iostream>
#include "ArgumentsHelper.h"

using namespace std;
using namespace CrossConsole;

int main(int argc, const char * argv[])
{
	CrossConsole::ArgumentsHelper::ProcessArguments(argc, argv);
    
	return 0;
}
