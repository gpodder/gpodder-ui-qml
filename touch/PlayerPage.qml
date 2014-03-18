
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

import 'common/util.js' as Util
import 'common/constants.js' as Constants
import 'icons/icons.js' as Icons

Dialog {
    id: playerPage

    contentHeight: flickable.contentHeight
    fullWidth: true

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
                    onClicked: player.seekAndSync(player.position - 60 * 1000);
                }

                IconMenuItem {
                    text: '-10s'
                    color: Constants.colors.playback
                    icon: Icons.arrow_left
                    onClicked: player.seekAndSync(player.position - 10 * 1000);
                }

                IconMenuItem {
                    text: '+10s'
                    color: Constants.colors.playback
                    icon: Icons.arrow_right
                    onClicked: player.seekAndSync(player.position + 10 * 1000);
                }

                IconMenuItem {
                    text: '+1m'
                    color: Constants.colors.playback
                    icon: Icons.last
                    onClicked: player.seekAndSync(player.position + 60 * 1000);
                }
            }
        }
    }

    PScrollDecorator { flickable: flickable }
}
