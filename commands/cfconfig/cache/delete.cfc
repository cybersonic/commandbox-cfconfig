/**
* Delete a cache.  Identify the cache uniquely by the name.
* 
* {code}
* cfconfig cache delete myCache
* cfconfig cache delete myCache serverName
* cfconfig cache delete myCache /path/to/server/home
* {code}
*
*/
component {
	
	property name='CFConfigService' inject='CFConfigService@cfconfig-services';
	property name='Util' inject='util@commandbox-cfconfig';
	/**
	* @name The name of the cache
	* @to CommandBox server name, server home path, or CFConfig JSON file. Defaults to CommandBox server in CWD.
	* @toFormat The format to write to. Ex: LuceeServer@5
	*/	
	function run(
		required string name,
		string to,
		string toFormat
	) {		
		var to = arguments.to ?: '';
		var toFormat = arguments.toFormat ?: '';

		try {
			var toDetails = Util.resolveServerDetails( to, toFormat );
		} catch( cfconfigException var e ) {
			error( e.message, e.detail ?: '' );
		}
			
		if( !toDetails.path.len() ) {
			error( "The location for the server couldn't be determined.  Please check your spelling." );
		}
		
		// Read existing config
		var oConfig = CFConfigService.determineProvider( toDetails.format, toDetails.version )
			.read( toDetails.path );

		// Get the caches and remove the requested one
		var caches = oConfig.getCaches() ?: {};
		caches.delete( name );	
		
		// Set remaining caches back and save
		oConfig.setCaches( caches )
			.write( toDetails.path );		
			
		print.greenLine( 'cache [#name#] deleted.' );
	}
	
}