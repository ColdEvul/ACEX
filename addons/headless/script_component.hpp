#define COMPONENT headless
#include "\z\acex\addons\main\script_mod.hpp"

#ifdef DEBUG_ENABLED_HEADLESS
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_HEADLESS
    #define DEBUG_SETTINGS DEBUG_SETTINGS_HEADLESS
#endif

#include "\z\acex\addons\main\script_macros.hpp"

#define DELAY_DEFAULT 15
