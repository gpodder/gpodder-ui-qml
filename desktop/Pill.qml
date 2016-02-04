import QtQuick 2.0

Image {
    property int leftCount: 0
    property int rightCount: 0
    source: 'image://python/pill/' + leftCount + '/' + rightCount
    cache: true
}
