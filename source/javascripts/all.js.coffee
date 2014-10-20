urlParam = (name) ->
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
    regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
    results = regex.exec(location.search)
    decodeURIComponent(results[1].replace(/\+/g, " ")) if results?

$('.subject').val urlParam('topic') if urlParam('topic')
