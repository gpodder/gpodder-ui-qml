function updateModelFrom(model, data) {
    // TODO: This is very naive at the moment, we should do proper remove(),
    // move(), set() and insert() calls, so that the UI can animate changes.
    for (var i=0; i<data.length; i++) {
        if (model.count < i) {
            model.append(data[i]);
        } else {
            model.set(i, data[i]);
        }
    }

    while (model.count > data.length) {
        model.remove(model.count-1);
    }

    model.sync();
}

function updateModelWith(model, key, value, update) {
    for (var row=0; row<model.count; row++) {
        var current = model.get(row);
        if (current[key] == value) {
            for (var key in update) {
                model.setProperty(row, key, update[key]);
            }
        }
    }

    model.sync();
}

WorkerScript.onMessage = function (msg) {
    if (msg.action === 'updateModelFrom') {
        updateModelFrom(msg.model, msg.data);
        WorkerScript.sendMessage({callback: msg.callback});
    } else if (msg.action === 'updateModelWith') {
        updateModelWith(msg.model, msg.key, msg.value, msg.update);
        WorkerScript.sendMessage({callback: msg.callback});
    } else {
        console.log('Unknown action: ' + msg.action);
    }
}
