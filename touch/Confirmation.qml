
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

SlidePage {
    id: confirmation

    property alias title: header.title
    property alias icon: icon.icon
    property alias color: header.color
    property var callback: undefined

    SlidePageHeader {
        id: header
        color: Constants.colors.destructive
        title: 'Confirmation'
    }

    PIcon {
        id: icon
        size: 300
        anchors.centerIn: parent
        color: header.color

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (confirmation.callback !== undefined) {
                    confirmation.callback();
                    confirmation.closePage();
                }
            }
        }
    }

    PLabel {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: icon.bottom
            margins: 30 * pgst.scalef
        }

        text: 'Tap to confirm'
        color: header.color
    }

    Row {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            margins: 60 * pgst.scalef
        }

        spacing: 30 * pgst.scalef

        PLabel {
            text: 'Swipe right to cancel'
            color: Constants.colors.text
        }

        PIcon {
            color: Constants.colors.text
            icon: Icons.arrow_right
        }
    }
}
