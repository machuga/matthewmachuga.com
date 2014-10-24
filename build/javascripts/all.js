(function() {
  var urlParam;

  urlParam = function(name) {
    var regex, results;
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    regex = new RegExp("[\\?&]" + name + "=([^&#]*)");
    results = regex.exec(location.search);
    if (results != null) {
      return decodeURIComponent(results[1].replace(/\+/g, " "));
    }
  };

  if (urlParam('topic')) {
    $('.subject').val(urlParam('topic'));
  }

}).call(this);
