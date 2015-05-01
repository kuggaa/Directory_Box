$(document).on( "ready", function() {

	var path = window.location.pathname.slice(1)

	if ( path == "search" || path == "send" ) {

			var links = $("a.search_result_link")
			links.on('click', function() {
				setTimeout(function() {
					location.reload()
				}, 100)
			})

	}
})