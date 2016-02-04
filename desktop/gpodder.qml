import QtQuick 2.3
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2

import 'dialogs'

import 'common'
import 'common/util.js' as Util
import 'common/constants.js' as Constants

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

        ColumnLayout {
            TableView {
                Layout.fillHeight: true
                Layout.fillWidth: true

                id: podcastListView

                model: GPodderPodcastListModel { id: podcastListModel }
                GPodderPodcastListModelConnections {}
                headerVisible: false
                alternatingRowColors: false
                horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff

                Menu {
                    id: podcastContextMenu

                    MenuItem {
                        text: 'Unsubscribe'
                        onTriggered: {
                            var podcast_id = podcastListModel.get(podcastListView.currentRow).id;
                            py.call('main.unsubscribe', [podcast_id]);
                        }
                    }

                    MenuItem {
                        text: 'Mark episodes as old'
                        onTriggered: {
                            var podcast_id = podcastListModel.get(podcastListView.currentRow).id;
                            py.call('main.mark_episodes_as_old', [podcast_id]);
                        }
                    }
                }

                rowDelegate: Rectangle {
                    height: 40
                    color: styleData.selected ? Constants.colors.select : 'transparent'

                    MouseArea {
                        acceptedButtons: Qt.RightButton
                        anchors.fill: parent
                        onClicked: podcastContextMenu.popup()
                    }
                }

                TableViewColumn {
                    id: coverartColumn
                    width: 40

                    role: 'coverart'
                    title: 'Image'
                    delegate: Item {
                        height: 32
                        width: 32
                        Image {
                            mipmap: true
                            source: styleData.value
                            width: 32
                            height: 32
                            anchors.centerIn: parent
                        }
                    }
                }

                TableViewColumn {
                    role: 'title'
                    title: 'Podcast'
                    width: podcastListView.width - coverartColumn.width - indicatorColumn.width - 2 * 5

                    delegate: Item {
                        property var row: podcastListModel.get(styleData.row)

                        width: parent.width
                        height: 40

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: -5

                            Text {
                                width: parent.width
                                color: styleData.selected ? 'white' : 'black'

                                font.bold: row.newEpisodes
                                text: styleData.value
                                elide: styleData.elideMode
                            }

                            Text {
                                width: parent.width
                                font.pointSize: 10
                                color: styleData.selected ? 'white' : 'black'

                                text: row.description
                                elide: styleData.elideMode
                            }
                        }
                    }
                }

                TableViewColumn {
                    id: indicatorColumn
                    width: 50

                    role: 'indicator'
                    title: 'Indicator'

                    delegate: Item {
                        height: 32
                        width: 50
                        property var row: podcastListModel.get(styleData.row)

                        Rectangle {
                            anchors.centerIn: parent
                            visible: row.updating

                            color: styleData.selected ? '#ffffff' : '#000000'

                            property real phase: 0

                            width: 15 + 3 * Math.sin(phase)
                            height: width

                            PropertyAnimation on phase {
                                loops: Animation.Infinite
                                duration: 2000
                                running: parent.visible
                                from: 0
                                to: 2*Math.PI
                            }
                        }

                        Pill {
                            anchors.centerIn: parent

                            visible: !row.updating

                            leftCount: row.unplayed
                            rightCount: row.downloaded
                        }
                    }
                }

                onCurrentRowChanged: {
                    var id = podcastListModel.get(currentRow).id;
                    episodeListModel.loadEpisodes(id);
                }
            }


            Button {
                Layout.fillWidth: true
                Layout.margins: 3
                text: 'Check for new episodes'
                onClicked: py.call('main.check_for_episodes');
                enabled: !py.refreshing
            }
        }

        SplitView {
            orientation: Orientation.Vertical

            TableView {
                id: episodeListView

                Layout.fillWidth: true
                model: GPodderEpisodeListModel { id: episodeListModel }
                GPodderEpisodeListModelConnections {}
                selectionMode: SelectionMode.MultiSelection

                function forEachSelectedEpisode(callback) {
                    episodeListView.selection.forEach(function(rowIndex) {
                        var episode_id = episodeListModel.get(rowIndex).id;
                        callback(episode_id);
                    });
                }

                Menu {
                    id: episodeContextMenu

                    MenuItem {
                        text: 'Toggle new'
                        onTriggered: {
                            episodeListView.forEachSelectedEpisode(function (episode_id) {
                                py.call('main.toggle_new', [episode_id]);
                            });
                        }
                    }

                    MenuItem {
                        text: 'Download'
                        onTriggered: {
                            episodeListView.forEachSelectedEpisode(function (episode_id) {
                                py.call('main.download_episode', [episode_id]);
                            });
                        }
                    }

                    MenuItem {
                        text: 'Delete'
                        onTriggered: {
                            episodeListView.forEachSelectedEpisode(function (episode_id) {
                                py.call('main.delete_episode', [episode_id]);
                            });
                        }
                    }
                }

                rowDelegate: Rectangle {
                    height: 40
                    color: styleData.selected ? Constants.colors.select : 'transparent'

                    MouseArea {
                        acceptedButtons: Qt.RightButton
                        anchors.fill: parent
                        onClicked: episodeContextMenu.popup()
                    }
                }

                TableViewColumn {
                    role: 'title'
                    title: 'Episode'

                    delegate: Row {
                        property var row: episodeListModel.get(styleData.row)
                        height: 32

                        Item {
                            width: 32
                            height: 32

                            Rectangle {
                                anchors.centerIn: parent
                                width: 10
                                height: 10
                                color: episodeTitle.color
                            }

                            anchors.verticalCenter: parent.verticalCenter
                            opacity: row.downloadState === Constants.state.downloaded
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: -5

                            Text {
                                id: episodeTitle
                                text: styleData.value
                                elide: styleData.elideMode
                                color: styleData.selected ? 'white' : 'black'
                                font.bold: row.isNew
                            }

                            Text {
                                text: row.progress ? ('Downloading: ' + parseInt(100*row.progress) + '%') : row.subtitle
                                elide: styleData.elideMode
                                color: styleData.selected ? 'white' : 'black'
                            }
                        }
                    }
                }

                onActivated: {
                    var episode_id = episodeListModel.get(currentRow).id;

                    openDialog('dialogs/EpisodeDetailsDialog.qml', function (dialog) {
                        py.call('main.show_episode', [episode_id], function (episode) {
                            dialog.episode = episode;
                        });
                    });
                }
            }

            Label {
            }
        }
    }
}
