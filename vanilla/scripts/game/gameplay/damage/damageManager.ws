/*
Copyright © CD Projekt RED 2015
*/






class W3DamageManager
{
	public function ProcessAction(act : W3DamageAction)
	{
		var proc : W3DamageManagerProcessor;
		
		
		proc = new W3DamageManagerProcessor in this;
		proc.ProcessAction(act);
		delete proc;
	}
}
