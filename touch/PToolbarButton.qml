
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2014, Thomas Perl <m@thp.io>
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

import 'common/constants.js' as Constants
import 'icons/icons.js' as Icons

Rectangle {
    id: toolbarButton

    //property alias color: iconMenuItem.color
    //property alias text: iconMenuItem.text
    property string text: ''
    property alias icon: iconMenuItem.icon

    signal clicked()

    width: iconMenuItem.width
    height: iconMenuItem.height
    color: iconMenuItem.pressed ? (platform.invertedToolbar ? Constants.colors.inverted.toolbarArea : Constants.colors.toolbarArea) : 'transparent'

    Rectangle {
        visible: iconMenuItem.pressed && !platform.invertedToolbar
        height: 5 * pgst.scalef
        color: Constants.colors.secondaryHighlight

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
    }

    IconMenuItem {
        id: iconMenuItem
        color: platform.invertedToolbar ? Constants.colors.inverted.toolbarText : Constants.colors.toolbarText
        colorDisabled: platform.invertedToolbar ? Constants.colors.inverted.toolbarDisabled : Constants.colors.toolbarDisabled
        transparent: true
        enabled: parent.enabled
        onClicked: toolbarButton.clicked()
    }
}
