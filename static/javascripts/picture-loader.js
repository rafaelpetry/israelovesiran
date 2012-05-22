$(function() {
  $('.controls label input[type="radio"]').click(function () {
    $('.controls label').removeClass('active');
    $(this).parent('label').addClass('active');
    // this is the cherry on the top
    $('body').removeAttr('class');
    $('body').addClass($(this).val());
  });
  $('input#choose-picture').on("change", function () {
    $('div.color-picker').show();
    $('div.generate').show();
  });
});
