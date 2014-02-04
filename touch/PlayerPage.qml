
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

SlidePage {
    id: playerPage

    Flickable {
        id: flickable
        anchors.fill: parent

        contentWidth: column.width
        contentHeight: column.height + column.spacing

        Column {
            id: column

            width: playerPage.width
            spacing: 10 * pgst.scalef

            SlidePageHeader {
                title: 'Now playing'
            }

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: 30 * pgst.scalef
                }

                PLabel {
                    text: player.episode_title
                    elide: Text.ElideRight
                }

                PLabel {
                    text: player.podcast_title
                    elide: Text.ElideRight
                }
            }

            IconContextMenu {
                width: parent.width

                IconMenuItem {
                    text: player.isPlaying ? 'Pause' : 'Play'
                    iconSource: 'icons/' + (player.isPlaying ? 'pause_24x32.png' : 'play_24x32.png')
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
                    iconSource: 'icons/first_32x32.png'
                    onClicked: player.seekAndSync(player.position - 60 * 1000);
                }

                IconMenuItem {
                    text: '-10s'
                    iconSource: 'icons/arrow_left_32x32.png'
                    onClicked: player.seekAndSync(player.position - 10 * 1000);
                }

                IconMenuItem {
                    text: '+10s'
                    iconSource: 'icons/arrow_right_32x32.png'
                    onClicked: player.seekAndSync(player.position + 10 * 1000);
                }

                IconMenuItem {
                    text: '+1m'
                    iconSource: 'icons/last_32x32.png'
                    onClicked: player.seekAndSync(player.position + 60 * 1000);
                }
            }

            PLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Util.formatPosition(slider.displayedValue/1000, player.duration/1000)
            }

            PSlider {
                id: slider
                width: playerPage.width
                value: player.position
                min: 0
                max: player.duration
                onValueChangeRequested: {
                    player.seekAndSync(newValue);
                }
            }
        }
    }
}
