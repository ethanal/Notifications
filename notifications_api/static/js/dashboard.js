$(function() {
    $("#send-notification").submit(function(event) {
        var $responseMessage = $("#send-notification-response");

        var target = $(this).data("target");
        $.ajax({
            type: "POST",
            url: target,
            data: $(this).serialize(),
            success: function(data) {
                $responseMessage.text(data.success);
                $responseMessage.removeClass("error");
            },
            error: function(jqXHR, textStatus, errorThrown) {
                if (jqXHR.status == 400) {
                    var msg = jQuery.parseJSON(jqXHR.responseText).error;
                } else {
                   var msg = "There was a error (" + jqXHR.statusText.toLowerCase() + ")";
                }
                $responseMessage.text(msg);
                $responseMessage.addClass("error");

            },
            complete: function() {
                $responseMessage.delay(1000).fadeOut('slow', function() {
                    $responseMessage.text("");
                    $responseMessage.show();
                });
            },
            xhrFields: {
                withCredentials: true
            }
        });

         event.preventDefault();
    });
});
