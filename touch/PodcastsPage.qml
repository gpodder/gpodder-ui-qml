
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
import 'icons/icons.js' as Icons
import 'common/constants.js' as Constants

SlidePage {
    id: page

    canClose: false

    hasMenuButton: true
    menuButtonLabel: 'Settings'
    onMenuButtonClicked: {
        pgst.showSelection([
            {
                label: 'Check for new episodes',
                callback: function () {
                    py.call('main.check_for_episodes');
                }
            },
            {
                label: 'Filter episodes',
                callback: function () {
                    pgst.loadPage('EpisodeQueryPage.qml');
                }
            },
            {
                label: 'Settings',
                callback: function () {
                    pgst.loadPage('SettingsPage.qml');
                },
            },
            {
                label: 'Add new podcast',
                callback: function () {
                    var ctx = { py: py };
                    pgst.loadPage('TextInputDialog.qml', {
                        buttonText: 'Subscribe',
                        placeholderText: 'Feed URL',
                        pasteOnLoad: true,
                        callback: function (url) {
                            ctx.py.call('main.subscribe', [url]);
                        }
                    });
                },
            },
            {
                label: 'Discover new podcasts',
                callback: function () {
                    py.call('main.get_directory_providers', [], function (result) {
                        var items = [];
                        for (var i=0; i<result.length; i++) {
                            (function (provider) {
                                items.push({
                                    label: provider.label,
                                    callback: function () {
                                        pgst.loadPage('Directory.qml', {
                                            provider: provider.label,
                                            can_search: provider.can_search,
                                        });
                                    },
                                });
                            })(result[i]);
                        }
                        pgst.showSelection(items, 'Select provider');
                    });
                },
            },
        ], undefined, undefined, true);
    }

    PListView {
        id: podcastList
        title: 'Subscriptions'

        section.property: 'section'
        section.delegate: SectionHeader { text: section }

        PPlaceholder {
            text: 'No podcasts'
            visible: podcastList.count === 0
        }

        model: podcastListModel

        delegate: PodcastItem {
            onClicked: pgst.loadPage('EpisodesPage.qml', {'podcast_id': id, 'title': title});
            onPressAndHold: {
                pgst.showSelection([
                    {
                        label: 'Refresh',
                        callback: function () {
                            py.call('main.check_for_episodes', [url]);
                        },
                    },
                    {
                        label: 'Unsubscribe',
                        callback: function () {
                            var ctx = { py: py, id: id };
                            pgst.showConfirmation(title, 'Unsubscribe', 'Cancel', 'Remove this podcast and all downloaded episodes?', Icons.trash, function () {
                                ctx.py.call('main.unsubscribe', [ctx.id]);
                            });
                        },
                    },
                    {
                        label: 'Rename',
                        callback: function () {
                            var ctx = { py: py, id: id };
                            pgst.loadPage('TextInputDialog.qml', {
                                buttonText: 'Rename',
                                placeholderText: 'New name',
                                text: title,
                                callback: function (new_title) {
                                    ctx.py.call('main.rename_podcast', [ctx.id, new_title]);
                                }
                            });
                        }
                    },
                    {
                        label: 'Mark episodes as old',
                        callback: function () {
                            py.call('main.mark_episodes_as_old', [id]);
                        },
                    },
                    {
                        label: 'Podcast details',
                        callback: function () {
                            pgst.loadPage('PodcastDetail.qml', {podcast_id: id, title: title});
                        }
                    },
                ], title);
            }
        }
    }
}
