import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2

import 'dialogs'

import 'common'
import 'common/util.js' as Util

ApplicationWindow {
    id: appWindow

    width: 500
    height: 400

    title: 'gPodder'

    GPodderCore {
        id: py
    }

    function openDialog(filename, callback) {
        var component = Qt.createComponent(filename);

        function createDialog() {
            if (component.status === Component.Ready) {
                var dialog = component.createObject(appWindow, {});
                dialog.visible = true;
                callback(dialog);
            }
        }

        if (component.status == Component.Ready) {
            createDialog();
        } else {
            component.statusChanged.connect(createDialog);
        }
    }

    menuBar: MenuBar {
        Menu {
            title: 'File'

            MenuItem {
                text: 'Add podcast'
                onTriggered: {
                    openDialog('dialogs/AddPodcastDialog.qml', function (dialog) {
                        dialog.addUrl.connect(function (url) {
                            py.call('main.subscribe', [url]);
                        });
                    });
                }
            }

            MenuItem {
                text: 'Quit'
                onTriggered: Qt.quit()
            }
        }
    }

    SplitView {
        anchors.fill: parent

        TableView {
            id: podcastListView

            width: 200
            model: GPodderPodcastListModel { id: podcastListModel }
            GPodderPodcastListModelConnections {}
            headerVisible: false
            alternatingRowColors: false

            Menu {
                id: podcastContextMenu
                MenuItem {
                    text: 'Unsubscribe'
                    onTriggered: {
                        var podcast_id = podcastListModel.get(podcastListView.currentRow).id;
                        py.call('main.unsubscribe', [podcast_id]);
                    }
                }
            }

            rowDelegate: Rectangle {
                height: 40
                color: styleData.selected ? '#eee' : '#fff'

                MouseArea {
                    acceptedButtons: Qt.RightButton
                    anchors.fill: parent
                    onClicked: podcastContextMenu.popup()
                }
            }

            TableViewColumn {
                role: 'coverart'
                title: 'Image'
                delegate: Item {
                    height: 32
                    width: 32
                    Image {
                        source: styleData.value
                        width: 32
                        height: 32
                        anchors.centerIn: parent
                    }
                }

                width: 40
            }

            TableViewColumn {
                role: 'title'
                title: 'Podcast'
                delegate: Item {
                    height: 40
                    Text {
                        text: styleData.value
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            onCurrentRowChanged: {
                var id = podcastListModel.get(currentRow).id;
                episodeListModel.loadEpisodes(id);
            }
        }

        TableView {
            Layout.fillWidth: true
            model: GPodderEpisodeListModel { id: episodeListModel }
            GPodderEpisodeListModelConnections {}

            TableViewColumn { role: 'title'; title: 'Title' }

            onActivated: {
                var episode_id = episodeListModel.get(currentRow).id;

                openDialog('dialogs/EpisodeDetailsDialog.qml', function (dialog) {
                    py.call('main.show_episode', [episode_id], function (episode) {
                        dialog.episode = episode;
                    });
                });
            }
        }
    }
}
