
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
import 'icons/icons.js' as Icons

Dialog {
    id: selectionDialog

    property string title: ''
    property var callback: undefined
    property var items: ([])
    property var selectedIndex: -1

    contentHeight: selectionDialogFlickable.contentHeight

    Flickable {
        id: selectionDialogFlickable

        boundsBehavior: Flickable.StopAtBounds

        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width

            SlidePageHeader {
                id: header
                visible: title != ''
                color: Constants.colors.dialogHighlight
                title: selectionDialog.title
            }

            Repeater {
                model: selectionDialog.items

                delegate: ButtonArea {
                    id: buttonArea

                    color: Constants.colors.dialogArea
                    width: parent.width
                    height: 70 * pgst.scalef

                    transparent: (index != selectionDialog.selectedIndex)

                    PLabel {
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            margins: 20 * pgst.scalef
                        }

                        text: modelData
                        color: (index == selectionDialog.selectedIndex || buttonArea.pressed) ? Constants.colors.dialogHighlight : Constants.colors.dialogText
                        font.pixelSize: 30 * pgst.scalef
                        elide: Text.ElideRight
                    }

                    onClicked: {
                        if (selectionDialog.callback !== undefined) {
                            selectionDialog.callback(index, modelData);
                        }
                        selectionDialog.closePage();
                    }
                }
            }
        }
    }

    PScrollDecorator { flickable: selectionDialogFlickable }
}
