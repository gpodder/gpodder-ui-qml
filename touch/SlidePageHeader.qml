
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

    property alias iconText: icon.text
    property alias icon: icon.icon
    signal iconClicked()

    width: parent.width
    height: Constants.layout.header.height * pgst.scalef

    IconMenuItem {
        id: icon

        visible: icon != '' && icon != undefined
        enabled: visible

        text: 'Search'
        icon: ''
        color: label.color

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

        onClicked: slidePageHeader.iconClicked()
    }

    PLabel {
        id: label
        anchors {
            left: icon.visible ? icon.right : parent.left
            right: parent.right
            rightMargin: 20 * pgst.scalef + (throbber.width * throbber.opacity)
            leftMargin: 20 * pgst.scalef
            verticalCenter: parent.verticalCenter
        }

        color: Constants.colors.highlight
        horizontalAlignment: Text.AlignRight
        font.pixelSize: parent.height * .4
        elide: Text.ElideRight
    }
}

