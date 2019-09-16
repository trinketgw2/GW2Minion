local tbl = 
{
	class = "SubTree",
	nodes = 
	{
		
		{
			class = "Action",
			nodes = 
			{
			},
			settings = 
			{
				xposoffset = 0,
			},
			variables = 
			{
				filename = "tm_ChangeMesh",
				finishcode = "",
				info = "",
				monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
				runcode = "if(context.meshname and ml_mesh_mgr.currentfilename ~= context.meshname) then\n\t\tPlayer:StopMovement()\n\t\tml_mesh_mgr:LoadMesh(context.meshname)\n\t\tml_global_information.Wait(1000)\n\t\tself:success()\n\t\treturn\nend\n\nself:fail()",
				startcode = "",
			},
		},
	},
	settings = 
	{
	},
	variables = 
	{
		filename = "tm_ChangeMesh.st",
		finishcode = "",
		info = "",
		menucode = "",
		monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Filename: '..self.variables.filename) GUI:Text('Filepath: '..self.filepath)",
		runcode = "context.meshname = self.settings.mesh",
		startcode = "",
		subtreeuicode = "if(table.valid(ml_mesh_mgr.data.meshfiles)) then\n\t\tlocal currentfileidx = 1\n\t\tlocal changed = false\n\n\t\tfor i,map in pairs(ml_mesh_mgr.data.meshfiles) do\n\t\t\t\tif(self.settings.mesh == map) then\n\t\t\t\t\t\tcurrentfileidx = i\n\t\t\t\tend\n\t\tend\n\n\t\tcurrentfileidx, changed = GUI:Combo(\"##tmchangemesh\",currentfileidx,ml_mesh_mgr.data.meshfiles)\n\t\tif(changed) then\n\t\t\t\tlocal name = ml_mesh_mgr.GetFileName(ml_mesh_mgr.data.meshfiles[currentfileidx])\n\t\t\t\tif(string.valid(name)) then\n\t\t\t\t\t\tself.settings.mesh = name\n\t\t\t\tend\n\t\tend\nelse\n\t\tGUI:Text(\"No mesh files found\")\nend",
	},
}



return tbl