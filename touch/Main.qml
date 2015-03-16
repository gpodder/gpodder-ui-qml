
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
import 'common'

import 'common/util.js' as Util
import 'common/constants.js' as Constants
import 'icons/icons.js' as Icons

Item {
    id: pgst

    GPodderCore { id: py }
    GPodderPlayback { id: player }
    GPodderPlatform { id: platform }

    GPodderPodcastListModel { id: podcastListModel }
    GPodderPodcastListModelConnections {}

    Keys.onPressed: {
        switch (event.key) {
            case Qt.Key_Space:
                player.togglePause();
                break;
            case Qt.Key_Q:
                player.seekAndSync(player.position - 60 * 1000);
                break;
            case Qt.Key_W:
                player.seekAndSync(player.position - 10 * 1000);
                break;
            case Qt.Key_O:
                player.seekAndSync(player.position + 10 * 1000);
                break;
            case Qt.Key_P:
                player.seekAndSync(player.position + 60 * 1000);
                break;
            case Qt.Key_Escape:
            case Qt.Key_Backspace:
            case Qt.Key_Back:
                if (backButton.enabled) {
                    backButton.clicked();
                    event.accepted = true;
                }
                break;
            default:
                break;
        }
    }

    // Initial focus
    focus: true

    property real scalef: (width < height) ? (width / 480) : (height / 480)
    property int shorterSide: (width < height) ? width : height
    property int dialogsVisible: 0

    anchors.fill: parent

    function update(page, x) {
        var index = -1;
        for (var i=0; i<children.length; i++) {
            if (children[i] === page) {
                index = i;
                break;
            }
        }

        if (page.isDialog) {
            children[index-1].opacity = 1;
        } else {
            children[index-1].opacity = x / width;
        }

        //children[index-1].pushPhase = x / width;
    }

    property bool havePlayer: false
    property bool loadPageInProgress: false
    property bool hasBackButton: false
    property int bottomSpacing: toolbar.showing ? toolbar.height+toolbar.anchors.bottomMargin : 0

    property bool hasMenuButton: false
    property string menuButtonLabel: ''
    property string menuButtonIcon: ''
    property string windowTitle: 'gPodder'

    function onDialogDismissed(dialog) {
        for (var i=0; i<children.length; i++) {
            // If the dismissed dialog is not on top of the stack, it was
            // dismissed while another page was pushed, so we need to do
            // another topOfStackChanged() to get the right top item
            // (see https://github.com/gpodder/gpodder-bb10/issues/7)
            if (children[i] === dialog && i < children.length - 1) {
                topOfStackChanged();
                break;
            }
        }
    }

    function topOfStackChanged(offset) {
        if (offset === undefined) {
            offset = 0;
        }

        var page = children[children.length+offset-1];

        pgst.hasBackButton = Qt.binding(function () { return page.isDialog || page.canClose; });
        pgst.hasMenuButton = Qt.binding(function () { return !page.isDialog && page.hasMenuButton; });
        pgst.menuButtonLabel = Qt.binding(function () { return (!page.isDialog && pgst.hasMenuButton) ? page.menuButtonLabel : 'Menu'; });
        pgst.menuButtonIcon = Qt.binding(function () { return (!page.isDialog && pgst.hasMenuButton) ? page.menuButtonIcon : Icons.stack; });

        if (!page.isDialog) {
            pgst.windowTitle = page.title || 'gPodder';
        }
    }

    function showConfirmation(title, affirmative, negative, description, icon, callback) {
        loadPage('Confirmation.qml', {
            title: title,
            affirmativeAction: affirmative,
            negativeAction: negative,
            description: description,
            icon: icon,
            callback: callback,
        });
    }

    function showSelection(items, title, selectedIndex, activatedFromMenu) {
        loadPage('SelectionDialog.qml', {
            title: title,
            callback: function (index, item) {
                items[index].callback();
            },
            items: function() {
                var result = [];
                for (var i in items) {
                    result.push(items[i].label);
                }
                return result;
            }(),
            selectedIndex: selectedIndex,
            activatedFromMenu: activatedFromMenu ? activatedFromMenu : false
        });
    }

    function loadPage(filename, properties) {
        if (pgst.loadPageInProgress) {
            console.log('ignoring loadPage request while load in progress');
            return;
        }

        var component = Qt.createComponent(filename);
        if (component.status != Component.Ready) {
            console.log('Error loading ' + filename + ':' +
                component.errorString());
        }

        if (properties === undefined) {
            properties = {};
        }

        pgst.loadPageInProgress = true;
        component.createObject(pgst, properties);
    }

    PBusyIndicator {
        anchors.centerIn: parent
        visible: !py.ready
    }

    Image {
        z: 101
        anchors {
            left: parent.left
            right: parent.right
            top: platform.toolbarOnTop ? toolbar.bottom : undefined
            bottom: platform.toolbarOnTop ? undefined : toolbar.top
        }

        source: platform.toolbarOnTop ? 'images/toolbarshadow-top.png' : 'images/toolbarshadow.png'
        opacity: .1
        height: 10 * pgst.scalef
        visible: toolbar.showing
    }

    PToolbar {
        id: toolbar
        z: 102

        anchors {
            top: platform.toolbarOnTop ? parent.top : undefined
            bottom: platform.toolbarOnTop ? undefined : parent.bottom
        }

        Row {
            id: toolbarButtonsLeft

            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }

            PToolbarButton {
                id: backButton

                text: 'Back'
                icon: Icons.arrow_left

                visible: platform.needsBackButton
                enabled: pgst.hasBackButton
                onClicked: {
                    if (enabled) {
                        pgst.children[pgst.children.length-1].closePage();
                    }
                }
            }
        }

        PToolbarLabel {
            visible: platform.titleInToolbar

            anchors {
                verticalCenter: parent.verticalCenter
                left: toolbarButtonsLeft.right
                right: toolbarButtonsRight.left
                margins: Constants.layout.padding * pgst.scalef
            }

            text: pgst.windowTitle
        }

        Row {
            id: toolbarButtonsRight

            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }

            PToolbarButton {
                id: throbber

                text: 'Now Playing'
                icon: Icons.play
                visible: !platform.floatingPlayButton && !pgst.havePlayer

                enabled: player.episode != 0
                onClicked: loadPage('PlayerPage.qml');
            }

            PToolbarButton {
                id: menuButton

                text: pgst.menuButtonLabel
                icon: pgst.menuButtonIcon
                visible: enabled || !platform.hideDisabledMenu

                enabled: pgst.hasMenuButton
                onClicked: pgst.children[pgst.children.length-1].menuButtonClicked()
            }
        }
    }

    Rectangle {
        z: 103
        color: 'transparent'
        height: 20 * pgst.scalef
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        MouseArea {
            property real pressedY

            anchors.fill: parent
            onPressed: {
                mouse.accepted = true;
                pressedY = mouse.y;
            }

            onReleased: {
                var yDiff = (mouse.y - pressedY) / pgst.scalef
                if (yDiff > 50) {
                    if (throbber.enabled) {
                        throbber.clicked();
                    }
                }
            }
        }
    }

    Rectangle {
        z: 190
        color: Constants.colors.playback
        visible: platform.floatingPlayButton && !pgst.havePlayer

        Behavior on opacity { NumberAnimation { } }
        opacity: (player.episode != 0) ? (player.isPlaying ? 1 : .5) : 0

        width: Constants.layout.item.height * 1.1 * pgst.scalef
        height: width
        radius: height / 2

        anchors {
            right: parent.right
            margins: Constants.layout.padding * 2 * pgst.scalef
        }

        y: pgst.height - height - anchors.margins

        PIcon {
            id: icon
            anchors.centerIn: parent
            icon: Icons.headphones
            size: 60
            color: Constants.colors.inverted.toolbarText
        }

        MouseArea {
            anchors.fill: parent
            onClicked: loadPage('PlayerPage.qml');
            drag {
                target: parent
                axis: Drag.YAxis
                minimumY: pgst.bottomSpacing + parent.anchors.margins
                maximumY: pgst.height - parent.height - parent.anchors.margins
            }
        }
    }

    PodcastsPage {
        visible: py.ready
    }
}
