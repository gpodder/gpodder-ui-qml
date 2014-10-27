
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

Rectangle {
    property var flickable

    x: flickable.width - width
    y: flickable.visibleArea.yPosition * flickable.height
    width: 10 * pgst.scalef
    height: flickable.visibleArea.heightRatio * flickable.height
    visible: flickable.visibleArea.heightRatio < 1
    color: Constants.colors.background
    opacity: (showMoreTimer.showTemporarily || flickable.moving) ? .5 : 0
    Behavior on opacity { PropertyAnimation { duration: 100 } }

    Timer {
        id: showMoreTimer
        property bool showTemporarily: false
        interval: 500
        onTriggered: {
            if (parent.visible && !showTemporarily) {
                showTemporarily = true;
                showMoreTimer.interval = 2000;
                showMoreTimer.start();
            } else {
                showTemporarily = false;
            }
        }
    }

    Component.onCompleted: {
        showMoreTimer.start();
    }
}
