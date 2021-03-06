// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

jQuery(function() {

    $('#send-emails-modal').on('show.bs.modal', function (event) {
        var button = $(event.relatedTarget);
        var header = button.data('title');
        var list = button.data('list');
        var modal = $(this);
        modal.find('.modal-title').text(header);
        modal.find('#send-emails-mailto').attr('href', 'mailto:' + list);
        modal.find('#send-emails-list').val(list);
    });

    $('#send-emails-clipboard').click(function () {
        var $recipients = document.getElementById("email_recipients");
        $recipients.select();
        try {
            var successful = document.execCommand('copy');
            var msg = successful ? 'successful' : 'unsuccessful';
            console.log('Copying emails to the clipboard was ' + msg);
        }
        catch (err) {
            console.log('Unable to copy emails to the clipboard');
        }
        $temp.remove();
    });
});

function addEventDatePicker() {
  var picker = $('#event-add-date-picker');

  $(EVENT_DATE_PICKER_TEMPLATE)
    .insertBefore(picker);

  enableDatepickers();
}

function removeEventDatePicker(button) {
  $(button).parent('div').remove();
}
