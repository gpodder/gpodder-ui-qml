
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

import 'util.js' as Util
import 'constants.js' as Constants

ListModel {
    id: episodeListModel

    property var podcast_id: -1

    property var queries: ({
        All: '',
        Fresh: 'new or downloading',
        Downloaded: 'downloaded or downloading',
        HideDeleted: 'not deleted',
        Deleted: 'deleted',
    })

    property var filters: ([
        { label: 'All', query: episodeListModel.queries.All },
        { label: 'Fresh', query: episodeListModel.queries.Fresh },
        { label: 'Downloaded', query: episodeListModel.queries.Downloaded },
        { label: 'Hide deleted', query: episodeListModel.queries.HideDeleted },
        { label: 'Deleted', query: episodeListModel.queries.Deleted },
    ])

    property bool ready: false
    property int currentFilterIndex: -1
    property string currentCustomQuery: queries.All

    function setQuery(query) {
        for (var i=0; i<filters.length; i++) {
            if (filters[i].query === query) {
                currentFilterIndex = i;
                return;
            }
        }

        currentFilterIndex = -1;
        currentCustomQuery = query;
    }

    function loadAllEpisodes(callback) {
        episodeListModel.podcast_id = -1;
        reload(callback);
    }

    function loadEpisodes(podcast_id, callback) {
        episodeListModel.podcast_id = podcast_id;
        reload(callback);
    }

    function reload(callback) {
        var query;

        if (currentFilterIndex !== -1) {
            query = filters[currentFilterIndex].query;
        } else {
            query = currentCustomQuery;
        }

        ready = false;
        py.call('main.load_episodes', [podcast_id, query], function (episodes) {
            Util.updateModelFrom(episodeListModel, episodes);
            episodeListModel.ready = true;
            if (callback !== undefined) {
                callback();
            }
        });
    }

    property var connections: Connections {
        target: py

        onDownloadProgress: {
            Util.updateModelWith(episodeListModel, 'id', episode_id,
                {'progress': progress});
        }
        onPlaybackProgress: {
            Util.updateModelWith(episodeListModel, 'id', episode_id,
                {'playbackProgress': progress});
        }
        onUpdatedEpisode: {
            for (var i=0; i<episodeListModel.count; i++) {
                if (episodeListModel.get(i).id == episode.id) {
                    episodeListModel.set(i, episode);
                    break;
                }
            }
        }
        onEpisodeListChanged: {
            if (episodeListModel.podcast_id == podcast_id) {
                episodeListModel.reload();
            }
        }
    }
}
