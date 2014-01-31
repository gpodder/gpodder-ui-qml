
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2013, 2014, Thomas Perl <m@thp.io>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 *
 */

import QtQuick 2.0
import io.thp.pyotherside 1.0


Python {
    id: py

    property bool ready: false
    signal downloading(int episode_id)
    signal downloadProgress(int episode_id, real progress)
    signal downloaded(int episode_id)
    signal deleted(int episode_id)
    signal isNewChanged(int episode_id, bool is_new)

    Component.onCompleted: {
        setHandler('hello', function (version, copyright) {
            console.log('gPodder version ' + version + ' starting up');
            console.log('Copyright: ' + copyright);
        });

        setHandler('downloading', py.downloading);
        setHandler('download-progress', py.downloadProgress);
        setHandler('downloaded', py.downloaded);
        setHandler('deleted', py.deleted);
        setHandler('is-new-changed', py.isNewChanged);

        var path = Qt.resolvedUrl('../..').substr('file://'.length);
        addImportPath(path);

        // Load the Python side of things
        importModule('main', function() {
            py.ready = true;
        });
    }

    onReceived: {
        console.log('unhandled message: ' + data);
    }

    onError: {
        console.log('Python failure: ' + traceback);
    }
}
