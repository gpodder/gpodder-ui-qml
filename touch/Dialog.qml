
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

Rectangle {
    id: page
    z: 200
    property bool activatedFromMenu: false
    property bool moveToTop: false
    property bool attachToToolbar: platform.toolbarOnTop && activatedFromMenu

    color: Constants.colors.dialogBackground

    Component.onCompleted: {
        pgst.dialogsVisible = pgst.dialogsVisible + 1;
        pgst.topOfStackChanged();
    }

    Component.onDestruction: {
        pgst.dialogsVisible = pgst.dialogsVisible - 1;
        pgst.onDialogDismissed(page);
    }

    default property alias children: contents.children
    property bool isDialog: true
    property int contentHeight: -1
    property bool fullWidth: false

    function closePage() {
        stacking.startFadeOut();
    }

    onXChanged: pgst.update(page, x)

    width: parent.width
    height: parent.height

    DialogStacking { id: stacking }

    MouseArea {
        anchors.fill: parent
        onClicked: page.closePage();
    }

    MouseArea {
        // Tapping on the dialog contents should do nothing
        anchors.fill: contents
    }

    Rectangle {
        id: contents
        property int border: parent.width * 0.1
        width: parent.fullWidth ? parent.width : (parent.width - 2 * border)
        property int maxHeight: parent.height - toolbar.height
        height: ((page.contentHeight > 0 && page.contentHeight < maxHeight) ? page.contentHeight : maxHeight) * parent.opacity
        anchors {
            horizontalCenter: activatedFromMenu ? undefined : parent.horizontalCenter
            verticalCenter: (moveToTop || activatedFromMenu) ? undefined : parent.verticalCenter

            right: activatedFromMenu ? parent.right : undefined

            top: (moveToTop || (activatedFromMenu && platform.toolbarOnTop)) ? parent.top : undefined
            topMargin: (moveToTop || (activatedFromMenu && platform.toolbarOnTop)) ? pgst.bottomSpacing : 0

            bottom: (!moveToTop && activatedFromMenu && !platform.toolbarOnTop) ? parent.bottom : undefined
            bottomMargin: (!moveToTop && activatedFromMenu && !platform.toolbarOnTop) ? pgst.bottomSpacing : 0
        }
        color: Constants.colors.dialog
        clip: true
    }
}
