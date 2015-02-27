
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

import 'common/constants.js' as Constants
import 'icons/icons.js' as Icons

Item {
    id: slidePageHeader
    property alias title: label.text
    property alias color: label.color
    property alias wrapMode: label.wrapMode
    property bool isOnSlidePage: (typeof(page) !== 'undefined') ? page : null
    property real padding: 20

    width: parent.width

    visible: !platform.titleInToolbar || !isOnSlidePage
    height: visible ? (2 * padding * pgst.scalef + label.height) : 0

    Binding {
        target: isOnSlidePage ? page : null
        property: 'title'
        value: slidePageHeader.title
        when: platform.titleInToolbar
    }

    PLabel {
        id: label
        anchors {
            left: parent.left
            right: parent.right
            rightMargin: slidePageHeader.padding * pgst.scalef
            leftMargin: slidePageHeader.padding * pgst.scalef
            verticalCenter: parent.verticalCenter
        }

        color: Constants.colors.highlight
        font.pixelSize: Constants.layout.header.height * pgst.scalef * .4
        elide: Text.ElideRight
    }
}
