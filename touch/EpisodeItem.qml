
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

Item {
    id: episodeItem
    property bool opened: episodeList.selectedIndex == index
    property bool isPlaying: ((player.episode == id) && player.isPlaying)

    width: parent.width
    height: (opened ? 160 : 80) * pgst.scalef
    Behavior on height { PropertyAnimation { duration: 100 } }

    Rectangle {
        clip: true
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: parent.height - 80 * pgst.scalef
        color: '#66000000'

        IconContextMenu {
            height: parent.height
            width: parent.width

            IconMenuItem {
                text: 'Play'
                iconSource: 'icons/' + (episodeItem.isPlaying ? 'pause_24x32.png' : 'play_24x32.png')
                onClicked: {
                    if (episodeItem.isPlaying) {
                        player.pause();
                    } else {
                        player.playbackEpisode(id);
                    }
                }
            }

            IconMenuItem {
                text: 'Download'
                iconSource: 'icons/cloud_download_32x32.png'
                visible: downloadState != Constants.state.downloaded
                onClicked: {
                    episodeList.selectedIndex = -1;
                    py.call('main.download_episode', [id]);
                }
            }

            IconMenuItem {
                text: 'Delete'
                iconSource: 'icons/trash_stroke_32x32.png'
                visible: downloadState != Constants.state.deleted
                onClicked: py.call('main.delete_episode', [id]);
            }

            IconMenuItem {
                text: 'Toggle New'
                iconSource: 'icons/star_32x32.png'
                onClicked: py.call('main.toggle_new', [id]);
            }

            IconMenuItem {
                text: 'Shownotes'
                iconSource: 'icons/document_alt_stroke_24x32.png'
                onClicked: pgst.loadPage('EpisodeDetail.qml', {episode_id: id, title: title});
            }
        }
    }

    ButtonArea {
        id: episodeItemArea

        onClicked: {
            if (episodeList.selectedIndex == index) {
                episodeList.selectedIndex = -1;
            } else {
                episodeList.selectedIndex = index;
            }
        }

        Rectangle {
            anchors.fill: parent
            color: '#ffffff'
            visible: (progress > 0) || isPlaying
            opacity: 0.1
        }

        Rectangle {
            anchors {
                top: parent.top
                left: parent.left
            }

            height: parent.height * .2
            width: parent.width * progress
            color: Constants.colors.download
            opacity: .4
        }

        Rectangle {
            anchors {
                bottom: parent.bottom
                left: parent.left
            }

            height: parent.height * .2
            width: parent.width * playbackProgress
            color: Constants.colors.playback
            opacity: episodeItem.isPlaying ? .6 : .2
        }

        transparent: true
        height: 80 * pgst.scalef

        anchors {
            left: parent.left
            right: parent.right
        }

        PLabel {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 30 * pgst.scalef
            }

            elide: Text.ElideRight
            text: title

            color: isNew ? Constants.colors.fresh : 'white'

            opacity: {
                switch (downloadState) {
                    case Constants.state.normal: return 0.8;
                    case Constants.state.downloaded: return 1;
                    case Constants.state.deleted: return 0.3;
                }
            }
        }
    }
}
