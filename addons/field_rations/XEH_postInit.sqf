#include "script_component.hpp"

if !(hasInterface) exitWith {};

["ace_settingsInitialized", {
    TRACE_3("Settings Initialized",GVAR(enabled),GVAR(timeWithoutWater),GVAR(timeWithoutFood));

    if !(GVAR(enabled)) exitWith {};

    // Add Advanced Fatigue duty factor
    if (missionNamespace getVariable [QACEGVAR(advanced_fatigue,enabled), false]) then {
        LOG("Adding Duty Factor");
        [QUOTE(ADDON), {
            (linearConversion [75, 0, _this getVariable [QGVAR(thirst), 100], 1, 2, true]) * (linearConversion [60, 0, _this getVariable [QGVAR(hunger), 100], 1, 1.5, true])
        }] call ACEFUNC(advanced_fatigue,addDutyFactor);
    };

    // HUD variables
    GVAR(hudInteractionHover) = false;
    GVAR(hudIsShowing) = false;

    // Add refill water actions to water sources from config
    private _filter = QUOTE(getNumber (_x >> 'scope') == 2 && {getNumber (_x >> QQGVAR(refillSource)) > 0});
    private _waterSources = _filter configClasses (configFile >> "CfgVehicles");

    {
        private _classname = configName _x;
        LOG_1("Adding refill action to %1",_classname);

        private _action = [QGVAR(refill), localize LSTRING(Refill), QPATHTOF(ui\icon_water_tap.paa), {true}, {true}, LINKFUNC(getRefillChildren)] call ACEFUNC(interact_menu,createAction);
        [_classname, 0, ["ACE_MainActions"], _action] call ACEFUNC(interact_menu,addActionToClass);
    } forEach _waterSources;

    // Start update loop with 10 second interval and 60 second MP sync
    [LINKFUNC(update), CBA_missionTime + MP_SYNC_INTERVAL, 10] call CBA_fnc_waitAndExecute;

    // Add event to hide HUD if it was shown through interact menu hover
    ["ace_interactMenuClosed", {
        if (GVAR(hudInteractionHover)) then {
            GVAR(hudInteractionHover) = false;
            [3] call FUNC(showHud);
        };
    }] call CBA_fnc_addEventHandler;

    // Add respawn eventhandler to reset necessary variables, done through script so only added if field rations is enabled
    ["CAManBase", "respawn", LINKFUNC(handleRespawn)] call CBA_fnc_addClassEventHandler;

    #ifdef DEBUG_MODE_FULL
        ["ACE_player thirst", {ACE_player getVariable [QGVAR(thirst), 100]}, [true, 0, 100]] call ACEFUNC(common,watchVariable);
        ["ACE_player hunger", {ACE_player getVariable [QGVAR(hunger), 100]}, [true, 0, 100]] call ACEFUNC(common,watchVariable);
    #endif
}] call CBA_fnc_addEventHandler;
