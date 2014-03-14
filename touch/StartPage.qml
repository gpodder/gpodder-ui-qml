
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

import 'icons/icons.js' as Icons
import 'common/constants.js' as Constants
import 'common/util.js' as Util

SlidePage {
    id: startPage
    canClose: false

    function update_stats() {
        py.call('main.get_stats', [], function (result) {
            stats.text = Util.format(
                '{podcasts} podcasts\n' +
                '{episodes} episodes\n' +
                '{newEpisodes} new episodes\n' +
                '{downloaded} downloaded',
                result);
        });

        py.call('main.get_fresh_episodes_summary', [3], function (episodes) {
            freshEpisodesRepeater.model = episodes;
        });
    }

    Item {
        Connections {
            target: py
            onUpdateStats: startPage.update_stats();
        }
    }

    Flickable {
        id: flickable
        boundsBehavior: Flickable.StopAtBounds

        Connections {
            target: py
            onReadyChanged: {
                if (py.ready) {
                    startPage.update_stats();
                }
            }
        }

        anchors.fill: parent

        contentWidth: startPageColumn.width
        contentHeight: startPageColumn.height + startPageColumn.spacing

        Column {
            id: startPageColumn

            width: startPage.width
            spacing: 20 * pgst.scalef

            SlidePageHeader {
                title: 'gPodder'
            }

            StartPageButton {
                id: subscriptionsPane

                title: 'Subscriptions'
                onClicked: pgst.loadPage('PodcastsPage.qml');

                PLabel {
                    id: stats

                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        margins: 20 * pgst.scalef
                    }
                }

                ButtonArea {
                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                    }

                    transparent: true
                    onClicked: pgst.loadPage('Subscribe.qml');
                    width: subscriptions.width + 2*subscriptions.anchors.margins
                    height: subscriptions.height + 2*subscriptions.anchors.margins

                    PIcon {
                        id: subscriptions
                        icon: Icons.plus
                        color: Constants.colors.download

                        anchors {
                            bottom: parent.bottom
                            right: parent.right
                            margins: 20 * pgst.scalef
                        }
                    }
                }
            }

            StartPageButton {
                id: freshEpisodes
                enabled: freshEpisodesRepeater.count > 0

                title: py.refreshing ? 'Refreshing feeds' : 'Fresh episodes'
                onClicked: pgst.loadPage('FreshEpisodes.qml');

                Row {
                    id: freshEpisodesRow

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20 * pgst.scalef
                    anchors.leftMargin: 20 * pgst.scalef
                    anchors.left: parent.left
                    spacing: 10 * pgst.scalef

                    PLabel {
                        color: Constants.colors.placeholder
                        text: 'No fresh episodes'
                        visible: freshEpisodesRepeater.count == 0
                    }

                    Repeater {
                        id: freshEpisodesRepeater

                        CoverArt {
                            source: modelData.coverart
                            text: modelData.title

                            width: 80 * pgst.scalef
                            height: 80 * pgst.scalef
                        }
                    }
                }

                ButtonArea {
                    id: refresherButtonArea
                    visible: !py.refreshing

                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                    }

                    transparent: true
                    onClicked: py.call('main.check_for_episodes');
                    width: refresher.width + 2*refresher.anchors.margins
                    height: refresher.height + 2*refresher.anchors.margins

                    PIcon {
                        id: refresher
                        icon: Icons.loop_alt2
                        color: Constants.colors.highlight

                        anchors {
                            bottom: parent.bottom
                            right: parent.right
                            margins: 20 * pgst.scalef
                        }
                    }
                }
            }

            ButtonArea {
                onClicked: pgst.loadPage('PlayerPage.qml');

                anchors {
                    left: freshEpisodes.left
                    right: freshEpisodes.right
                }

                height: 100 * pgst.scalef

                PLabel {
                    anchors.centerIn: parent
                    text: 'Now playing'
                }
            }

            ButtonArea {
                onClicked: pgst.loadPage('Directory.qml');

                anchors {
                    left: freshEpisodes.left
                    right: freshEpisodes.right
                }

                height: 100 * pgst.scalef

                PLabel {
                    anchors.centerIn: parent
                    text: 'gpodder.net'
                }
            }
        }
    }

    PScrollDecorator { flickable: flickable }
}

