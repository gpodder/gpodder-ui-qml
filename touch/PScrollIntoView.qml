
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


Timer {
    id: scrollTimer
    interval: 10
    repeat: true

    function begin(flickable_) {
        flickable = flickable_;
        lastHeight = flickable.contentHeight;
        repeatLimit = defaultRepeatLimit;
        scrollTimer.start();
    }

    property var flickable
    property int defaultRepeatLimit: 10
    property int repeatLimit: defaultRepeatLimit
    property real lastHeight: 0

    onTriggered: {
        flickable.contentY = flickable.contentHeight - flickable.height;
        flickable.returnToBounds();

        repeatLimit = repeatLimit - 1;
        lastHeight = flickable.contentHeight;

        if (repeatLimit <= 0 && lastHeight === flickable.contentHeight) {
            stop();
        }
    }
}
