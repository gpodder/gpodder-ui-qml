
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2015, Thomas Perl <m@thp.io>
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

SlidePage {
    id: page

    Component.onCompleted: {
        py.getConfig('plugins.youtube.api_key_v3', function (value) {
            youtube_api_key_v3.text = value;
        });
        py.getConfig('limit.episodes', function (value) {
            limit_episodes.value = value;
        });
    }

    Component.onDestruction: {
        py.setConfig('plugins.youtube.api_key_v3', youtube_api_key_v3.text);
        py.setConfig('limit.episodes', parseInt(limit_episodes.value));
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
            spacing: 15 * pgst.scalef

            SlidePageHeader { title: 'Settings' }

            SectionHeader { text: 'YouTube' }

            SettingsLabel { text: 'API Key (v3)' }

            PTextField {
                id: youtube_api_key_v3
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Constants.layout.padding * pgst.scalef
                }
            }

            SectionHeader { text: 'Limits' }

            SettingsLabel { text: 'Maximum episodes per feed' }

            PSlider {
                id: limit_episodes
                min: 100
                step: 100
                max: 1000
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Constants.layout.padding * pgst.scalef
                }
                onValueChangeRequested: { value = newValue; }
            }

            PLabel {
                text: parseInt(limit_episodes.displayedValue)
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Constants.layout.padding * pgst.scalef
                }
            }

            SectionHeader { text: 'About' }

            ButtonArea {
                width: parent.width
                height: Constants.layout.item.height * pgst.scalef
                PLabel {
                    anchors.centerIn: parent
                    text: 'About gPodder ' + py.uiversion
                }
                onClicked: pgst.loadPage('AboutPage.qml')
            }
        }
    }

    PScrollDecorator { flickable: flickable }
}

