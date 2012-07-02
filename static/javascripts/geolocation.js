$(function () {
    function geolocationSuccess(position) {
      var photo_id = $('img.user-image').attr('id'),
          lat = position.coords.latitude,
          lon = position.coords.longitude,
          url = '/coordinates/'+photo_id+'/'+lat+'/'+lon;

      $.post(url);
    }

    $(document).ready(function () {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(geolocationSuccess);
      }
    })
});
