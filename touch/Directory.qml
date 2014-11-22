
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

SlidePage {
    id: page
    property string provider
    property bool can_search

    Component.onCompleted: {
        if (!page.can_search) {
            // Load static data
            search('');
        }
    }

    function search(text) {
        loading.visible = true;
        directorySearchModel.search(text, function() {
            loading.visible = false;
        });
    }

    ListView {
        id: listView

        anchors.fill: parent
        boundsBehavior: Flickable.StopAtBounds

        PScrollDecorator { flickable: listView }

        model: GPodderDirectorySearchModel { id: directorySearchModel; provider: page.provider }

        header: Column {
            anchors {
                left: parent.left
                right: parent.right
            }

            SlidePageHeader { title: page.provider }

            Column {
                visible: page.can_search

                spacing: 0.5 * 30 * pgst.scalef

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: 30 * pgst.scalef
                }

                PTextField {
                    id: input
                    width: parent.width
                    placeholderText: 'Search term'
                    onAccepted: page.search(input.text);
                }

                ButtonArea {
                    id: button
                    width: input.width
                    height: input.height

                    PLabel {
                        anchors.centerIn: parent
                        text: 'Search'
                    }

                    onClicked: page.search(input.text);
                }
            }
        }

        delegate: DirectoryItem {
            onClicked: {
                py.call('main.subscribe', [url], function () {
                    page.closePage();
                });
            }
        }
    }

    PBusyIndicator {
        id: loading
        visible: false
        anchors.centerIn: parent
    }
}
