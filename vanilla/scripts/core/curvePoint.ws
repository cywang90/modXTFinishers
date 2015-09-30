﻿/*
Copyright © CD Projekt RED 2015
*/

enum EInterpCurveMode
{
	
	CIM_Constant,
	
	CIM_Linear,
	
	CIM_CurveAuto,
	
	CIM_CurveBreak,
};


class InterpCurvePoint
{
	var inVal : float;
	
	var interpMode : EInterpCurveMode;
	
	function InterpCurvePoint(){}
	
	function IsCurveKey() : bool
	{	
		return( interpMode == CIM_CurveAuto
				|| interpMode == CIM_CurveBreak );
	}
}


class InterpCurvePointF extends InterpCurvePoint
{
	var outVal : float;
	
	var arriveTangent : float;
	var leaveTangent : float;	
}


class InterpCurvePointV extends InterpCurvePoint
{
	var outVal : Vector;
	
	var arriveTangent : Vector;
	var leaveTangent : Vector;
}