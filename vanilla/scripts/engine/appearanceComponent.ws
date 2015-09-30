/*
Copyright © CD Projekt RED 2015
*/

import class CAppearanceComponent extends CComponent
{
	import final function IncludeAppearanceTemplate(template : CEntityTemplate); 
	import final function ExcludeAppearanceTemplate(template : CEntityTemplate); 
	
	
	import final function ApplyAppearance( appearanceName : string );
}