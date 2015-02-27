
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
import 'common/util.js' as Util
import 'icons/icons.js' as Icons

SlidePage {
    id: detailPage

    property int episode_id
    property string title
    property string link
    property bool ready: false
    property var chapters: ([])

    hasMenuButton: detailPage.link != ''
    menuButtonIcon: Icons.link
    menuButtonLabel: 'Website'
    onMenuButtonClicked: Qt.openUrlExternally(detailPage.link)

    PBusyIndicator {
        anchors.centerIn: parent
        visible: !detailPage.ready
    }

    Component.onCompleted: {
        py.call('main.show_episode', [episode_id], function (episode) {
            detailPage.title = episode.title;
            descriptionLabel.text = episode.description;
            metadataLabel.text = episode.metadata;
            detailPage.link = episode.link;
            detailPage.ready = true;
            detailPage.chapters = episode.chapters;
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

            width: detailPage.width
            spacing: Constants.layout.padding * pgst.scalef

            Item { height: Constants.layout.padding * pgst.scalef; width: parent.width }

            Column {
                width: parent.width - 2 * Constants.layout.padding * pgst.scalef
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Constants.layout.padding * pgst.scalef

                SlidePageHeader {
                    padding: 0
                    title: detailPage.title
                    width: parent.width
                    wrapMode: Text.WordWrap
                    color: Constants.colors.highlight
                }

                PLabel {
                    id: metadataLabel
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: 20 * pgst.scalef
                    color: Constants.colors.placeholder
                }

                PExpander {
                    visible: detailPage.chapters.length > 0

                    width: parent.width
                    expandedHeight: chaptersColumn.childrenRect.height

                    Column {
                        id: chaptersColumn
                        width: parent.width

                        PLabel {
                            text: 'Chapters'
                            color: Constants.colors.secondaryHighlight
                        }

                        Repeater {
                            model: detailPage.chapters

                            delegate: Column {
                                width: parent.width

                                PLabel {
                                    width: parent.width
                                    text: Util.formatDuration(modelData.start)
                                    font.pixelSize: 20 * pgst.scalef
                                    color: Constants.colors.secondaryHighlight
                                }

                                PLabel {
                                    width: parent.width
                                    text: modelData.title
                                    font.pixelSize: 20 * pgst.scalef
                                    color: Constants.colors.placeholder
                                }
                            }
                        }
                    }
                }

                PLabel {
                    id: descriptionLabel
                    width: parent.width
                    font.pixelSize: 30 * pgst.scalef
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    PScrollDecorator { flickable: flickable }
}

