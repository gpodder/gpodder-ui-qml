import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2

import '../common'
import '../common/util.js' as Util

Rectangle {
    property var episode
    color: '#aa000000'

    anchors.fill: parent

    MouseArea {
        anchors.fill: parent
        onClicked: parent.destroy();
    }

    TextArea {
        anchors.fill: parent
        anchors.margins: 50
        readOnly: true
        text: episode ? episode.description : '...'
    }
}
