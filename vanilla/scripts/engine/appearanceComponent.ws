import class CAppearanceComponent extends CComponent
{
	import final function IncludeAppearanceTemplate(template : CEntityTemplate); 
	import final function ExcludeAppearanceTemplate(template : CEntityTemplate); 
	
	// Selects a different appearance for the entity.
	import final function ApplyAppearance( appearanceName : string );
}