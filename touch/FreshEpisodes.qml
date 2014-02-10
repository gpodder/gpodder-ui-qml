
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2013, Thomas Perl <m@thp.io>
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

SlidePage {
    id: freshEpisodes
    property bool ready: false

    Component.onCompleted: {
        freshEpisodesListModel.loadFreshEpisodes(function () {
            freshEpisodes.ready = true;
        });
    }

    PBusyIndicator {
        visible: !freshEpisodes.ready
        anchors.centerIn: parent
    }

    PListView {
        id: episodeList
        property int selectedIndex: -1
        title: 'Fresh episodes'

        model: GPodderEpisodeListModel { id: freshEpisodesListModel }

        section.property: 'published'
        section.delegate: SectionHeader { text: section }

        delegate: EpisodeItem { }
    }
}

