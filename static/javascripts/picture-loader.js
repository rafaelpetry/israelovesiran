$(function() {
  function handleFileSelect(evt) {
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
    $('.controls label').removeClass('active');
    $(this).parent('label').addClass('active');
    // this is the cherry on the top
    $('body').removeAttr('class');
    $('body').addClass($(this).val());
  });
  $('input#choose-picture').on("change", function (evt) {
    handleFileSelect(evt);
    $('div.color-picker').show();
    $('div.generate').show();
  });
});
