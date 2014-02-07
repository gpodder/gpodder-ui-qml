

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

Item {
    id: coverArt

    property string text
    property alias source: cover.source

    Image {
        id: cover
        asynchronous: true

        opacity: source && status == Image.Ready
        Behavior on opacity { PropertyAnimation { duration: 100 } }

        sourceSize.width: width
        sourceSize.height: height

        width: parent.width
        height: parent.height
    }

    Rectangle {
        opacity: 0.3 * (1 - cover.opacity)
        anchors.fill: cover
        clip: true

        color: Constants.colors.background

        PLabel {
            text: coverArt.text[0]
            color: Constants.colors.highlight
            anchors.centerIn: parent
            font.pixelSize: parent.height * .8
        }
    }
}
