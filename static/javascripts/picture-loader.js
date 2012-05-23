$(function() {
  function handleFileSelect(evt) {
    if (!(window.File && window.FileReader && window.FileList && window.Blob)) {
      // File APIs are not supported
      return;
    }

    var file = evt.target.files[0],
        reader = new FileReader();

    reader.onload = function (e) {
        var picture = '<img class="picture" src="' + e.target.result + '"/>';
        $('#picture').html(picture);
        $('.controls label.active input')[0].click()
    };

    reader.readAsDataURL(file);
  };

  function updateBanner(bannerName) {
    var banner = $('#banner'),
        bannerImg = '<img class="banner-image '+bannerName+'" src="/images/banners/'+bannerName+'.png">';

    banner.html(bannerImg);
  };

  $('.controls label input[type="radio"]').click(function () {
    var bannerName = $(this).val();

    $('.controls label').removeClass('active');
    $(this).parent('label').addClass('active');

    // this is the cherry on the top
    $('body').removeAttr('class');
    $('body').addClass(bannerName);

    updateBanner(bannerName);
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
