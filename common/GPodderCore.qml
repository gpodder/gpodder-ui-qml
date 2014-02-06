
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

    property string progname: 'gpodder'
    property bool ready: false
    property bool refreshing: false
    signal downloading(int episode_id)
    signal downloadProgress(int episode_id, real progress)
    signal playbackProgress(int episode_id, real progress)
    signal downloaded(int episode_id)
    signal deleted(int episode_id)
    signal isNewChanged(int episode_id, bool is_new)
    signal stateChanged(int episode_id, int state)
    signal podcastListChanged()
    signal updatingPodcast(int podcast_id)
    signal updatedPodcast(var podcast)

    Component.onCompleted: {
        setHandler('hello', function (coreversion, uiversion) {
            console.log('gPodder Core ' + coreversion);
            console.log('gPodder QML UI ' + uiversion);
            console.log('PyOtherSide ' + py.pluginVersion());
            console.log('Python ' + py.pythonVersion());
        });

        setHandler('downloading', py.downloading);
        setHandler('download-progress', py.downloadProgress);
        setHandler('playback-progress', py.playbackProgress);
        setHandler('downloaded', py.downloaded);
        setHandler('deleted', py.deleted);
        setHandler('is-new-changed', py.isNewChanged);
        setHandler('state-changed', py.stateChanged);
        setHandler('podcast-list-changed', py.podcastListChanged);
        setHandler('updating-podcast', py.updatingPodcast);
        setHandler('updated-podcast', py.updatedPodcast);
        setHandler('refreshing', function(v) { py.refreshing = v; });

        addImportPath(Qt.resolvedUrl('../..'));

        // Load the Python side of things
        importModule('main', function() {
            py.call('main.initialize', [py.progname], function() {
                py.ready = true;
            });
        });
    }

    onReceived: {
        console.log('unhandled message: ' + data);
    }

    onError: {
        console.log('Python failure: ' + traceback);
    }
}
