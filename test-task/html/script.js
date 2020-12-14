var APP_SERVER = "http://localhost:8081/kv/";

function setResponseError(error) {
    if (error === false) {
        $(".responseBlock").removeClass("error").addClass('success');
    } else if (error === true) {
        $(".responseBlock").removeClass("success").addClass('error');  
    } else {
        $(".responseBlock").removeClass("error").removeClass('success');
    }
};

function addLog(text, clear) {
    if (clear === true) {
        $('.responseBlock').html("");
    }
    $(".responseBlock").append('<p>' + text + '</p>');
};

function sendRequest(addr, method, params, callback) {
    console.log('sanding request');
    var payload = (typeof params == 'object') ? JSON.stringify(params) : params;
    $.ajax({
        method : method,
        url : APP_SERVER + addr,
        data: payload,
		  processData: true,
        dataType: "text",
        cache: false,
        success: function(data, textStatus, jqXHR ) {
			//console.log("AJAX success: ", data,textStatus, jqXHR);
            console.log(data);
            console.log(jqXHR,jqXHR.getAllResponseHeaders());
            //checkData(data);
            setResponseError(false);
			addLog(data, true);
            if (typeof callback == "function") callback(data);
        },
        error: function(jqXHR, textStatus, errorThrown) {
                setResponseError(true);
                addLog(textStatus,true);
                addLog(errorThrown);
        }
    });
};

$(document).on('click','.collapsible h3', function(ev) {
    $(this).parent().toggleClass('collapsed');
});

$(document).on('click','#getButton', function(ev) {
    let key = $("#getVal").val();
    sendRequest(key, "GET", {});
});

$(document).on('click','#putButton', function(ev) {
    let key = $("#putKey").val();
    let val = $("#putVal").val();
    sendRequest(key, "PUT", {value: val});
});

$(document).on('click','#postButton', function(ev) {
    let _key = $("#postKey").val();
    let val = $("#postVal").val();
    sendRequest("", "POST", {key: _key, value: val});
});

$(document).on('click','#deleteButton', function(ev) {
    let key = $("#deleteVal").val();
    sendRequest(key, "DELETE", {});
});

$(document).on('click','#mgetButton', function(ev) {
    let key = $("#mgetVal").val();
    let num = $('#mgetNum').val();
    for (let i = 0; i < num; i++) {
        sendRequest(key, "GET", {});
    }
});

$(() => {
    addLog("tests started!");
});