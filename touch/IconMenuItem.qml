
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

import 'common/constants.js' as Constants

ButtonArea {
    id: iconMenuItem

    property alias text: label.text
    property color color: Constants.colors.secondaryHighlight
    property color colorDisabled: Constants.colors.placeholder
    property color _real_color: enabled ? color : colorDisabled
    property alias icon: icon.icon
    property alias size: icon.size
    property bool alwaysShowText: false

    Behavior on _real_color { ColorAnimation { duration: 100 } }

    transparent: true
    canHighlight: false

    height: 80 * pgst.scalef
    width: height

    PIcon {
        id: icon
        anchors.centerIn: parent
        opacity: iconMenuItem.enabled ? 1 : .2
        color: label.color
    }

    PLabel {
        id: label
        font.pixelSize: 15 * pgst.scalef
        visible: parent.pressed || parent.alwaysShowText
        color: parent.pressed ? Qt.darker(iconMenuItem._real_color, 1.1) : iconMenuItem._real_color

        anchors {
            bottom: icon.top
            horizontalCenter: icon.horizontalCenter
            margins: 5 * pgst.scalef
        }
    }
}
