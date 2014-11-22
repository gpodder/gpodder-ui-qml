
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

Dialog {
    id: textInputDialog
    moveToTop: true

    property string buttonText
    property string placeholderText
    property string text
    property bool pasteOnLoad: false
    property var callback

    contentHeight: contentColumn.height + 20 * pgst.scalef

    Component.onCompleted: {
        if (pasteOnLoad) {
            input.paste();
        }
    }

    function accept() {
        textInputDialog.callback(input.text);
        textInputDialog.closePage();
    }

    Column {
        id: contentColumn

        anchors.centerIn: parent
        spacing: 20 * pgst.scalef

        PTextField {
            id: input
            width: textInputDialog.width *.8
            placeholderText: textInputDialog.placeholderText
            text: textInputDialog.text
            onAccepted: textInputDialog.accept();
        }

        ButtonArea {
            id: button
            width: input.width
            height: input.height
            visible: textInputDialog.buttonText !== ''

            PLabel {
                anchors.centerIn: parent
                text: textInputDialog.buttonText
            }

            onClicked: textInputDialog.accept();
        }
    }
}
