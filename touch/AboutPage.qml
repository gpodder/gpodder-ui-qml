
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

SlidePage {
    id: page

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

            SlidePageHeader {
                title: 'About gPodder'
            }

            Column {
                width: parent.width

                Item { height: 10 * pgst.scalef; width: 1 }

                PLabel {
                    width: parent.width * .95
                    font.pixelSize: 30 * pgst.scalef
                    anchors.horizontalCenter: parent.horizontalCenter
                    wrapMode: Text.WordWrap
                    text: 'gPodder ' + py.uiversion
                    color: Constants.colors.highlight
                }

                PLabel {
                    width: parent.width * .95
                    font.pixelSize: 20 * pgst.scalef
                    anchors.horizontalCenter: parent.horizontalCenter
                    wrapMode: Text.WordWrap
                    text: 'http://gpodder.org/'
                    color: Constants.colors.placeholder
                }
            }

            PLabel {
                width: parent.width * .95
                font.pixelSize: 30 * pgst.scalef
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                text: [
                    '© 2005-2015 Thomas Perl and the gPodder Team',
                    'License: ISC / GPLv3 or later',
                    'Website: http://gpodder.org/',
                    '',
                    'gPodder Core ' + py.coreversion,
                    'gPodder QML UI ' + py.uiversion,
                    'Podcastparser ' + py.parserversion,
                    'PyOtherSide ' + py.pluginVersion(),
                    'Python ' + py.pythonVersion()
                ].join('\n')
            }
        }
    }

    PScrollDecorator { flickable: flickable }
}

