$(function() {
  function handleFileSelect(evt) {
    if (!(window.File && window.FileReader && window.FileList && window.Blob)) {
      // File APIs are not supported
      return;
    }

    var file = evt.target.files[0],
        reader = new FileReader();

    reader.onload = (function(theFile) {
      return function (e) {
        var span = document.createElement('span');
        span.innerHTML = ['<img class="picture" src="', e.target.result, '" title="', escape(theFile.name), '"/>'].join('');
        $('#picture').prepend(span);
      };
    })(file);

    reader.readAsDataURL(file);
  };

  $('.controls label input[type="radio"]').click(function () {
    var bannerName = $(this).val();
    var seal = $('#seal');
    var banner = '';

    $('.controls label').removeClass('active');
    $(this).parent('label').addClass('active');

    // this is the cherry on the top
    $('body').removeAttr('class');
    $('body').addClass(bannerName);

    banner = '<img class="seal-image '+bannerName+'" src="/images/banners/'+bannerName+'.png">';
    seal.empty();
    seal.append(banner);

  });
  $('input#choose-picture').on("change", function (evt) {
    if (!evt.target.files[0].type.match('image.*')) {
      alert("Please, choose an image.");
      return;
    }

    handleFileSelect(evt);
    $('div.color-picker').show();
    $('div.generate').show();
  });



});
