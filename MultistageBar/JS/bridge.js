var jj = {};
window["jj"] = jj;

var responseCallback = {};

jj.login = function(callback) {
    call("login", {"title": "titlevalue"}, callback);
}

function call(funcName, args = null, callback = null) {
    if (window.webkit.messageHandlers[funcName] == false) {
        return;
    }
    var wrap = {
        "args": args
    }
    // 如果有回调,通过回调ID保存回调,
    if (callback && typeof callback == 'function') {
        var callbackID = createCallbackInfo(funcName, callback);
        wrap["callbackID"] = callbackID;
    }
    window.webkit.messageHandlers[funcName].postMessage(wrap)
}

function createCallbackInfo(funcName, callbackFunc) {
    var callbackID = 'js_oc_callback_' + (new Date().getTime());
    responseCallback[callbackID] = callbackFunc;
    return callbackID;
}

function jsCallIOSCallback(response) {
    var message = JSON.parse(response);
    if (message.callbackID) {
        var callback = responseCallback[message.callbackID];
        callback(message.data);
    }
    delete responseCallback[message.callbackID];
}


