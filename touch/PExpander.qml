
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

import 'common/constants.js' as Constants
import 'common/util.js' as Util


Item {
    id: expander

    property bool expanded: !canExpand
    property bool canExpand: expandedHeight > contractedHeight

    property real contractedHeight: 100 * pgst.scalef
    property real expandedHeight: childrenRect.height
    property color backgroundColor: Constants.colors.page

    height: expanded ? expandedHeight : contractedHeight
    clip: true

    Behavior on height { PropertyAnimation { } }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (expander.canExpand) {
                expander.expanded = !expander.expanded
            }
        }
    }

    Rectangle {
        z: 100

        opacity: chapterExpander.opacity

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: expander.contractedHeight * 0.6

        gradient: Gradient {
            GradientStop { position: 0; color: '#00000000' }
            GradientStop { position: 1; color: expander.backgroundColor }
        }
    }

    PLabel {
        id: chapterExpander

        z: 200

        anchors {
            right: parent.right
            bottom: parent.bottom
        }

        text: '...'
        font.pixelSize: 60 * pgst.scalef

        color: Constants.colors.highlight
        opacity: !expander.expanded

        Behavior on opacity { PropertyAnimation { } }
    }
}
