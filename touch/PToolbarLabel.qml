
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

Item {
    id: toolbarLabel

    property string text: ''
    property bool firstLable: false

    onTextChanged: {
        state = (state === 'a') ? 'b': 'a';
        if (state === 'a') {
            a.text = text;
        } else {
            b.text = text;
        }
    }

    states: [
        State {
            name: 'a'
            PropertyChanges { target: a; opacity: 1; anchors.leftMargin: 0 }
            PropertyChanges { target: b; opacity: 0; anchors.leftMargin: 10 * pgst.scalef }
        },
        State {
            name: 'b'
            PropertyChanges { target: a; opacity: 0; anchors.leftMargin: -10 * pgst.scalef }
            PropertyChanges { target: b; opacity: 1; anchors.leftMargin: 0 }
        }
    ]

    PLabel {
        id: a

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        color: platform.invertedToolbar ? Constants.colors.inverted.toolbarText : Constants.colors.toolbarText
        elide: Text.ElideRight

        Behavior on anchors.leftMargin { NumberAnimation { } }
        Behavior on opacity { NumberAnimation { } }
    }

    PLabel {
        id: b

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        color: platform.invertedToolbar ? Constants.colors.inverted.toolbarText : Constants.colors.toolbarText
        elide: Text.ElideRight

        Behavior on anchors.leftMargin { NumberAnimation { } }
        Behavior on opacity { NumberAnimation { } }
    }
}
