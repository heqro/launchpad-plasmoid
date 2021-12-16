import QtQuick 2.4

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Rectangle { // (CONCEPT) Fully-fledged Gnome-like design.

    height: parentHeight
//     border.color: Qt.rgba(theme.highlightColor.r,theme.highlightColor.g,theme.highlightColor.b, 1)
//     border.width: Math.floor(units.smallSpacing/2)
    color: "transparent"
    width: (t_metrics.width > 0) ? t_metrics.width + Math.ceil(units.largeSpacing * 2) : 0

    radius: 40

    Behavior on width { SmoothedAnimation {duration: 150; velocity: 200} } // setting both duration and velocity helps when the user cancels out his search and the greeting text is too long for the velocity to catch up in a good fashion.

    TextMetrics { // this elements allows us to read the width of the user's input text
        id: t_metrics
        text: (myText != "") ? myText : placeholderText
        font.pointSize: 20 // account for the arbitrary font size chosen in the parent object.
    }

    anchors {
        bottom: parent.top
    }

    Rectangle {
        id: searchIconContainer
        height: parentHeight
        width: parentHeight

//         border.color: Qt.rgba(theme.highlightColor.r,theme.highlightColor.g,theme.highlightColor.b, 1)
//         border.width: Math.floor(units.smallSpacing/2)
        color: "transparent"

        radius: width/2

        anchors {
            right: parent.left
//             rightMargin: units.smallSpacing/2
        }

        PlasmaCore.IconItem { // category icon
            //id: categoryIconId
            //source: "plasma-search" // more detailed design. I dislike it a bit.
            source: "nepomuk" // symbolic-like. I enjoy much more this one than a detailed one.
            height: Math.floor(4 * parent.height / 5)
            width: Math.floor(4 * parent.height / 5)
            anchors.centerIn: parent
        }

    }

    Rectangle { // this is the real rectangle that draws the border around every element in the menu.
        z: -1
        height: parentHeight
        width: searchIconContainer.width + parent.width + units.smallSpacing/2
        border.color: Qt.rgba(theme.highlightColor.r,theme.highlightColor.g,theme.highlightColor.b, 1)
        border.width: Math.floor(units.smallSpacing/2)
        color: Qt.rgba(theme.backgroundColor.r, theme.backgroundColor.g, theme.backgroundColor.b, plasmoid.configuration.searchBarOpacity)
        radius: 40

        anchors {
            right: parent.right
        }
    }

}
