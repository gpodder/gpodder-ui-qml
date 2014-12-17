
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

import 'common'
import 'common/util.js' as Util
import 'common/constants.js' as Constants
import 'icons/icons.js' as Icons

SlidePage {
    id: page

    property int podcast_id
    property string title

    hasMenuButton: true
    menuButtonLabel: 'Settings'
    onMenuButtonClicked: {
        pgst.showSelection([
            {
                label: 'Filter list (' + queryControl.currentFilter + ')',
                callback: function () {
                    queryControl.showSelectionDialog();
                }
            },
            {
                label: 'Mark episodes as old',
                callback: function () {
                    py.call('main.mark_episodes_as_old', [page.podcast_id]);
                },
            },
            {
                label: 'Enqueue episodes in player',
                callback: function () {
                    var startPlayback = Util.atMostOnce(function () {
                        if (!player.isPlaying) {
                            player.jumpToQueueIndex(0);
                        }
                    });

                    episodeList.model.forEachEpisode(function (episode) {
                        player.enqueueEpisode(episode.id, startPlayback);
                    });
                },
            },
            {
                label: 'Podcast details',
                callback: function () {
                    pgst.loadPage('PodcastDetail.qml', {podcast_id: podcast_id, title: title});
                }
            },
            {
                label: 'Unsubscribe',
                callback: function () {
                    var ctx = { py: py, id: page.podcast_id, page: page };
                    pgst.showConfirmation(title, 'Unsubscribe', 'Cancel', 'Remove this podcast and all downloaded episodes?', Icons.trash, function () {
                        ctx.py.call('main.unsubscribe', [ctx.id]);
                        ctx.page.closePage();
                    });
                },
            },
        ], undefined, undefined, true);
    }


    Component.onCompleted: {
        episodeList.model.podcast_id = podcast_id;
        // List model will be loaded automatically on load
    }

    EpisodeQueryControl {
        id: queryControl
        model: episodeList.model
        title: 'Select filter'
    }

    EpisodeListView {
        id: episodeList
        title: page.title
    }
}
