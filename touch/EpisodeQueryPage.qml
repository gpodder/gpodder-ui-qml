
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
import 'common/constants.js' as Constants
import 'icons/icons.js' as Icons

SlidePage {
    id: page

    hasMenuButton: true
    menuButtonIcon: Icons.magnifying_glass
    menuButtonLabel: 'Filter'
    onMenuButtonClicked: queryControl.showSelectionDialog()

    EpisodeQueryControl {
        id: queryControl
        model: episodeList.model
        title: 'Select filter'
    }

    EpisodeListView {
        id: episodeList
        title: 'Episodes'

        section.property: 'section'
        section.delegate: SectionHeader {
            text: section
            color: episodeList.selectedIndex === -1 ? Constants.colors.secondaryHighlight : Constants.colors.text
            opacity: episodeList.selectedIndex === -1 ? 1 : 0.2
        }
    }
}
