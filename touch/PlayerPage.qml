
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

SlidePage {
    id: page

    Component.onCompleted: pgst.havePlayer = true;
    Component.onDestruction: pgst.havePlayer = false;

    Flickable {
        id: flickable
        anchors.fill: parent
        boundsBehavior: Flickable.StopAtBounds

        contentWidth: column.width
        contentHeight: column.height + column.spacing

        Column {
            id: column

            width: flickable.width
            spacing: 10 * pgst.scalef

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: 30 * pgst.scalef
                }

                SlidePageHeader {
                    title: 'Now playing'
                    width: parent.width
                }

                Item { width: parent.width; height: 20 * pgst.scalef }

                PLabel {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    text: player.episode_title
                    elide: Text.ElideRight
                    color: Constants.colors.dialogText
                }

                PLabel {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    text: player.podcast_title
                    elide: Text.ElideRight
                    color: Constants.colors.dialogText
                }
            }

            PLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Util.formatPosition(slider.displayedValue/1000, player.duration/1000)
                color: Constants.colors.dialogText
            }

            PSlider {
                id: slider
                width: flickable.width
                value: player.position
                min: 0
                max: player.duration
                color: Constants.colors.playback
                onValueChangeRequested: {
                    player.seekAndSync(newValue);
                }
            }

            IconContextMenu {
                width: parent.width

                IconMenuItem {
                    text: player.isPlaying ? 'Pause' : 'Play'
                    color: Constants.colors.playback
                    icon: player.isPlaying ? Icons.pause : Icons.play
                    onClicked: {
                        if (player.isPlaying) {
                            player.pause();
                        } else {
                            player.play();
                        }
                    }
                }

                IconMenuItem {
                    text: '-1m'
                    color: Constants.colors.playback
                    icon: Icons.first
                    GPodderAutoFire {
                        running: parent.pressed
                        onFired: player.seekAndSync(player.position - 60 * 1000)
                    }
                }

                IconMenuItem {
                    text: '-10s'
                    color: Constants.colors.playback
                    icon: Icons.arrow_left
                    GPodderAutoFire {
                        running: parent.pressed
                        onFired: player.seekAndSync(player.position - 10 * 1000)
                    }
                }

                IconMenuItem {
                    text: '+10s'
                    color: Constants.colors.playback
                    icon: Icons.arrow_right
                    GPodderAutoFire {
                        running: parent.pressed
                        onFired: player.seekAndSync(player.position + 10 * 1000)
                    }
                }

                IconMenuItem {
                    text: '+1m'
                    color: Constants.colors.playback
                    icon: Icons.last
                    GPodderAutoFire {
                        running: parent.pressed
                        onFired: player.seekAndSync(player.position + 60 * 1000)
                    }
                }

                IconMenuItem {
                    text: player.sleepTimerRunning ? Util.formatDuration(player.sleepTimerRemaining) : 'Sleep'
                    alwaysShowText: player.sleepTimerRunning
                    color: Constants.colors.playback
                    icon: Icons.sleep
                    onClicked: {
                        if (player.sleepTimerRunning) {
                            player.stopSleepTimer();
                        } else {
                            var options = [];
                            var durations_minutes = player.durationChoices;
                            for (var i=0; i<durations_minutes.length; i++) {
                                (function (minutes) {
                                    options.push({
                                        label: '' + minutes + ' minutes',
                                        callback: function () {
                                            player.startSleepTimer(60 * minutes);
                                        }
                                    });
                                })(durations_minutes[i]);
                            }
                            pgst.showSelection(options, 'Sleep timer', undefined, false);
                        }
                    }
                }

                IconMenuItem {
                    text: 'Chapters'
                    color: Constants.colors.playback
                    icon: Icons.tag_fill
                    visible: player.episode_chapters.length > 0
                    onClicked: {
                        var items = [];

                        for (var i in player.episode_chapters) {
                            (function (items, chapter) {
                                items.push({
                                    label: chapter.title + ' (' + Util.formatDuration(chapter.start) + ')',
                                    callback: function () {
                                        player.seekAndSync(chapter.start * 1000);
                                    }
                                });
                            })(items, player.episode_chapters[i]);
                        }

                        pgst.showSelection(items, 'Chapters');
                    }
                }
            }

            SectionHeader {
                text: 'Play queue'
                visible: playQueueRepeater.count > 0
                width: parent.width
            }

            Repeater {
                id: playQueueRepeater
                model: player.queue

                property var queueConnections: Connections {
                    target: player

                    onQueueUpdated: {
                        playQueueRepeater.model = player.queue;
                    }
                }

                ButtonArea {
                    height: Constants.layout.item.height * pgst.scalef
                    width: parent.width
                    transparent: true

                    PLabel {
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: Constants.layout.padding * pgst.scalef
                            verticalCenter: parent.verticalCenter
                        }

                        text: modelData.title
                        elide: Text.ElideRight
                    }

                    onClicked: {
                        player.jumpToQueueIndex(index);
                    }

                    onPressAndHold: {
                        pgst.showSelection([
                            {
                                label: 'Shownotes',
                                callback: function () {
                                    pgst.loadPage('EpisodeDetail.qml', {
                                        episode_id: modelData.episode_id,
                                        title: modelData.title
                                    });
                                },
                            },
                            {
                                label: 'Remove from queue',
                                callback: function () {
                                    player.removeQueueIndex(index);
                                },
                            },
                        ]);
                    }
                }
            }
        }
    }

    PScrollDecorator { flickable: flickable }
}
