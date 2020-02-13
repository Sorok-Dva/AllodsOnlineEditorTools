
def op():
	clr.AddReferenceByPartialName("System")
	clr.AddReferenceByPartialName("LoggerCs", "libdb_cs", "EditorTools")

	import MapEditor
	import System
	import Logging
	import Db as libdb
	import MapInfo

	database = libdb.IDatabase.GetMainDatabase();
	tmpl = MapInfo.MapObjectType( MapInfo.MapObjectType.Object, "troll/trollStatic.xdb" );

	for i in xrange(1000):
		x = System.Math.Sin( i * 5.43254345 ) * 200.0 + 512.0
		y = System.Math.Sin( i * 7.43254345 ) * 200.0 + 512.0
		(z, pos) = context.EditorScene.GetTerrainHeight(context.EditorSceneViewID, MapInfo.Position(x, y, 0))

		id = map.MapObjects.AddMapObject(tmpl, MapInfo.Position(x, y, z) )
		(created,obj) = map.MapObjects.TryGetMapObject(id)
		
		if not created:
			Logging.Logger.LogError(__name__, 'object not created')

op()
