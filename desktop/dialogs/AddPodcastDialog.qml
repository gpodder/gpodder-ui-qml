import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2

import '../common'
import '../common/util.js' as Util

Dialog {
    signal addUrl(string url)

    width: 300
    height: 100
    title: 'Add new podcast'
    standardButtons: StandardButton.Open | StandardButton.Cancel

    RowLayout {
        anchors.fill: parent

        Label {
            text: 'URL:'
        }

        TextField {
            id: urlEntry
            focus: true

            Layout.fillWidth: true
        }
    }

    onAccepted: {
        addUrl(urlEntry.text);
        visible = false;
    }
}
