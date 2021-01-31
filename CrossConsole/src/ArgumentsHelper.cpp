//============================================================================
// Name        : ArgumentsHelper.cpp
// Description : Arguments helper class implementation
//============================================================================

#include <iostream>
#include "ArgumentsHelper.h"

using namespace std;

namespace CrossConsole {

void
ArgumentsHelper::ProcessArguments(int argc, const char *argv[])
{
	cout << "argc = " << argc << endl;

	for (int i = 0; i < argc; i++)
	{
		cout << "argv[" << i << "] = " << argv[i] << endl;
	}
}

ArgumentsHelper::~ArgumentsHelper() {
	// TODO Auto-generated destructor stub
}

ArgumentsHelper::ArgumentsHelper() {
	// TODO Auto-generated constructor stub
}

} /* namespace CrossConsole */
