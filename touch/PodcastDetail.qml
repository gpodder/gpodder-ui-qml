
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
import 'icons/icons.js' as Icons

SlidePage {
    id: page

    property int podcast_id
    property string title
    property string description
    property string link
    property string section
    property string coverart
    property string url

    property bool ready: false

    hasMenuButton: true
    onMenuButtonClicked: {
        pgst.showSelection([
            {
                label: 'Visit website',
                callback: function () {
                    Qt.openUrlExternally(page.link);
                }
            },
            {
                label: 'Copy feed URL',
                callback: function () {
                    pgst.loadPage('TextInputDialog.qml', {
                        placeholderText: 'Feed URL',
                        text: page.url,
                    });
                }
            },
            {
                label: 'Change section',
                callback: function () {
                    var ctx = { py: py, id: page.podcast_id };
                    pgst.loadPage('TextInputDialog.qml', {
                        buttonText: 'Change section',
                        placeholderText: 'New section',
                        text: section,
                        callback: function (new_section) {
                            ctx.py.call('main.change_section', [ctx.id, new_section]);
                        }
                    });
                }
            },
        ], undefined, undefined, true);
    }

    PBusyIndicator {
        anchors.centerIn: parent
        visible: !page.ready
    }

    Component.onCompleted: {
        py.call('main.show_podcast', [podcast_id], function (podcast) {
            page.title = podcast.title;
            page.description = podcast.description;
            page.link = podcast.link;
            page.section = podcast.section;
            page.coverart = podcast.coverart;
            page.url = podcast.url;
            page.ready = true;
        });
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        boundsBehavior: Flickable.StopAtBounds

        contentWidth: detailColumn.width
        contentHeight: detailColumn.height + detailColumn.spacing

        Column {
            id: detailColumn

            width: page.width
            spacing: Constants.layout.padding * pgst.scalef

            Item { height: Constants.layout.padding * pgst.scalef; width: parent.width }

            Column {
                width: parent.width - 2 * Constants.layout.padding * pgst.scalef
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Constants.layout.padding * pgst.scalef

                PExpander {
                    width: parent.width
                    expandedHeight: coverImage.height

                    Image {
                        id: coverImage
                        source: page.coverart
                        fillMode: Image.PreserveAspectFit
                        width: parent.width
                    }
                }

                SlidePageHeader {
                    title: page.title
                    width: parent.width
                    wrapMode: Text.WordWrap
                    color: Constants.colors.highlight
                }

                PLabel {
                    visible: text !== ''
                    text: page.link
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: 20 * pgst.scalef
                    color: Constants.colors.placeholder
                }

                PLabel {
                    text: 'Section: ' + page.section
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: 20 * pgst.scalef
                    color: Constants.colors.placeholder
                }

                PLabel {
                    text: page.description
                    width: parent.width
                    font.pixelSize: 30 * pgst.scalef
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    PScrollDecorator { flickable: flickable }
}
