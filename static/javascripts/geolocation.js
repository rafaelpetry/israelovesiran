$(function () {
    function geolocationSuccess(position) {
      $('<input>').attr({
        type: 'hidden',
        name: 'latitude',
        value: position.coords.latitude
      }).appendTo('form');
      $('<input>').attr({
        type: 'hidden',
        name: 'longitude',
        value: position.coords.longitude
      }).appendTo('form');
    }

    $(document).ready(function () {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(geolocationSuccess);
      }
    })
});
