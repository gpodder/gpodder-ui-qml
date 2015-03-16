
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

Item {
    id: episodeItem
    property bool opened: episodeList.selectedIndex == index
    property bool isPlaying: ((player.episode == id) && player.isPlaying)

    width: parent.width
    height: (opened ? 2 : 1) * Constants.layout.item.height * pgst.scalef
    Behavior on height { PropertyAnimation { duration: 100 } }

    Item {
        clip: true
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: parent.height - 80 * pgst.scalef

        IconContextMenu {
            height: parent.height
            width: parent.width

            IconMenuItem {
                text: episodeItem.isPlaying ? 'Pause' : 'Play'
                color: (episodeItem.isPlaying || progress > 0) ? titleLabel.color : Constants.colors.playback
                icon: episodeItem.isPlaying ? Icons.pause : Icons.play
                onClicked: {
                    if (episodeItem.isPlaying) {
                        player.pause();
                    } else {
                        player.playbackEpisode(id);
                    }
                }

                onPressAndHold: {
                    player.enqueueEpisode(id, function () {
                        if (!player.isPlaying) {
                            player.jumpToQueueIndex(0);
                        }
                        pgst.loadPage('PlayerPage.qml');
                    });
                }
            }

            IconMenuItem {
                text: 'Download'
                color: (episodeItem.isPlaying || progress > 0) ? titleLabel.color : Constants.colors.download
                icon: Icons.cloud_download
                enabled: downloadState != Constants.state.downloaded
                onClicked: {
                    episodeList.selectedIndex = -1;
                    py.call('main.download_episode', [id]);
                }
            }

            IconMenuItem {
                text: 'Delete'
                color: (episodeItem.isPlaying || progress > 0) ? titleLabel.color : Constants.colors.destructive
                icon: Icons.trash
                enabled: downloadState != Constants.state.deleted
                onClicked: {
                    var ctx = { py: py, id: id };
                    pgst.showConfirmation(title, 'Delete', 'Cancel', 'Delete this episode?', Icons.trash, function () {
                        ctx.py.call('main.delete_episode', [ctx.id]);
                    });
                }
            }

            IconMenuItem {
                id: toggleNew
                color: (episodeItem.isPlaying || isNew || progress > 0) ? titleLabel.color : Constants.colors.text
                text: 'Toggle New'
                icon: Icons.star
                onClicked: Util.disableUntilReturn(toggleNew, py, 'main.toggle_new', [id]);
            }

            IconMenuItem {
                text: 'Shownotes'
                color: titleLabel.color
                icon: Icons.article
                onClicked: pgst.loadPage('EpisodeDetail.qml', {episode_id: id, title: title});
            }
        }
    }

    ButtonArea {
        id: episodeItemArea

        opacity: (canHighlight || episodeList.selectedIndex == index) ? 1 : 0.2
        canHighlight: (episodeList.selectedIndex == -1)

        onClicked: {
            if (episodeList.selectedIndex == index) {
                episodeList.selectedIndex = -1;
            } else if (episodeList.selectedIndex != -1) {
                episodeList.selectedIndex = -1;
            } else {
                episodeList.selectedIndex = index;
            }
        }

        Rectangle {
            anchors.fill: parent
            color: titleLabel.color
            visible: (progress > 0) || isPlaying || episodeItem.opened
            opacity: 0.1
        }

        Rectangle {
            anchors {
                top: parent.top
                left: parent.left
            }

            height: Constants.layout.padding * pgst.scalef
            width: parent.width * progress
            color: Constants.colors.download
        }

        Rectangle {
            anchors {
                bottom: parent.bottom
                left: parent.left
            }

            height: Constants.layout.padding * pgst.scalef
            width: parent.width * playbackProgress
            color: titleLabel.color
            opacity: episodeItem.isPlaying ? 1 : .2
        }

        transparent: true
        height: Constants.layout.item.height * pgst.scalef

        anchors {
            left: parent.left
            right: parent.right
        }

        RectangleIndicator {
            id: downloadIndicator
            enabled: downloadState == Constants.state.downloaded
            color: titleLabel.color
        }

        Column {
            anchors {
                left: parent.left
                leftMargin: Constants.layout.padding * pgst.scalef
                right: downloadIndicator.left
                rightMargin: Constants.layout.padding * pgst.scalef
                verticalCenter: parent.verticalCenter
            }

            PLabel {
                id: titleLabel

                anchors {
                    left: parent.left
                    right: parent.right
                }

                elide: Text.ElideRight
                text: title

                color: {
                    if (episodeItem.isPlaying) {
                        return Constants.colors.playback;
                    } else if (progress > 0) {
                        return Constants.colors.download;
                    } else if (episodeItem.opened) {
                        return Constants.colors.highlight;
                    } else if (isNew) {
                        return Constants.colors.fresh;
                    } else {
                        return Constants.colors.text;
                    }
                }

                opacity: {
                    if (downloadState == Constants.state.deleted && !isNew && progress <= 0) {
                        return 0.3;
                    } else {
                        return 1.0;
                    }
                }
            }

            PLabel {
                id: subtitleLabel

                anchors {
                    left: titleLabel.left
                    right: titleLabel.right
                }

                text: subtitle
                textFormat: Text.PlainText
                font.pixelSize: 20 * pgst.scalef

                visible: subtitle !== ''
                elide: Text.ElideRight
                opacity: titleLabel.opacity
            }
        }
    }
}
