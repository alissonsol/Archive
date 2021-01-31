//============================================================================
// Name        : ArgumentsHelper.h
// Description : Arguments helper class header
//============================================================================

#ifndef ARGUMENTSHELPER_H_
#define ARGUMENTSHELPER_H_

namespace CrossConsole {

class ArgumentsHelper {
public:
	static void ProcessArguments(int argc, const char *argv[]);

protected:
	virtual ~ArgumentsHelper();

private:
	ArgumentsHelper();
};

} /* namespace CrossConsole */

#endif /* ARGUMENTSHELPER_H_ */
