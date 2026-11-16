<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE TS>
<TS version="2.1" language="de" sourcelanguage="en">
<context>
    <name>BareMetal</name>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="55"/>
        <source>Checking your system</source>
        <translation>Dein System wird geprüft</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="57"/>
        <source>Making room on drive C:</source>
        <translation>Platz auf Laufwerk C: wird geschaffen</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="59"/>
        <source>Creating the Testux partition</source>
        <translation>Testux-Partition wird angelegt</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="61"/>
        <source>Copying the live system</source>
        <translation>Live-System wird kopiert</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="63"/>
        <source>Adjusting the boot configuration</source>
        <translation>Startkonfiguration wird angepasst</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="65"/>
        <source>Pausing BitLocker for one restart</source>
        <translation>BitLocker wird für einen Neustart pausiert</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="67"/>
        <source>Adding the boot entry</source>
        <translation>Starteintrag wird hinzugefügt</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="69"/>
        <source>Something went wrong, undoing all changes</source>
        <translation>Etwas ist schiefgelaufen, alle Änderungen werden rückgängig gemacht</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="71"/>
        <source>Removing the boot entry</source>
        <translation>Starteintrag wird entfernt</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="73"/>
        <source>Removing the Testux partition</source>
        <translation>Testux-Partition wird entfernt</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="75"/>
        <source>Giving the space back to Windows</source>
        <translation>Speicherplatz geht an Windows zurück</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="81"/>
        <source>The Testux boot entry was removed, but the Testux partition no longer looks the way Testux created it, so it was left untouched for safety. You can delete it yourself in Disk Management.</source>
        <translation>Der Testux-Starteintrag wurde entfernt. Die Testux-Partition sieht aber nicht mehr so aus, wie Testux sie angelegt hat, deshalb bleibt sie zur Sicherheit unangetastet. Du kannst sie selbst in der Datenträgerverwaltung löschen.</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="86"/>
        <source>Details: %1</source>
        <translation>Details: %1</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="123"/>
        <source>The ISO file is missing. Download it again.</source>
        <translation>Die ISO-Datei fehlt. Lade sie erneut herunter.</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="153"/>
        <source>Booting without a USB stick needs Windows on a UEFI PC.</source>
        <translation>Starten ohne USB-Stick braucht Windows auf einem UEFI-PC.</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="158"/>
        <source>%1 is missing. Please reinstall Testux.</source>
        <translation>%1 fehlt. Bitte installiere Testux neu.</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal.cpp" line="213"/>
        <source>The setup script stopped unexpectedly (exit code %1).</source>
        <translation>Das Einrichtungsskript wurde unerwartet beendet (Exitcode %1).</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal_stub.cpp" line="11"/>
        <source>Booting without a USB stick is only available on Windows.</source>
        <translation>Starten ohne USB-Stick gibt es nur unter Windows.</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal_win.cpp" line="110"/>
        <source>Testux needs administrator rights for this step and the request was declined.</source>
        <translation>Testux braucht für diesen Schritt Administratorrechte und die Anfrage wurde abgelehnt.</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal_win.cpp" line="113"/>
        <source>Could not start %1 (error %2).</source>
        <translation>%1 konnte nicht gestartet werden (Fehler %2).</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal_win.cpp" line="119"/>
        <source>%1 did not start.</source>
        <translation>%1 ist nicht gestartet.</translation>
    </message>
    <message>
        <location filename="../src/baremetal/baremetal_win.cpp" line="141"/>
        <source>Windows refused to restart. Please restart manually.</source>
        <translation>Windows hat den Neustart verweigert. Bitte starte selbst neu.</translation>
    </message>
</context>
<context>
    <name>BootPanel</name>
    <message>
        <source>Boot it on this PC</source>
        <translation type="vanished">Auf diesem PC starten</translation>
    </message>
    <message>
        <source>Starts %1 directly on your hardware, without a USB stick. It runs at full speed and you can install it from there. Windows stays and starts as usual afterwards.</source>
        <translation type="vanished">Startet %1 direkt auf deiner Hardware, ganz ohne USB-Stick. Es läuft mit voller Geschwindigkeit und du kannst es von dort aus installieren. Windows bleibt und startet danach wie gewohnt.</translation>
    </message>
    <message>
        <location filename="../qml/BootPanel.qml" line="29"/>
        <source>Next step: start it on this PC</source>
        <translation>Nächster Schritt: auf diesem PC starten</translation>
    </message>
    <message>
        <location filename="../qml/BootPanel.qml" line="34"/>
        <source>Liked it? Testux can start %1 directly on your PC, without a USB stick. It runs at full speed and you can install it from there. Windows stays and starts as usual afterwards. This step needs administrator rights.</source>
        <translation>Gefällt es dir? Testux kann %1 direkt auf deinem PC starten, ganz ohne USB-Stick. Es läuft mit voller Geschwindigkeit und du kannst es von dort aus installieren. Windows bleibt und startet danach wie gewohnt. Für diesen Schritt brauchst du Administratorrechte.</translation>
    </message>
    <message>
        <location filename="../qml/BootPanel.qml" line="42"/>
        <source>This works on Windows PCs for now.</source>
        <translation>Das geht vorerst nur auf Windows-PCs.</translation>
    </message>
    <message>
        <location filename="../qml/BootPanel.qml" line="60"/>
        <source>Checking your PC</source>
        <translation>Dein PC wird geprüft</translation>
    </message>
    <message>
        <location filename="../qml/BootPanel.qml" line="62"/>
        <source>This distro can only be tried in a window</source>
        <translation>Diese Distro kannst du nur im Fenster ausprobieren</translation>
    </message>
    <message>
        <location filename="../qml/BootPanel.qml" line="64"/>
        <source>Not ready yet, see what to change</source>
        <translation>Noch nicht bereit, sieh nach, was fehlt</translation>
    </message>
    <message>
        <location filename="../qml/BootPanel.qml" line="66"/>
        <source>Ready, with a few things to know</source>
        <translation>Bereit, mit ein paar Hinweisen</translation>
    </message>
    <message>
        <location filename="../qml/BootPanel.qml" line="67"/>
        <source>Your PC is ready</source>
        <translation>Dein PC ist bereit</translation>
    </message>
    <message>
        <location filename="../qml/BootPanel.qml" line="74"/>
        <source>Set it up</source>
        <translation>Einrichten</translation>
    </message>
    <message>
        <source>Set up boot</source>
        <translation type="vanished">Start einrichten</translation>
    </message>
</context>
<context>
    <name>BootWizard</name>
    <message>
        <location filename="../qml/BootWizard.qml" line="45"/>
        <source>Back to %1</source>
        <translation>Zurück zu %1</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="53"/>
        <source>Boot %1 on this PC</source>
        <translation>%1 auf diesem PC starten</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="54"/>
        <source>Your PC starts %1 once, straight from the hard drive. No USB stick needed.</source>
        <translation>Dein PC startet %1 einmal direkt von der Festplatte. Kein USB-Stick nötig.</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="58"/>
        <source>Check</source>
        <translation>Prüfen</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="58"/>
        <source>Space</source>
        <translation>Platz</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="58"/>
        <source>Confirm</source>
        <translation>Bestätigen</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="58"/>
        <source>Prepare</source>
        <translation>Vorbereiten</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="58"/>
        <source>Restart</source>
        <translation>Neustart</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="77"/>
        <source>Back</source>
        <translation>Zurück</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="89"/>
        <source>Next</source>
        <translation>Weiter</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="97"/>
        <source>Prepare boot</source>
        <translation>Start vorbereiten</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="110"/>
        <source>Is this PC ready?</source>
        <translation>Ist dieser PC bereit?</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="125"/>
        <source>Checking your PC</source>
        <translation>Dein PC wird geprüft</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="137"/>
        <source>Check again</source>
        <translation>Erneut prüfen</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="152"/>
        <source>Do you want to install it later?</source>
        <translation>Möchtest du es später installieren?</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="161"/>
        <source>Just try it</source>
        <translation>Nur ausprobieren</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="162"/>
        <source>Only the boot files go on your drive. You can still install later.</source>
        <translation>Nur die Startdateien kommen auf dein Laufwerk. Installieren kannst du später immer noch.</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="170"/>
        <source>Make room to install it next to Windows</source>
        <translation>Platz schaffen, um es neben Windows zu installieren</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="171"/>
        <source>Testux shrinks drive C: and leaves the space free. In the live system, pick &quot;install alongside Windows&quot;.</source>
        <translation>Testux verkleinert Laufwerk C: und lässt den Platz frei. Wähle im Live-System „Neben Windows installieren“.</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="185"/>
        <source>Space for %1: %2 GB</source>
        <translation>Platz für %1: %2 GB</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="199"/>
        <source>40 GB is plenty for the system, apps and some files.</source>
        <translation>40 GB reichen locker für System, Apps und ein paar Dateien.</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="219"/>
        <source>Before you start</source>
        <translation>Bevor es losgeht</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="232"/>
        <source>Drive C:</source>
        <translation>Laufwerk C:</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="233"/>
        <source>Shrinks by about %1 GB for the boot files and %2.</source>
        <translation>Wird um etwa %1 GB verkleinert, für die Startdateien und %2.</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="234"/>
        <source>Shrinks by about %1 GB for the boot files.</source>
        <translation>Wird um etwa %1 GB verkleinert, für die Startdateien.</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="235"/>
        <source>Next restart</source>
        <translation>Nächster Neustart</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="235"/>
        <source>Starts %1 once. After that Windows starts as usual.</source>
        <translation>Startet einmal %1. Danach startet Windows wie gewohnt.</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="236"/>
        <source>BitLocker</source>
        <translation>BitLocker</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="236"/>
        <source>Paused for that one restart if it is on. Keep your recovery key at hand anyway.</source>
        <translation>Wird für diesen einen Neustart pausiert, falls aktiv. Halte deinen Wiederherstellungsschlüssel trotzdem bereit.</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="237"/>
        <source>Undo</source>
        <translation>Rückgängig</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="237"/>
        <source>Back in Windows, Testux removes the boot files again.</source>
        <translation>Zurück in Windows entfernt Testux die Startdateien wieder.</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="243"/>
        <source>I have a backup of my important files</source>
        <translation>Ich habe eine Sicherung meiner wichtigen Dateien</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="244"/>
        <source>Changing partitions is safe in almost every case. A backup covers the rest.</source>
        <translation>Partitionen zu ändern ist fast immer sicher. Eine Sicherung deckt den Rest ab.</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="259"/>
        <source>Something went wrong</source>
        <translation>Etwas ist schiefgelaufen</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="259"/>
        <source>Preparing your PC</source>
        <translation>Dein PC wird vorbereitet</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="284"/>
        <source>Undo changes</source>
        <translation>Änderungen rückgängig machen</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="290"/>
        <source>Back to the start</source>
        <translation>Zurück zum Anfang</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="304"/>
        <source>Ready to restart</source>
        <translation>Bereit zum Neustart</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="309"/>
        <source>Save your work and close your apps. After the restart your PC starts %1. Have fun looking around!</source>
        <translation>Speichere deine Arbeit und schließe deine Apps. Nach dem Neustart startet dein PC %1. Viel Spaß beim Umschauen!</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="315"/>
        <source>To install, open the installer on the desktop and pick &quot;install alongside Windows&quot; or the free space.</source>
        <translation>Zum Installieren öffne den Installer auf dem Desktop und wähle „Neben Windows installieren“ oder den freien Speicherplatz.</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="325"/>
        <source>Restart now</source>
        <translation>Jetzt neu starten</translation>
    </message>
    <message>
        <location filename="../qml/BootWizard.qml" line="331"/>
        <source>Later</source>
        <translation>Später</translation>
    </message>
</context>
<context>
    <name>Catalog</name>
    <message>
        <location filename="../src/catalog/catalog.cpp" line="111"/>
        <source>Could not update the catalog: %1</source>
        <translation>Die Distro-Liste konnte nicht aktualisiert werden: %1</translation>
    </message>
    <message>
        <location filename="../src/catalog/catalog.cpp" line="127"/>
        <source>The catalog lists no usable distros.</source>
        <translation>Die Distro-Liste enthält keine nutzbaren Distros.</translation>
    </message>
</context>
<context>
    <name>CatalogParser</name>
    <message>
        <location filename="../src/catalog/catalogparser.cpp" line="102"/>
        <source>The catalog is not valid JSON: %1</source>
        <translation>Die Distro-Liste ist kein gültiges JSON: %1</translation>
    </message>
    <message>
        <location filename="../src/catalog/catalogparser.cpp" line="109"/>
        <source>The catalog contains no distro list.</source>
        <translation>Die Distro-Liste enthält keine Distros.</translation>
    </message>
    <message>
        <location filename="../src/catalog/catalogparser.cpp" line="115"/>
        <source>The catalog defines no categories.</source>
        <translation>Die Distro-Liste enthält keine Kategorien.</translation>
    </message>
</context>
<context>
    <name>ChecklistPanel</name>
    <message>
        <location filename="../qml/ChecklistPanel.qml" line="40"/>
        <source>Things to try</source>
        <translation>Zum Ausprobieren</translation>
    </message>
    <message>
        <location filename="../qml/ChecklistPanel.qml" line="45"/>
        <source>%1 of %2</source>
        <translation>%1 von %2</translation>
    </message>
</context>
<context>
    <name>ChoiceMenu</name>
    <message>
        <location filename="../qml/ChoiceMenu.qml" line="21"/>
        <source>%1: %2</source>
        <translation>%1: %2</translation>
    </message>
</context>
<context>
    <name>ComparePage</name>
    <message>
        <location filename="../qml/ComparePage.qml" line="53"/>
        <source>Rolling</source>
        <translation>Rolling</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="53"/>
        <source>Fixed</source>
        <translation>Fest</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="58"/>
        <source>Included</source>
        <translation>Dabei</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="58"/>
        <source>Later</source>
        <translation>Später</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="59"/>
        <source>Not tried yet</source>
        <translation>Nicht getestet</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="64"/>
        <source>Distro</source>
        <translation>Distro</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="65"/>
        <source>Desktop</source>
        <translation>Desktop</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="66"/>
        <source>Based on</source>
        <translation>Basis</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="67"/>
        <source>Updates</source>
        <translation>Updates</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="68"/>
        <source>Download</source>
        <translation>Download</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="69"/>
        <source>Min. memory</source>
        <translation>Min. RAM</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="70"/>
        <source>Secure Boot</source>
        <translation>Secure Boot</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="71"/>
        <source>Live</source>
        <translation>Live</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="72"/>
        <source>NVIDIA</source>
        <translation>NVIDIA</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="108"/>
        <source>Sort by</source>
        <translation>Sortieren nach</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="116"/>
        <source>%1 distros</source>
        <translation>%1 Distros</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="31"/>
        <location filename="../qml/ComparePage.qml" line="73"/>
        <source>Your memory use</source>
        <translation>Dein RAM</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="28"/>
        <source>Name</source>
        <translation>Name</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="29"/>
        <source>Download size</source>
        <translation>Downloadgröße</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="30"/>
        <source>Minimum memory</source>
        <translation>Mindest-RAM</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="93"/>
        <source>Compare</source>
        <translation>Vergleich</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="94"/>
        <source>The facts side by side. Memory use is measured on your PC while a distro runs in a window.</source>
        <translation>Die Fakten nebeneinander. Der RAM-Verbrauch wird auf deinem PC gemessen, während eine Distro im Fenster läuft.</translation>
    </message>
    <message>
        <location filename="../qml/ComparePage.qml" line="99"/>
        <source>&quot;Your memory use&quot; fills in as you try distros. Start one in a window and look at it for a minute.</source>
        <translation>„Dein RAM“ füllt sich, während du Distros testest. Starte eine im Fenster und schau sie dir eine Minute lang an.</translation>
    </message>
</context>
<context>
    <name>DistroCard</name>
    <message>
        <source>Secure Boot</source>
        <translation type="vanished">Secure Boot</translation>
    </message>
    <message>
        <source>Live session</source>
        <translation type="vanished">Live-System</translation>
    </message>
    <message>
        <location filename="../qml/DistroCard.qml" line="89"/>
        <source>Try without installing</source>
        <translation>Ohne Installation testen</translation>
    </message>
    <message>
        <location filename="../qml/DistroCard.qml" line="89"/>
        <source>Installer only</source>
        <translation>Nur Installer</translation>
    </message>
</context>
<context>
    <name>DistroPage</name>
    <message>
        <location filename="../qml/DistroPage.qml" line="18"/>
        <source>Back to all distros</source>
        <translation>Zurück zu allen Distros</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="58"/>
        <source>Website</source>
        <translation>Website</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="84"/>
        <source>About %1</source>
        <translation>Über %1</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="128"/>
        <source>At a glance</source>
        <translation>Auf einen Blick</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="134"/>
        <source>Version</source>
        <translation>Version</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="135"/>
        <source>Desktop</source>
        <translation>Desktop</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="136"/>
        <source>Based on</source>
        <translation>Basiert auf</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="137"/>
        <source>Updates</source>
        <translation>Updates</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="138"/>
        <source>Download</source>
        <translation>Download</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="139"/>
        <source>Memory</source>
        <translation>Arbeitsspeicher</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="139"/>
        <source>%1 or more</source>
        <translation>%1 oder mehr</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="140"/>
        <source>Secure Boot</source>
        <translation>Secure Boot</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="140"/>
        <source>Works with Secure Boot on</source>
        <translation>Läuft mit aktivem Secure Boot</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="140"/>
        <source>Secure Boot must be off</source>
        <translation>Secure Boot muss aus sein</translation>
    </message>
    <message>
        <source>Live session</source>
        <translation type="vanished">Live-System</translation>
    </message>
    <message>
        <source>Yes, try before installing</source>
        <translation type="vanished">Ja, vor dem Installieren testen</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="141"/>
        <source>No, installer only</source>
        <translation>Nein, nur Installer</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="141"/>
        <source>Try without installing</source>
        <translation>Ohne Installation testen</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="141"/>
        <source>Yes</source>
        <translation>Ja</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="142"/>
        <source>NVIDIA driver</source>
        <translation>NVIDIA-Treiber</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="142"/>
        <source>Included or offered</source>
        <translation>Dabei oder wird angeboten</translation>
    </message>
    <message>
        <location filename="../qml/DistroPage.qml" line="142"/>
        <source>Install it afterwards</source>
        <translation>Danach installieren</translation>
    </message>
</context>
<context>
    <name>DistrosPage</name>
    <message>
        <location filename="../qml/DistrosPage.qml" line="76"/>
        <source>Pick a Linux to try</source>
        <translation>Such dir ein Linux zum Testen aus</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="77"/>
        <source>Every distro runs in a window first, so nothing on your PC changes until you decide.</source>
        <translation>Jede Distro läuft zuerst in einem Fenster. An deinem PC ändert sich nichts, bis du dich entscheidest.</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="82"/>
        <source>Testux %1 is available.</source>
        <translation>Testux %1 ist verfügbar.</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="87"/>
        <source>Get the update</source>
        <translation>Update holen</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="94"/>
        <source>The online list could not be loaded, showing the list built into Testux.</source>
        <translation>Die Online-Liste konnte nicht geladen werden, du siehst die in Testux eingebaute Liste.</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="29"/>
        <source>All</source>
        <translation>Alle</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="35"/>
        <source>Works with Secure Boot</source>
        <translation>Läuft mit Secure Boot</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="36"/>
        <source>Live session</source>
        <translation>Live-System</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="37"/>
        <source>NVIDIA driver included</source>
        <translation>NVIDIA-Treiber dabei</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="38"/>
        <source>Rolling updates</source>
        <translation>Rolling Release</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="39"/>
        <source>Fixed releases</source>
        <translation>Feste Versionen</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="40"/>
        <source>Fits my PC</source>
        <translation>Passt zu meinem PC</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="112"/>
        <source>All distros</source>
        <translation>Alle Distros</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="119"/>
        <source>Search by name, desktop or base</source>
        <translation>Nach Name, Desktop oder Basis suchen</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="142"/>
        <source>Category</source>
        <translation>Kategorie</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="149"/>
        <source>Desktop</source>
        <translation>Desktop</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="156"/>
        <source>Based on</source>
        <translation>Basiert auf</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="177"/>
        <source>More</source>
        <translation>Mehr</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="190"/>
        <source>%1 of %2 distros</source>
        <translation>%1 von %2 Distros</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="191"/>
        <source>%1 distros</source>
        <translation>%1 Distros</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="198"/>
        <location filename="../qml/DistrosPage.qml" line="267"/>
        <source>Clear filters</source>
        <translation>Filter zurücksetzen</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="209"/>
        <source>Fewer filters</source>
        <translation>Weniger Filter</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="209"/>
        <source>More filters</source>
        <translation>Mehr Filter</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="226"/>
        <source>Loading the distro list</source>
        <translation>Distro-Liste wird geladen</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="234"/>
        <source>No distros to show</source>
        <translation>Keine Distros zum Anzeigen</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="239"/>
        <source>Try again</source>
        <translation>Erneut versuchen</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="253"/>
        <source>No distro matches</source>
        <translation>Keine Distro passt</translation>
    </message>
    <message>
        <location filename="../qml/DistrosPage.qml" line="259"/>
        <source>Try fewer filters or another search word.</source>
        <translation>Nimm weniger Filter oder ein anderes Suchwort.</translation>
    </message>
</context>
<context>
    <name>DownloadPanel</name>
    <message>
        <location filename="../qml/DownloadPanel.qml" line="23"/>
        <source>Download paused at %1 of %2.</source>
        <translation>Download bei %1 von %2 pausiert.</translation>
    </message>
    <message>
        <location filename="../qml/DownloadPanel.qml" line="24"/>
        <source>First Testux downloads the official ISO (%1) and checks it.</source>
        <translation>Zuerst lädt Testux die offizielle ISO (%1) herunter und prüft sie.</translation>
    </message>
    <message>
        <location filename="../qml/DownloadPanel.qml" line="31"/>
        <source>Resume</source>
        <translation>Fortsetzen</translation>
    </message>
    <message>
        <location filename="../qml/DownloadPanel.qml" line="31"/>
        <source>Download</source>
        <translation>Herunterladen</translation>
    </message>
    <message>
        <location filename="../qml/DownloadPanel.qml" line="46"/>
        <source>Checking the download</source>
        <translation>Download wird geprüft</translation>
    </message>
    <message>
        <location filename="../qml/DownloadPanel.qml" line="47"/>
        <source>Downloading %1 of %2</source>
        <translation>%1 von %2 heruntergeladen</translation>
    </message>
    <message>
        <location filename="../qml/DownloadPanel.qml" line="54"/>
        <source>Pause</source>
        <translation>Pausieren</translation>
    </message>
    <message>
        <location filename="../qml/DownloadPanel.qml" line="75"/>
        <source>Downloaded and checked (%1)</source>
        <translation>Heruntergeladen und geprüft (%1)</translation>
    </message>
    <message>
        <location filename="../qml/DownloadPanel.qml" line="82"/>
        <source>Delete download</source>
        <translation>Download löschen</translation>
    </message>
    <message>
        <source>ISO downloaded and verified (%1)</source>
        <translation type="vanished">ISO heruntergeladen und geprüft (%1)</translation>
    </message>
    <message>
        <source>Delete ISO</source>
        <translation type="vanished">ISO löschen</translation>
    </message>
    <message>
        <location filename="../qml/DownloadPanel.qml" line="90"/>
        <source>The download did not work</source>
        <translation>Der Download hat nicht geklappt</translation>
    </message>
    <message>
        <location filename="../qml/DownloadPanel.qml" line="95"/>
        <source>Try again</source>
        <translation>Erneut versuchen</translation>
    </message>
</context>
<context>
    <name>FilterMenu</name>
    <message>
        <location filename="../qml/FilterMenu.qml" line="17"/>
        <source>%1 (%2)</source>
        <translation>%1 (%2)</translation>
    </message>
</context>
<context>
    <name>Format</name>
    <message>
        <location filename="../qml/Format.qml" line="14"/>
        <location filename="../qml/Format.qml" line="20"/>
        <source>%1 GB</source>
        <translation>%1 GB</translation>
    </message>
    <message>
        <location filename="../qml/Format.qml" line="15"/>
        <location filename="../qml/Format.qml" line="21"/>
        <source>%1 MB</source>
        <translation>%1 MB</translation>
    </message>
    <message>
        <location filename="../qml/Format.qml" line="25"/>
        <source>Yes</source>
        <translation>Ja</translation>
    </message>
    <message>
        <location filename="../qml/Format.qml" line="25"/>
        <source>No</source>
        <translation>Nein</translation>
    </message>
    <message>
        <location filename="../qml/Format.qml" line="34"/>
        <source>%1 desktop, independent</source>
        <translation>%1-Desktop, eigenständig</translation>
    </message>
    <message>
        <location filename="../qml/Format.qml" line="35"/>
        <source>%1 desktop, based on %2</source>
        <translation>%1-Desktop, basiert auf %2</translation>
    </message>
    <message>
        <location filename="../qml/Format.qml" line="39"/>
        <source>Independent</source>
        <translation>Eigenständig</translation>
    </message>
    <message>
        <location filename="../qml/Format.qml" line="43"/>
        <source>Rolling release</source>
        <translation>Rolling Release</translation>
    </message>
    <message>
        <location filename="../qml/Format.qml" line="43"/>
        <source>Fixed releases</source>
        <translation>Feste Versionen</translation>
    </message>
</context>
<context>
    <name>HardwareListPanel</name>
    <message>
        <location filename="../qml/HardwareListPanel.qml" line="38"/>
        <source>None found</source>
        <translation>Nichts gefunden</translation>
    </message>
</context>
<context>
    <name>IsoDownload</name>
    <message>
        <location filename="../src/download/isolibrary.cpp" line="93"/>
        <source>Not enough free disk space. The download needs %1 more.</source>
        <translation>Nicht genug freier Speicherplatz. Der Download braucht noch %1 mehr.</translation>
    </message>
    <message>
        <location filename="../src/download/isolibrary.cpp" line="107"/>
        <source>Cannot write %1.</source>
        <translation>%1 kann nicht geschrieben werden.</translation>
    </message>
    <message>
        <location filename="../src/download/isolibrary.cpp" line="131"/>
        <source>Could not delete the ISO. Is a VM still using it?</source>
        <translation>Die ISO konnte nicht gelöscht werden. Benutzt eine VM sie noch?</translation>
    </message>
    <message>
        <location filename="../src/download/isolibrary.cpp" line="178"/>
        <source>Writing the ISO failed: %1</source>
        <translation>Schreiben der ISO fehlgeschlagen: %1</translation>
    </message>
    <message>
        <location filename="../src/download/isolibrary.cpp" line="194"/>
        <source>Download failed: %1</source>
        <translation>Download fehlgeschlagen: %1</translation>
    </message>
    <message>
        <location filename="../src/download/isolibrary.cpp" line="219"/>
        <source>Could not fetch the checksum: %1</source>
        <translation>Die Prüfsumme konnte nicht geladen werden: %1</translation>
    </message>
    <message>
        <location filename="../src/download/isolibrary.cpp" line="233"/>
        <source>The checksum list does not mention %1.</source>
        <translation>Die Prüfsummenliste enthält %1 nicht.</translation>
    </message>
    <message>
        <location filename="../src/download/isolibrary.cpp" line="240"/>
        <source>The download is damaged (checksum mismatch). Please try again.</source>
        <translation>Der Download ist beschädigt (Prüfsumme stimmt nicht). Bitte versuche es noch einmal.</translation>
    </message>
    <message>
        <location filename="../src/download/isolibrary.cpp" line="244"/>
        <source>Could not move the ISO to %1.</source>
        <translation>Die ISO konnte nicht nach %1 verschoben werden.</translation>
    </message>
</context>
<context>
    <name>Main</name>
    <message>
        <location filename="../qml/Main.qml" line="14"/>
        <source>Distros</source>
        <translation>Distros</translation>
    </message>
    <message>
        <location filename="../qml/Main.qml" line="15"/>
        <source>Compare</source>
        <translation>Vergleich</translation>
    </message>
    <message>
        <location filename="../qml/Main.qml" line="16"/>
        <source>This PC</source>
        <translation>Dieser PC</translation>
    </message>
    <message>
        <location filename="../qml/Main.qml" line="17"/>
        <source>Settings</source>
        <translation>Einstellungen</translation>
    </message>
    <message>
        <location filename="../qml/Main.qml" line="38"/>
        <source>Welcome to Testux</source>
        <translation>Willkommen bei Testux</translation>
    </message>
    <message>
        <location filename="../qml/Main.qml" line="39"/>
        <source>Testux lets you try Linux in a window on this PC. Nothing gets installed and Windows stays exactly as it is.</source>
        <translation>Mit Testux probierst du Linux in einem Fenster auf diesem PC aus. Nichts wird installiert und Windows bleibt genau so, wie es ist.</translation>
    </message>
    <message>
        <location filename="../qml/Main.qml" line="40"/>
        <source>Not sure where to start?</source>
        <translation>Du weißt nicht, wo du anfangen sollst?</translation>
    </message>
    <message>
        <location filename="../qml/Main.qml" line="41"/>
        <source>Answer three quick questions here and Testux suggests three distros that fit you.</source>
        <translation>Beantworte hier drei kurze Fragen und Testux schlägt dir drei passende Distros vor.</translation>
    </message>
    <message>
        <location filename="../qml/Main.qml" line="42"/>
        <source>Or look around yourself</source>
        <translation>Oder schau dich selbst um</translation>
    </message>
    <message>
        <location filename="../qml/Main.qml" line="43"/>
        <source>All distros are listed here. Click one to read what it is like.</source>
        <translation>Hier stehen alle Distros. Klick auf eine, um zu lesen, wie sie ist.</translation>
    </message>
    <message>
        <location filename="../qml/Main.qml" line="44"/>
        <source>Try it</source>
        <translation>Ausprobieren</translation>
    </message>
    <message>
        <location filename="../qml/Main.qml" line="45"/>
        <source>On a distro&apos;s page press Try it. Testux downloads it once, checks it and opens Linux in its own window. Close that window when you are done.</source>
        <translation>Drück auf der Seite einer Distro auf Ausprobieren. Testux lädt sie einmal herunter, prüft sie und öffnet Linux in einem eigenen Fenster. Schließ das Fenster, wenn du fertig bist.</translation>
    </message>
    <message>
        <location filename="../qml/Main.qml" line="46"/>
        <source>Will it run well?</source>
        <translation>Läuft es gut auf deinem PC?</translation>
    </message>
    <message>
        <location filename="../qml/Main.qml" line="47"/>
        <source>This PC checks your memory, graphics and Wi-Fi, so you know what to expect.</source>
        <translation>Unter Dieser PC prüft Testux Arbeitsspeicher, Grafik und WLAN, damit du weißt, was dich erwartet.</translation>
    </message>
    <message>
        <location filename="../qml/Main.qml" line="48"/>
        <source>Need this again?</source>
        <translation>Willst du das noch mal sehen?</translation>
    </message>
    <message>
        <location filename="../qml/Main.qml" line="49"/>
        <source>Start this tour again here at any time.</source>
        <translation>Hier kannst du diese Tour jederzeit wieder starten.</translation>
    </message>
</context>
<context>
    <name>QuizPanel</name>
    <message>
        <location filename="../qml/QuizPanel.qml" line="22"/>
        <source>What do you mostly use your PC for?</source>
        <translation>Wofür nutzt du deinen PC hauptsächlich?</translation>
    </message>
    <message>
        <location filename="../qml/QuizPanel.qml" line="24"/>
        <source>Everyday &amp; office</source>
        <translation>Alltag &amp; Büro</translation>
    </message>
    <message>
        <location filename="../qml/QuizPanel.qml" line="25"/>
        <source>Gaming</source>
        <translation>Gaming</translation>
    </message>
    <message>
        <location filename="../qml/QuizPanel.qml" line="26"/>
        <source>Creative work &amp; coding</source>
        <translation>Kreativ &amp; Programmieren</translation>
    </message>
    <message>
        <location filename="../qml/QuizPanel.qml" line="27"/>
        <source>Older or slow PC</source>
        <translation>Alter oder langsamer PC</translation>
    </message>
    <message>
        <location filename="../qml/QuizPanel.qml" line="32"/>
        <source>How should it look?</source>
        <translation>Wie soll es aussehen?</translation>
    </message>
    <message>
        <location filename="../qml/QuizPanel.qml" line="34"/>
        <source>Like Windows</source>
        <translation>Wie Windows</translation>
    </message>
    <message>
        <location filename="../qml/QuizPanel.qml" line="35"/>
        <source>Like macOS</source>
        <translation>Wie macOS</translation>
    </message>
    <message>
        <location filename="../qml/QuizPanel.qml" line="36"/>
        <source>Doesn&apos;t matter, modern</source>
        <translation>Egal, modern</translation>
    </message>
    <message>
        <location filename="../qml/QuizPanel.qml" line="41"/>
        <source>How much do you want to tinker?</source>
        <translation>Wie viel willst du basteln?</translation>
    </message>
    <message>
        <location filename="../qml/QuizPanel.qml" line="43"/>
        <source>Not at all</source>
        <translation>Gar nicht</translation>
    </message>
    <message>
        <location filename="../qml/QuizPanel.qml" line="44"/>
        <source>A little</source>
        <translation>Ein bisschen</translation>
    </message>
    <message>
        <location filename="../qml/QuizPanel.qml" line="45"/>
        <source>I love it</source>
        <translation>Sehr gerne</translation>
    </message>
    <message>
        <location filename="../qml/QuizPanel.qml" line="73"/>
        <source>Which Linux suits you?</source>
        <translation>Welches Linux passt zu dir?</translation>
    </message>
    <message>
        <location filename="../qml/QuizPanel.qml" line="79"/>
        <source>Based on your answers, these three are a good start.</source>
        <translation>Nach deinen Antworten sind diese drei ein guter Anfang.</translation>
    </message>
    <message>
        <location filename="../qml/QuizPanel.qml" line="80"/>
        <source>Answer three quick questions and Testux suggests three distros to try.</source>
        <translation>Beantworte drei kurze Fragen und Testux schlägt dir drei Distros zum Ausprobieren vor.</translation>
    </message>
    <message>
        <location filename="../qml/QuizPanel.qml" line="89"/>
        <source>Start over</source>
        <translation>Neu beginnen</translation>
    </message>
</context>
<context>
    <name>Readiness</name>
    <message>
        <location filename="../src/hw/readiness.cpp" line="52"/>
        <source>Checking hardware</source>
        <translation>Hardware wird geprüft</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="53"/>
        <source>The hardware check has not finished yet.</source>
        <translation>Die Hardwareprüfung ist noch nicht fertig.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="58"/>
        <source>Windows only for now</source>
        <translation>Vorerst nur unter Windows</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="59"/>
        <source>Booting a distro on this PC works from Windows. On Linux, try it in a window instead.</source>
        <translation>Eine Distro auf diesem PC zu starten geht von Windows aus. Unter Linux teste sie stattdessen im Fenster.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="66"/>
        <source>Starts in UEFI mode</source>
        <translation>Startet im UEFI-Modus</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="67"/>
        <source>Legacy BIOS mode</source>
        <translation>Legacy-BIOS-Modus</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="68"/>
        <source>This PC starts Windows in legacy BIOS mode. Booting a live system from the drive needs UEFI mode. Try the distro in a window instead.</source>
        <translation>Dieser PC startet Windows im Legacy-BIOS-Modus. Ein Live-System vom Laufwerk zu starten braucht den UEFI-Modus. Teste die Distro stattdessen im Fenster.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="75"/>
        <source>GPT system disk</source>
        <translation>GPT-Systemdatenträger</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="76"/>
        <source>MBR system disk</source>
        <translation>MBR-Systemdatenträger</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="77"/>
        <source>Windows is installed on an MBR disk. Testux can only add its boot partition to GPT disks. Try the distro in a window instead.</source>
        <translation>Windows ist auf einem MBR-Datenträger installiert. Testux kann seine Startpartition nur auf GPT-Datenträgern anlegen. Teste die Distro stattdessen im Fenster.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="84"/>
        <source>Can start from the hard drive</source>
        <translation>Kann von der Festplatte starten</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="87"/>
        <source>This ISO cannot start from the hard drive</source>
        <translation>Diese ISO kann nicht von der Festplatte starten</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="90"/>
        <source>Try %1 in a window instead, or put it on a USB stick.</source>
        <translation>Teste %1 stattdessen im Fenster oder schreib die ISO auf einen USB-Stick.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="97"/>
        <source>Secure Boot is off</source>
        <translation>Secure Boot ist aus</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="97"/>
        <source>Every distro can start.</source>
        <translation>Jede Distro kann starten.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="100"/>
        <location filename="../src/hw/readiness.cpp" line="102"/>
        <source>Secure Boot is on</source>
        <translation>Secure Boot ist an</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="101"/>
        <source>%1 is signed for Secure Boot and starts as is.</source>
        <translation>%1 ist für Secure Boot signiert und startet ohne Änderungen.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="103"/>
        <source>%1 is not signed for Secure Boot. Hold Shift while clicking Restart, then choose Troubleshoot &gt; Advanced options &gt; UEFI Firmware Settings and turn Secure Boot off. You can turn it back on after testing.</source>
        <translation>%1 ist nicht für Secure Boot signiert. Halte die Umschalttaste gedrückt und klicke auf Neu starten, wähle dann Problembehandlung &gt; Erweiterte Optionen &gt; UEFI-Firmwareeinstellungen und schalte Secure Boot aus. Nach dem Testen kannst du es wieder einschalten.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="112"/>
        <source>Enough free space</source>
        <translation>Genug freier Speicherplatz</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="113"/>
        <source>%1 GB needed, %2 GB free.</source>
        <translation>%1 GB nötig, %2 GB frei.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="114"/>
        <source>Not enough free space</source>
        <translation>Nicht genug freier Speicherplatz</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="115"/>
        <source>Testux needs %1 GB on the Windows drive for the live system and the space for Linux, but only %2 GB are free. Free up space or reserve less for Linux.</source>
        <translation>Testux braucht %1 GB auf dem Windows-Laufwerk für das Live-System und den Platz für Linux, es sind aber nur %2 GB frei. Schaffe Platz oder reserviere weniger für Linux.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="124"/>
        <source>Drive not encrypted</source>
        <translation>Laufwerk nicht verschlüsselt</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="125"/>
        <source>BitLocker is on</source>
        <translation>BitLocker ist an</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="126"/>
        <source>Testux pauses BitLocker for one restart so Windows starts normally afterwards. Keep your recovery key at hand: aka.ms/myrecoverykey. Once Linux is installed, starting Windows through the Linux boot menu can make BitLocker ask for it; picking Windows in the firmware boot menu avoids that.</source>
        <translation>Testux pausiert BitLocker für einen Neustart, damit Windows danach normal startet. Halte deinen Wiederherstellungsschlüssel bereit: aka.ms/myrecoverykey. Ist Linux installiert und du startest Windows über das Linux-Startmenü, kann BitLocker danach fragen. Wählst du Windows im Startmenü der Firmware, passiert das nicht.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="136"/>
        <source>Fast Startup is off</source>
        <translation>Schnellstart ist aus</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="137"/>
        <source>Fast Startup is on</source>
        <translation>Schnellstart ist an</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="138"/>
        <source>With Fast Startup Windows never fully shuts down, so Linux can read but not change your Windows files. Turn it off in Control Panel &gt; Power Options &gt; Choose what the power buttons do.</source>
        <translation>Mit Schnellstart fährt Windows nie ganz herunter, deshalb kann Linux deine Windows-Dateien lesen, aber nicht ändern. Schalte ihn aus unter Systemsteuerung &gt; Energieoptionen &gt; Auswählen, was beim Drücken von Netzschaltern geschehen soll.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="147"/>
        <source>Enough memory</source>
        <translation>Genug Arbeitsspeicher</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="147"/>
        <source>%1 GB RAM.</source>
        <translation>%1 GB RAM.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="149"/>
        <source>Little memory</source>
        <translation>Wenig Arbeitsspeicher</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="150"/>
        <source>%1 recommends %2 GB of RAM, this PC has %3 GB. It runs, but may feel slow.</source>
        <translation>%1 empfiehlt %2 GB RAM, dieser PC hat %3 GB. Es läuft, kann sich aber langsam anfühlen.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="158"/>
        <source>Graphics</source>
        <translation>Grafik</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="159"/>
        <source>Intel and AMD graphics work with the drivers built into Linux.</source>
        <translation>Intel- und AMD-Grafik laufen mit den Treibern, die in Linux eingebaut sind.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="161"/>
        <location filename="../src/hw/readiness.cpp" line="164"/>
        <source>NVIDIA graphics</source>
        <translation>NVIDIA-Grafik</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="162"/>
        <source>%1 includes the NVIDIA driver or offers it during setup.</source>
        <translation>%1 bringt den NVIDIA-Treiber mit oder bietet ihn bei der Installation an.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="165"/>
        <source>%1 starts with the open-source NVIDIA driver, which can be slow. If the screen stays black, pick the safe graphics (nomodeset) entry in the boot menu and install the NVIDIA driver after setup.</source>
        <translation>%1 startet mit dem quelloffenen NVIDIA-Treiber, der langsam sein kann. Bleibt der Bildschirm schwarz, wähle im Startmenü den Eintrag mit sicherer Grafik (nomodeset) und installiere den NVIDIA-Treiber nach der Installation.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="174"/>
        <source>Network</source>
        <translation>Netzwerk</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="175"/>
        <source>Broadcom Wi-Fi</source>
        <translation>Broadcom-WLAN</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="176"/>
        <source>Broadcom Wi-Fi chips often need an extra driver on Linux. Keep a network cable or USB tethering from your phone ready.</source>
        <translation>Broadcom-WLAN-Chips brauchen unter Linux oft einen extra Treiber. Halte ein Netzwerkkabel oder USB-Tethering vom Handy bereit.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="183"/>
        <source>Live desktop</source>
        <translation>Live-Desktop</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="184"/>
        <source>%1 runs from the boot partition and changes nothing until you install it.</source>
        <translation>%1 läuft von der Startpartition und ändert nichts, bis du es installierst.</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="187"/>
        <source>Installer only</source>
        <translation>Nur Installer</translation>
    </message>
    <message>
        <location filename="../src/hw/readiness.cpp" line="188"/>
        <source>%1 has no live desktop. The ISO starts its installer right away, so you cannot try it before installing.</source>
        <translation>%1 hat keinen Live-Desktop. Die ISO startet sofort den Installer, du kannst es also vor dem Installieren nicht ausprobieren.</translation>
    </message>
</context>
<context>
    <name>Recommend</name>
    <message>
        <location filename="../src/catalog/recommend.cpp" line="48"/>
        <source>Easy for everyday use</source>
        <translation>Einfach im Alltag</translation>
    </message>
    <message>
        <location filename="../src/catalog/recommend.cpp" line="51"/>
        <source>Set up for gaming</source>
        <translation>Fürs Gaming eingerichtet</translation>
    </message>
    <message>
        <location filename="../src/catalog/recommend.cpp" line="52"/>
        <source>NVIDIA driver included</source>
        <translation>NVIDIA-Treiber dabei</translation>
    </message>
    <message>
        <location filename="../src/catalog/recommend.cpp" line="54"/>
        <source>Comes with creative apps</source>
        <translation>Mit Kreativ-Apps</translation>
    </message>
    <message>
        <location filename="../src/catalog/recommend.cpp" line="55"/>
        <source>Great for programming</source>
        <translation>Gut zum Programmieren</translation>
    </message>
    <message>
        <location filename="../src/catalog/recommend.cpp" line="57"/>
        <source>Runs well on older PCs</source>
        <translation>Läuft gut auf älteren PCs</translation>
    </message>
    <message>
        <location filename="../src/catalog/recommend.cpp" line="68"/>
        <source>Taskbar and start menu like Windows</source>
        <translation>Taskleiste und Startmenü wie bei Windows</translation>
    </message>
    <message>
        <location filename="../src/catalog/recommend.cpp" line="71"/>
        <source>Feels a bit like macOS</source>
        <translation>Fühlt sich ein bisschen wie macOS an</translation>
    </message>
    <message>
        <location filename="../src/catalog/recommend.cpp" line="74"/>
        <source>A clean, modern desktop</source>
        <translation>Ein aufgeräumter, moderner Desktop</translation>
    </message>
    <message>
        <location filename="../src/catalog/recommend.cpp" line="84"/>
        <source>Works out of the box</source>
        <translation>Läuft sofort ohne Einrichten</translation>
    </message>
    <message>
        <location filename="../src/catalog/recommend.cpp" line="89"/>
        <source>Lets you change everything</source>
        <translation>Du kannst alles anpassen</translation>
    </message>
    <message>
        <location filename="../src/catalog/recommend.cpp" line="90"/>
        <source>Always the newest software</source>
        <translation>Immer die neueste Software</translation>
    </message>
</context>
<context>
    <name>SessionView</name>
    <message>
        <location filename="../qml/SessionView.qml" line="39"/>
        <source>Shutting down %1</source>
        <translation>%1 wird heruntergefahren</translation>
    </message>
    <message>
        <location filename="../qml/SessionView.qml" line="41"/>
        <source>%1 is running in its own window</source>
        <translation>%1 läuft in einem eigenen Fenster</translation>
    </message>
    <message>
        <location filename="../qml/SessionView.qml" line="42"/>
        <source>Starting %1</source>
        <translation>%1 wird gestartet</translation>
    </message>
    <message>
        <location filename="../qml/SessionView.qml" line="49"/>
        <source>Stop</source>
        <translation>Beenden</translation>
    </message>
    <message>
        <location filename="../qml/SessionView.qml" line="64"/>
        <source>Uses %1 of %2 memory</source>
        <translation>Nutzt %1 von %2 Arbeitsspeicher</translation>
    </message>
    <message>
        <location filename="../qml/SessionView.qml" line="76"/>
        <source>Memory use shows up once the system has booted.</source>
        <translation>Der RAM-Verbrauch erscheint, sobald das System hochgefahren ist.</translation>
    </message>
</context>
<context>
    <name>SettingsPage</name>
    <message>
        <location filename="../qml/SettingsPage.qml" line="12"/>
        <source>Settings</source>
        <translation>Einstellungen</translation>
    </message>
    <message>
        <location filename="../qml/SettingsPage.qml" line="23"/>
        <source>Downloads</source>
        <translation>Downloads</translation>
    </message>
    <message>
        <location filename="../qml/SettingsPage.qml" line="33"/>
        <source>Downloaded ISOs take up %1.</source>
        <translation>Heruntergeladene ISOs belegen %1.</translation>
    </message>
    <message>
        <location filename="../qml/SettingsPage.qml" line="34"/>
        <source>No ISOs downloaded.</source>
        <translation>Keine ISOs heruntergeladen.</translation>
    </message>
    <message>
        <location filename="../qml/SettingsPage.qml" line="41"/>
        <source>Delete all ISOs</source>
        <translation>Alle ISOs löschen</translation>
    </message>
    <message>
        <location filename="../qml/SettingsPage.qml" line="57"/>
        <source>Distro list</source>
        <translation>Distro-Liste</translation>
    </message>
    <message>
        <location filename="../qml/SettingsPage.qml" line="66"/>
        <source>Distros in the list: %1. It updates by itself every time Testux starts.</source>
        <translation>Distros in der Liste: %1. Sie aktualisiert sich bei jedem Start von Testux von selbst.</translation>
    </message>
    <message>
        <location filename="../qml/SettingsPage.qml" line="72"/>
        <source>Updating</source>
        <translation>Wird aktualisiert</translation>
    </message>
    <message>
        <location filename="../qml/SettingsPage.qml" line="72"/>
        <source>Update now</source>
        <translation>Jetzt aktualisieren</translation>
    </message>
    <message>
        <location filename="../qml/SettingsPage.qml" line="88"/>
        <source>About Testux</source>
        <translation>Über Testux</translation>
    </message>
    <message>
        <location filename="../qml/SettingsPage.qml" line="93"/>
        <source>Version %1. Testux is free software under the GNU General Public License version 3.</source>
        <translation>Version %1. Testux ist freie Software unter der GNU General Public License Version 3.</translation>
    </message>
    <message>
        <location filename="../qml/SettingsPage.qml" line="104"/>
        <source>Source code</source>
        <translation>Quellcode</translation>
    </message>
    <message>
        <location filename="../qml/SettingsPage.qml" line="110"/>
        <source>Report a problem</source>
        <translation>Problem melden</translation>
    </message>
    <message>
        <location filename="../qml/SettingsPage.qml" line="120"/>
        <source>Delete all ISOs?</source>
        <translation>Alle ISOs löschen?</translation>
    </message>
    <message>
        <location filename="../qml/SettingsPage.qml" line="123"/>
        <source>This frees %1. Test disks stay. You can download any ISO again later.</source>
        <translation>Das gibt %1 frei. Test-Disks bleiben erhalten. Du kannst jede ISO später wieder herunterladen.</translation>
    </message>
    <message>
        <location filename="../qml/SettingsPage.qml" line="130"/>
        <source>Cancel</source>
        <translation>Abbrechen</translation>
    </message>
    <message>
        <location filename="../qml/SettingsPage.qml" line="135"/>
        <source>Delete</source>
        <translation>Löschen</translation>
    </message>
</context>
<context>
    <name>Sidebar</name>
    <message>
        <location filename="../qml/Sidebar.qml" line="88"/>
        <source>How Testux works</source>
        <translation>So funktioniert Testux</translation>
    </message>
    <message>
        <location filename="../qml/Sidebar.qml" line="109"/>
        <source>Running: %1</source>
        <translation>Läuft: %1</translation>
    </message>
    <message>
        <location filename="../qml/Sidebar.qml" line="116"/>
        <source>Stop</source>
        <translation>Beenden</translation>
    </message>
    <message>
        <location filename="../qml/Sidebar.qml" line="124"/>
        <source>Version %1</source>
        <translation>Version %1</translation>
    </message>
</context>
<context>
    <name>ThisPcPage</name>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="13"/>
        <source>This PC</source>
        <translation>Dieser PC</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="14"/>
        <source>What Testux found out about your hardware. None of it leaves your PC.</source>
        <translation>Das hat Testux über deine Hardware herausgefunden. Nichts davon verlässt deinen PC.</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="28"/>
        <source>Checking your PC</source>
        <translation>Dein PC wird geprüft</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="45"/>
        <source>System</source>
        <translation>System</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="51"/>
        <source>Check again</source>
        <translation>Erneut prüfen</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="62"/>
        <source>Memory</source>
        <translation>Arbeitsspeicher</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="63"/>
        <source>Processor threads</source>
        <translation>Prozessor-Threads</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="64"/>
        <source>Free space on the system drive</source>
        <translation>Frei auf dem Systemlaufwerk</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="65"/>
        <source>Fast virtual machines</source>
        <translation>Schnelle virtuelle Maschinen</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="65"/>
        <source>Available</source>
        <translation>Verfügbar</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="65"/>
        <source>Not available, VMs run slowly</source>
        <translation>Nicht verfügbar, VMs laufen langsam</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="66"/>
        <source>Boot mode</source>
        <translation>Startmodus</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="66"/>
        <source>UEFI</source>
        <translation>UEFI</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="66"/>
        <source>Legacy BIOS</source>
        <translation>Legacy-BIOS</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="67"/>
        <source>Secure Boot</source>
        <translation>Secure Boot</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="67"/>
        <location filename="../qml/ThisPcPage.qml" line="71"/>
        <location filename="../qml/ThisPcPage.qml" line="72"/>
        <source>On</source>
        <translation>An</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="67"/>
        <location filename="../qml/ThisPcPage.qml" line="71"/>
        <location filename="../qml/ThisPcPage.qml" line="72"/>
        <source>Off</source>
        <translation>Aus</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="70"/>
        <source>Partition style</source>
        <translation>Partitionsstil</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="70"/>
        <source>GPT</source>
        <translation>GPT</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="70"/>
        <source>MBR</source>
        <translation>MBR</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="71"/>
        <source>BitLocker</source>
        <translation>BitLocker</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="72"/>
        <source>Fast Startup</source>
        <translation>Schnellstart</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="83"/>
        <source>Graphics</source>
        <translation>Grafik</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="86"/>
        <source>NVIDIA cards work best with the proprietary driver. Distros marked &quot;NVIDIA driver included&quot; set it up for you, on the others you install it after setup.</source>
        <translation>NVIDIA-Karten laufen am besten mit dem proprietären Treiber. Distros mit „NVIDIA-Treiber dabei“ richten ihn für dich ein, bei den anderen installierst du ihn nach der Installation.</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="93"/>
        <source>Wi-Fi</source>
        <translation>WLAN</translation>
    </message>
    <message>
        <location filename="../qml/ThisPcPage.qml" line="96"/>
        <source>Broadcom Wi-Fi often needs an extra driver on Linux. Keep a network cable or phone tethering ready for the first start.</source>
        <translation>Broadcom-WLAN braucht unter Linux oft einen extra Treiber. Halte für den ersten Start ein Netzwerkkabel oder Tethering vom Handy bereit.</translation>
    </message>
</context>
<context>
    <name>TourOverlay</name>
    <message>
        <location filename="../qml/TourOverlay.qml" line="129"/>
        <source>Step %1 of %2</source>
        <translation>Schritt %1 von %2</translation>
    </message>
    <message>
        <location filename="../qml/TourOverlay.qml" line="155"/>
        <source>Skip tour</source>
        <translation>Tour überspringen</translation>
    </message>
    <message>
        <location filename="../qml/TourOverlay.qml" line="165"/>
        <source>Back</source>
        <translation>Zurück</translation>
    </message>
    <message>
        <location filename="../qml/TourOverlay.qml" line="172"/>
        <source>Let&apos;s go</source>
        <translation>Los geht&apos;s</translation>
    </message>
    <message>
        <location filename="../qml/TourOverlay.qml" line="172"/>
        <source>Next</source>
        <translation>Weiter</translation>
    </message>
</context>
<context>
    <name>TryPanel</name>
    <message>
        <location filename="../qml/TryPanel.qml" line="71"/>
        <location filename="../qml/TryPanel.qml" line="156"/>
        <source>Try it in a window</source>
        <translation>Im Fenster ausprobieren</translation>
    </message>
    <message>
        <source>%1 runs in a window next to your apps. Your PC stays exactly as it is.</source>
        <translation type="vanished">%1 läuft in einem Fenster neben deinen Apps. Dein PC bleibt genau so, wie er ist.</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="76"/>
        <source>%1 opens in its own window next to your apps. Nothing on your PC changes, close the window when you are done.</source>
        <translation>%1 öffnet sich in einem eigenen Fenster neben deinen Apps. An deinem PC ändert sich nichts, schließ das Fenster einfach, wenn du fertig bist.</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="85"/>
        <source>QEMU is missing</source>
        <translation>QEMU fehlt</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="93"/>
        <source>This will run slowly</source>
        <translation>Das wird langsam laufen</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="93"/>
        <source>Restart Windows for fast mode</source>
        <translation>Windows für den schnellen Modus neu starten</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="100"/>
        <source>Turning on fast mode</source>
        <translation>Schneller Modus wird eingeschaltet</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="100"/>
        <source>Turn on fast mode</source>
        <translation>Schnellen Modus einschalten</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="107"/>
        <source>%1 cannot be tried without installing. The window opens its installer, so turn on &quot;Keep a test install&quot; below to see the system.</source>
        <translation>%1 lässt sich nicht ohne Installation testen. Im Fenster öffnet sich der Installer, schalte also unten &quot;Testinstallation behalten&quot; ein, um das System zu sehen.</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="120"/>
        <source>%1 opens by itself when the download is done.</source>
        <translation>%1 startet von selbst, sobald der Download fertig ist.</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="156"/>
        <source>Try it</source>
        <translation>Ausprobieren</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="164"/>
        <source>Download paused at %1 of %2.</source>
        <translation>Download bei %1 von %2 pausiert.</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="165"/>
        <source>Downloads %1 once and checks it, then it starts.</source>
        <translation>Lädt einmalig %1 herunter, prüft es und startet dann.</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="175"/>
        <source>Continue my test install</source>
        <translation>Meine Testinstallation fortsetzen</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="175"/>
        <source>Keep a test install</source>
        <translation>Testinstallation behalten</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="177"/>
        <source>The system you installed last time starts again.</source>
        <translation>Das System, das du letztes Mal installiert hast, startet wieder.</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="178"/>
        <source>Run the installer inside the window and keep the result for next time. Uses up to 30 GB, only what is needed.</source>
        <translation>Führe den Installer im Fenster aus und behalte das Ergebnis fürs nächste Mal. Belegt bis zu 30 GB, nur so viel wie nötig.</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="189"/>
        <source>Delete test install</source>
        <translation>Testinstallation löschen</translation>
    </message>
    <message>
        <source>%1 has no live desktop. The window opens its installer, so use a test disk to see the system.</source>
        <translation type="vanished">%1 hat keinen Live-Desktop. Im Fenster öffnet sich der Installer, nimm also eine Test-Disk, um das System zu sehen.</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="140"/>
        <source>The VM stopped with an error</source>
        <translation>Die VM wurde mit einem Fehler beendet</translation>
    </message>
    <message>
        <source>Use my test disk</source>
        <translation type="vanished">Meine Test-Disk verwenden</translation>
    </message>
    <message>
        <source>Add a test disk</source>
        <translation type="vanished">Test-Disk hinzufügen</translation>
    </message>
    <message>
        <source>Your test install from last time is kept.</source>
        <translation type="vanished">Deine Testinstallation vom letzten Mal bleibt erhalten.</translation>
    </message>
    <message>
        <source>Lets you run the installer for a real test install. Takes up to 30 GB, only what is used.</source>
        <translation type="vanished">Damit kannst du den Installer für eine echte Testinstallation nutzen. Belegt bis zu 30 GB, nur so viel wie gebraucht wird.</translation>
    </message>
    <message>
        <source>Start in a window</source>
        <translation type="vanished">Im Fenster starten</translation>
    </message>
    <message>
        <source>Delete test disk</source>
        <translation type="vanished">Test-Disk löschen</translation>
    </message>
    <message>
        <location filename="../qml/TryPanel.qml" line="200"/>
        <source>Another distro is running. Starting this one stops it first.</source>
        <translation>Eine andere Distro läuft gerade. Wenn du diese startest, wird die andere zuerst beendet.</translation>
    </message>
</context>
<context>
    <name>VmManager</name>
    <message>
        <location filename="../src/vm/vmmanager.cpp" line="145"/>
        <source>QEMU is missing from the Testux folder. Reinstall Testux to fix it.</source>
        <translation>QEMU fehlt im Testux-Ordner. Installiere Testux neu, um das zu beheben.</translation>
    </message>
    <message>
        <location filename="../src/vm/vmmanager.cpp" line="149"/>
        <source>QEMU is not installed. Install qemu-system-x86_64 and qemu-img with your package manager.</source>
        <translation>QEMU ist nicht installiert. Installiere qemu-system-x86_64 und qemu-img mit deinem Paketmanager.</translation>
    </message>
    <message>
        <location filename="../src/vm/vmmanager.cpp" line="151"/>
        <source>QEMU is not installed. Install it with: %1</source>
        <translation>QEMU ist nicht installiert. Installiere es mit: %1</translation>
    </message>
    <message>
        <location filename="../src/vm/vmmanager.cpp" line="159"/>
        <source>Fast mode is off, so Linux runs slowly. Testux can turn it on, Windows then asks for an administrator once and needs a restart.</source>
        <translation>Der schnelle Modus ist aus, deshalb läuft Linux langsam. Testux kann ihn einschalten, Windows fragt dann einmal nach einem Administrator und braucht einen Neustart.</translation>
    </message>
    <message>
        <location filename="../src/vm/vmmanager.cpp" line="161"/>
        <source>Restart Windows to finish turning on fast mode. If Linux still runs slowly afterwards, turn on virtualization (Intel VT-x or AMD-V/SVM) in your PC&apos;s BIOS/UEFI settings.</source>
        <translation>Starte Windows neu, um den schnellen Modus fertig einzuschalten. Läuft Linux danach immer noch langsam, schalte die Virtualisierung (Intel VT-x oder AMD-V/SVM) in den BIOS/UEFI-Einstellungen deines PCs ein.</translation>
    </message>
    <message>
        <location filename="../src/vm/vmmanager.cpp" line="545"/>
        <source>Fast mode is on after the next restart of Windows. Until then Linux runs slowly.</source>
        <translation>Der schnelle Modus ist nach dem nächsten Neustart von Windows an. Bis dahin läuft Linux langsam.</translation>
    </message>
    <message>
        <location filename="../src/vm/vmmanager.cpp" line="549"/>
        <source>Windows could not turn on fast mode (dism error %1).</source>
        <translation>Windows konnte den schnellen Modus nicht einschalten (dism-Fehler %1).</translation>
    </message>
    <message>
        <source>The Windows Hypervisor Platform is off, so VMs run very slowly. Run this in an administrator terminal, then restart: dism /online /enable-feature /featurename:HypervisorPlatform /all</source>
        <translation type="vanished">Die Windows-Hypervisorplattform ist aus, deshalb laufen VMs sehr langsam. Führe das in einem Terminal als Administrator aus und starte dann neu: dism /online /enable-feature /featurename:HypervisorPlatform /all</translation>
    </message>
    <message>
        <location filename="../src/vm/vmmanager.cpp" line="166"/>
        <source>Your user may not use KVM, so VMs run very slowly. Run: sudo usermod -aG kvm $USER, then log out and back in.</source>
        <translation>Dein Benutzer darf KVM nicht nutzen, deshalb laufen VMs sehr langsam. Führe sudo usermod -aG kvm $USER aus, melde dich dann ab und wieder an.</translation>
    </message>
    <message>
        <location filename="../src/vm/vmmanager.cpp" line="168"/>
        <source>KVM is not available, so VMs run very slowly. Enable virtualization (Intel VT-x or AMD-V/SVM) in your firmware settings.</source>
        <translation>KVM ist nicht verfügbar, deshalb laufen VMs sehr langsam. Aktiviere die Virtualisierung (Intel VT-x oder AMD-V/SVM) in deinen Firmware-Einstellungen.</translation>
    </message>
    <message>
        <location filename="../src/vm/vmmanager.cpp" line="272"/>
        <source>%1 in Testux</source>
        <translation>%1 in Testux</translation>
    </message>
</context>
<context>
    <name>VmSession</name>
    <message>
        <location filename="../src/vm/vmmanager.cpp" line="380"/>
        <source>QEMU stopped unexpectedly (exit code %1).</source>
        <translation>QEMU wurde unerwartet beendet (Exitcode %1).</translation>
    </message>
    <message>
        <location filename="../src/vm/vmmanager.cpp" line="435"/>
        <source>QEMU did not open its control channel.</source>
        <translation>QEMU hat seinen Steuerkanal nicht geöffnet.</translation>
    </message>
    <message>
        <location filename="../src/vm/vmmanager.cpp" line="465"/>
        <source>QEMU could not be started: %1</source>
        <translation>QEMU konnte nicht gestartet werden: %1</translation>
    </message>
</context>
<context>
    <name>WelcomeBackDialog</name>
    <message>
        <location filename="../qml/WelcomeBackDialog.qml" line="13"/>
        <source>Welcome back</source>
        <translation>Willkommen zurück</translation>
    </message>
    <message>
        <location filename="../qml/WelcomeBackDialog.qml" line="13"/>
        <source>Testux boot files found</source>
        <translation>Testux-Startdateien gefunden</translation>
    </message>
    <message>
        <location filename="../qml/WelcomeBackDialog.qml" line="27"/>
        <source>Hope you enjoyed the test drive. Testux can now remove the temporary boot files from your drive.</source>
        <translation>Hoffentlich hat dir die Testfahrt gefallen. Testux kann jetzt die temporären Startdateien von deinem Laufwerk entfernen.</translation>
    </message>
    <message>
        <location filename="../qml/WelcomeBackDialog.qml" line="28"/>
        <source>The temporary boot files from an earlier test are still on your drive. Testux can remove them now.</source>
        <translation>Die temporären Startdateien von einem früheren Test liegen noch auf deinem Laufwerk. Testux kann sie jetzt entfernen.</translation>
    </message>
    <message>
        <location filename="../qml/WelcomeBackDialog.qml" line="36"/>
        <source>Give unused Linux space back to Windows</source>
        <translation>Ungenutzten Linux-Platz an Windows zurückgeben</translation>
    </message>
    <message>
        <location filename="../qml/WelcomeBackDialog.qml" line="37"/>
        <source>Leave this on unless you installed Linux. Space that Linux uses is never touched.</source>
        <translation>Lass das an, außer du hast Linux installiert. Platz, den Linux nutzt, wird nie angefasst.</translation>
    </message>
    <message>
        <location filename="../qml/WelcomeBackDialog.qml" line="67"/>
        <source>Not now</source>
        <translation>Nicht jetzt</translation>
    </message>
    <message>
        <location filename="../qml/WelcomeBackDialog.qml" line="73"/>
        <source>Remove boot files</source>
        <translation>Startdateien entfernen</translation>
    </message>
</context>
</TS>
