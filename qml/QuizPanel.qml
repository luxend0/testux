pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// "Which Linux suits you?": three questions, three suggestions. Answers are kept, so the
// suggestions are still there next time.
Panel {
    id: panel

    signal distroSelected(string id)

    readonly property bool answered: answers.purpose !== "" && answers.look !== "" && answers.tinker !== ""
    readonly property var picks: answered && Catalog.distros.length > 0
                                 ? Catalog.recommend(answers.purpose, answers.look, answers.tinker) : []

    readonly property list<var> questions: [
        {
            key: "purpose",
            text: qsTr("What do you mostly use your PC for?"),
            options: [
                { value: "everyday", label: qsTr("Everyday & office") },
                { value: "gaming", label: qsTr("Gaming") },
                { value: "creative", label: qsTr("Creative work & coding") },
                { value: "oldpc", label: qsTr("Older or slow PC") }
            ]
        },
        {
            key: "look",
            text: qsTr("How should it look?"),
            options: [
                { value: "windows", label: qsTr("Like Windows") },
                { value: "mac", label: qsTr("Like macOS") },
                { value: "modern", label: qsTr("Doesn't matter, modern") }
            ]
        },
        {
            key: "tinker",
            text: qsTr("How much do you want to tinker?"),
            options: [
                { value: "none", label: qsTr("Not at all") },
                { value: "some", label: qsTr("A little") },
                { value: "lots", label: qsTr("I love it") }
            ]
        }
    ]

    Settings {
        id: answers
        category: "quiz"

        property string purpose
        property string look
        property string tinker
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        spacing: Theme.gapL

        RowLayout {
            spacing: Theme.gapM
            Layout.fillWidth: true

            ColumnLayout {
                spacing: Theme.gapXs
                Layout.fillWidth: true

                Heading {
                    text: qsTr("Which Linux suits you?")
                    Layout.fillWidth: true
                }

                BodyText {
                    text: panel.answered
                          ? qsTr("Based on your answers, these three are a good start.")
                          : qsTr("Answer three quick questions and Testux suggests three distros to try.")
                    muted: true
                    Layout.fillWidth: true
                }
            }

            AppButton {
                kind: "quiet"
                visible: answers.purpose !== "" || answers.look !== "" || answers.tinker !== ""
                text: qsTr("Start over")
                onClicked: {
                    answers.purpose = ""
                    answers.look = ""
                    answers.tinker = ""
                }
                Layout.alignment: Qt.AlignTop
            }
        }

        Repeater {
            model: panel.questions

            ColumnLayout {
                id: question

                required property var modelData
                required property int index

                // One question at a time until all are answered, then all stay editable.
                visible: panel.answered || index === 0 || answers[panel.questions[index - 1].key] !== ""
                spacing: Theme.gapS
                Layout.fillWidth: true

                Label {
                    text: (question.index + 1) + ". " + question.modelData.text
                    font.weight: Font.DemiBold
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }

                SegmentedControl {
                    options: question.modelData.options
                    current: answers[question.modelData.key]
                    onPicked: value => answers[question.modelData.key] = value
                }
            }
        }

        GridLayout {
            id: results

            // From the column, not from itself: the cards' widths would feed back into it.
            readonly property real cardWidth: (content.width - (columns - 1) * columnSpacing) / columns

            visible: panel.picks.length > 0
            columns: Math.max(1, Math.min(3, Math.floor((content.width + columnSpacing) / (240 + columnSpacing))))
            columnSpacing: Theme.gapL
            rowSpacing: Theme.gapL
            Layout.fillWidth: true
            Layout.topMargin: Theme.gapS

            Repeater {
                model: panel.picks

                DistroCard {
                    required property var modelData

                    distro: modelData.distro
                    reason: modelData.reason
                    onClicked: panel.distroSelected(modelData.distro.id)
                    Layout.preferredWidth: results.cardWidth
                    Layout.fillHeight: true
                }
            }
        }
    }
}
