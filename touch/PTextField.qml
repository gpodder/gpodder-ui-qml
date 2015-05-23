
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
    id: textField

    property alias text: textInput.text
    property string placeholderText: ''
    signal accepted

    function paste() {
        textInput.paste();
    }

    height: 50 * pgst.scalef

    TextInput {
        id: textInput

        Component.onDestruction: {
            // Return keyboard focus to pgst
            pgst.focus = true;
        }

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: clipboardIcon.left
            margins: 5 * pgst.scalef
        }
        clip: true

        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText

        color: Constants.colors.text
        selectionColor: Constants.colors.background
        font.pixelSize: parent.height * 0.7
        font.family: placeholder.font.family
        focus: true
        onAccepted: textField.accepted()
    }

    PLabel {
        id: placeholder
        anchors.fill: textInput
        visible: (textInput.text == '')
        text: textField.placeholderText
        color: Constants.colors.placeholder
        font.pixelSize: textInput.font.pixelSize
    }

    IconMenuItem {
        id: clipboardIcon

        anchors {
            right: parent.right
            margins: 5 * pgst.scalef
            verticalCenter: parent.verticalCenter
        }

        icon: Icons.paperclip
        onClicked: {
            pgst.showSelection([
                {
                    label: 'Copy',
                    callback: function () {
                        textInput.copy();
                    }
                },
                {
                    label: 'Paste',
                    callback: function() {
                        textInput.paste();
                    }
                },
                {
                    label: 'Cut',
                    callback: function() {
                        textInput.cut();
                    }
                },
                {
                    label: 'Clear',
                    callback: function() {
                        textInput.text = '';
                    }
                },
                {
                    label: 'Select all',
                    callback: function() {
                        textInput.selectAll();
                    }
                }
            ]);
        }
    }
}
